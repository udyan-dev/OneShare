import './utils/instrument.js';
import * as dotenv from 'dotenv';
import express from 'express';
import http from 'http';
import {Server} from 'socket.io';
import {store} from './services/store.js';
import type {FileMeta, TransferConfig} from './services/IRoomStore.js';
import {buildIceServersAndCreds} from './utils/turn.js';
import {generateRoomToken, verifyRoomToken} from './utils/security.js';
import {RateLimiter} from './utils/rateLimiter.js';
import {logger} from './utils/logger.js';
import {validateTransferConfig} from './utils/validation.js';
import {startLanMdns} from './services/lanDiscovery.js';
import {initFirebase, logEvent, reportError, updateHealthStatus} from './services/firebase.js';

dotenv.config();
initFirebase();

const app = express();
app.use(express.json());
const port = Number(process.env.PORT || 3000);
const httpServer = http.createServer(app);
const corsOrigin = process.env.NODE_ENV === 'production' ? process.env.CLIENT_URL : '*';

app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', corsOrigin || '*');
    res.header('Access-Control-Allow-Headers', 'Content-Type');
    if (req.method === 'OPTIONS') {
        res.header('Access-Control-Allow-Methods', 'GET,POST,OPTIONS');
        return res.sendStatus(204);
    }
    next();
});

const io = new Server(httpServer, {
    cors: {origin: corsOrigin},
    transports: ['websocket'],
    perMessageDeflate: {threshold: 1024}
});

const lanPeers = new Map<string, Map<string, string[]>>();

function broadcastLanPeers(shareId: string) {
    const map = lanPeers.get(shareId);
    if (!map) return;
    io.to(shareId).emit('lan-peers', Array.from(map.entries()).map(([sid, addrs]) => ({socketId: sid, addrs})));
}

setInterval(async () => {
    try {
        const s = await store.stats();
        updateHealthStatus({rooms: s.rooms, peers: s.peers, sockets: io.sockets.sockets.size});
    } catch {}
}, 5000);

app.get('/health', (_, res) => res.json({status: 'ok'}));
app.get('/health/live', (_, res) => res.json({live: true}));
app.get('/health/ready', async (_, res) => {
    try {
        await store.stats();
        return res.json({ready: true, deps: {firestore: true, turnConfigured: !!process.env.TURN_SECRET}});
    } catch (e) {
        reportError(e as Error);
        return res.status(503).json({ready: false});
    }
});

app.get('/v1/share/:shareId/progress', async (req, res) => {
    try {
        res.json(await store.aggregateProgress(req.params.shareId));
    } catch (e) {
        reportError(e as Error);
        res.status(500).json({error: 'Internal Server Error'});
    }
});

const restLimiter = new RateLimiter(20, 0.5);

app.post('/v1/share/create', async (req, res) => {
    try {
        const ip = (req.headers['x-forwarded-for'] as string)?.split(',')[0]?.trim() || req.ip || 'ip';
        if (!restLimiter.allow(`create:${ip}`, 1)) return res.status(429).json({error: 'rate-limited'});
        
        const files = (req.body?.files as FileMeta[]) || [];
        const config = (req.body?.config as TransferConfig | undefined);
        
        if (!Array.isArray(files) || !files.length) return res.status(400).json({error: 'files required'});
        if (config) {
            const v = validateTransferConfig(config);
            if (!v.ok) return res.status(400).json({error: v.error});
        }

        const {shareId, deletionKey} = await store.createRoomFromApi(files, config);
        const {iceServers, turnCreds} = buildIceServersAndCreds();
        await logEvent('room_created', {shareId, source: 'api'});
        res.json({shareId, deletionKey, roomToken: generateRoomToken(shareId), iceServers, turnCreds});
    } catch (e) {
        reportError(e as Error);
        res.status(500).json({error: 'Internal Server Error'});
    }
});

app.post('/v1/share/close', async (req, res) => {
    try {
        const ip = (req.headers['x-forwarded-for'] as string)?.split(',')[0]?.trim() || req.ip || 'ip';
        if (!restLimiter.allow(`close:${ip}`, 1)) return res.status(429).json({error: 'rate-limited'});
        
        const deletionKey = req.body?.deletionKey as string;
        if (!deletionKey) return res.status(400).json({error: 'deletionKey required'});
        
        const {closed, shareId, receivers, sender} = await Promise.resolve(store.closeRoomByDeletionKey(deletionKey) as any);
        if (!closed || !shareId) return res.status(404).json({error: 'not found'});
        
        io.to(shareId).emit('room-closed');
        if (sender) io.sockets.sockets.get(sender)?.leave(shareId);
        receivers.forEach((id: string) => io.sockets.sockets.get(id)?.leave(shareId));
        
        await logEvent('room_closed', {shareId, source: 'api'});
        res.json({ok: true, shareId});
    } catch (e) {
        reportError(e as Error);
        res.status(500).json({error: 'Internal Server Error'});
    }
});

app.post('/v1/share/:shareId/config', async (req, res) => {
    try {
        const cfg = req.body?.config as TransferConfig | undefined;
        if (!cfg) return res.status(400).json({error: 'config required'});
        
        const v = validateTransferConfig(cfg);
        if (!v.ok) return res.status(400).json({error: v.error});
        
        if (!await store.updateTransferConfig(req.params.shareId, cfg)) return res.status(404).json({error: 'not found'});
        res.json({ok: true});
    } catch (e) {
        reportError(e as Error);
        res.status(500).json({error: 'Internal Server Error'});
    }
});

io.on('connection', (socket) => {
    logger.info({socketId: socket.id}, 'ws connected');
    void logEvent('ws_connected', {socketId: socket.id});

    socket.on('create-room', async (payload: any) => {
        try {
            const addr = (socket.handshake.headers['x-forwarded-for'] as string)?.split(',')[0]?.trim() || socket.handshake.address || socket.id;
            const createLimiter = new RateLimiter(10, 0.2);
            if (!createLimiter.allow(`create:${addr}`, 1)) return socket.emit('create-room-error', 'rate-limited');

            let shareId = payload?.shareId;
            const files = Array.isArray(payload) ? payload : payload?.files;
            const config = payload?.config;

            if (!shareId && (!files || !files.length)) return socket.emit('create-room-error', 'Invalid payload');
            if (config) {
                const v = validateTransferConfig(config);
                if (!v.ok) return socket.emit('create-room-error', v.error);
            }

            if (shareId) {
                if (!await store.attachSender(shareId, socket.id)) return socket.emit('create-room-error', 'Unknown shareId');
            } else {
                shareId = (await store.createRoomWithSender(socket.id, files!, config)).shareId;
                await logEvent('room_created', {shareId, source: 'ws'});
            }

            socket.join(shareId!);
            const {iceServers, turnCreds} = buildIceServersAndCreds();
            const deletionKey = (await store.getRoom(shareId!))?.deletionKey;
            socket.emit('room-created', {shareId, deletionKey, roomToken: generateRoomToken(shareId!), iceServers, turnCreds});
        } catch (e) {
            reportError(e as Error);
            socket.emit('create-room-error', 'Internal Server Error');
        }
    });

    socket.on('join-room', async (payload: any) => {
        try {
            const addr = (socket.handshake.headers['x-forwarded-for'] as string)?.split(',')[0]?.trim() || socket.handshake.address || socket.id;
            const joinLimiter = new RateLimiter(20, 0.5);
            if (!joinLimiter.allow(`join:${addr}`, 1)) return socket.emit('join-room-error', 'rate-limited');

            const shareId = typeof payload === 'string' ? payload : payload?.shareId;
            if (!shareId) return socket.emit('join-room-error', 'shareId required');
            if (!verifyRoomToken(shareId, typeof payload === 'string' ? undefined : payload?.roomToken)) return socket.emit('join-room-error', 'invalid token');

            const room = await store.joinRoom(shareId, socket.id);
            if (!room) return socket.emit('join-room-error', 'Room not found');
            
            socket.join(shareId);
            await logEvent('room_joined', {shareId, socketId: socket.id});
            socket.emit('join-success', {
                fileMetadata: room.fileMetadata,
                otherPeerSocketIds: await store.peersExcept(shareId, socket.id),
                transferConfig: room.transferConfig
            });
            socket.to(shareId).emit('peer-joined', {peerSocketId: socket.id});
        } catch (e) {
            reportError(e as Error);
            socket.emit('join-room-error', 'Internal Server Error');
        }
    });

    ['webrtc-offer', 'webrtc-answer', 'webrtc-ice-candidate'].forEach((evt) => {
        socket.on(evt, (data: any) => {
            if (data?.targetSocketId) io.to(data.targetSocketId).emit(evt, {...data, senderSocketId: socket.id});
        });
    });

    socket.on('turn-refresh', () => {
        const {iceServers, turnCreds} = buildIceServersAndCreds();
        socket.emit('turn-creds', {iceServers, turnCreds});
    });

    socket.on('ice-selected', (data: any) => {
        void logEvent('ice_selected', {type: data?.candidateType || 'unknown', socketId: socket.id});
    });

    socket.on('receiver-progress', async (payload: any) => {
        if (!payload?.shareId || typeof payload?.bytes !== 'number') return;
        store.updateReceiverProgress(payload.shareId, socket.id, payload.bytes);
        io.to(payload.shareId).emit('aggregate-progress', await store.aggregateProgress(payload.shareId));
    });

    socket.on('receiver-backpressure', async (payload: any) => {
        if (!payload?.shareId) return;
        const room = await store.getRoom(payload.shareId);
        if (room?.senderSocketId) io.to(room.senderSocketId).emit('sender-throttle', {receiverSocketId: socket.id, level: payload.level ?? 1});
    });

    socket.on('lan-announce', (payload: any) => {
        const shareId = typeof payload === 'string' ? payload : payload?.shareId;
        const addrs = payload?.addrs;
        if (!shareId || !Array.isArray(addrs) || !addrs.length) return;
        
        let map = lanPeers.get(shareId);
        if (!map) lanPeers.set(shareId, map = new Map());
        map.set(socket.id, addrs);
        broadcastLanPeers(shareId);
    });

    socket.on('lan-reset', (shareId?: string) => {
        if (!shareId) return;
        const map = lanPeers.get(shareId);
        if (map) {
            map.delete(socket.id);
            if (map.size === 0) lanPeers.delete(shareId);
        }
        broadcastLanPeers(shareId);
    });

    socket.on('update-transfer-config', async (payload: any) => {
        if (payload?.shareId && payload?.config && await store.updateTransferConfig(payload.shareId, payload.config)) {
            io.to(payload.shareId).emit('transfer-config-updated', payload.config);
        }
    });

    socket.on('keepalive', async (shareId?: string) => {
        if (shareId) {
            const res = store.refreshRoomTTLByShareId(shareId);
            if (res instanceof Promise) res.then(() => {});
        }
        socket.emit('keepalive', {ok: true});
    });

    const handleLeave = async () => {
        try {
            const {type, shareId} = await store.leaveSocket(socket.id);
            if (!shareId) return;
            socket.leave(shareId);
            
            const map = lanPeers.get(shareId);
            if (map) {
                map.delete(socket.id);
                if (map.size === 0) lanPeers.delete(shareId);
            }
            
            if (type === 'sender') io.to(shareId).emit('room-closed');
            else if (type === 'receiver') socket.to(shareId).emit('peer-left', {peerSocketId: socket.id});
        } catch (e) {
            reportError(e as Error);
        }
    };

    socket.on('leave-room', handleLeave);
    socket.on('disconnect', handleLeave);
});

httpServer.listen(port, '0.0.0.0', () => {
    logger.info({port}, 'Server listening');
    try { startLanMdns(port); } catch {}
});

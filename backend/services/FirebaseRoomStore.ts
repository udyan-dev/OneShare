import {getFirestore} from './firebase.js';
import type {FileMeta, IRoomStore, Room, TransferConfig} from './IRoomStore.js';
import {nanoid} from 'nanoid';
import {logger} from '../utils/logger.js';

const ROOM_TTL_SECONDS = Number(process.env.ROOM_TTL_SECONDS || 900);
const ROOM_COLLECTION = 'oneshare_rooms';

export class FirebaseRoomStore implements IRoomStore {
    private rooms = new Map<string, Room>();
    private socketToShare = new Map<string, string>();
    private deletionToShare = new Map<string, string>();
    private progress = new Map<string, Map<string, number>>();
    private timers = new Map<string, NodeJS.Timeout>();

    private get db() {
        return getFirestore();
    }

    async createRoomFromApi(files: FileMeta[], config?: TransferConfig) {
        const shareId = nanoid(6);
        const deletionKey = nanoid(10);

        const room: Room = {
            shareId,
            deletionKey,
            receiverSocketIds: new Set(),
            fileMetadata: files,
            isWaiting: true,
            createdAt: Date.now(),
            expiresAt: Date.now() + (ROOM_TTL_SECONDS * 1000),
            ...(config ? {transferConfig: config} : {})
        };

        this.saveToMemory(room);
        this.bgWriteRoom(room);

        return {shareId, deletionKey};
    }

    async createRoomWithSender(senderSocketId: string, files: FileMeta[], config?: TransferConfig) {
        const {shareId, deletionKey} = await this.createRoomFromApi(files, config);
        await this.attachSender(shareId, senderSocketId);
        return {shareId, deletionKey};
    }

    async attachSender(shareId: string, senderSocketId: string) {
        const room = this.rooms.get(shareId);
        if (!room) return undefined;

        room.senderSocketId = senderSocketId;
        this.socketToShare.set(senderSocketId, shareId);
        this.refreshTTL(room);

        this.bgUpdateRoom(shareId, {senderSocketId});

        return room;
    }

    async joinRoom(shareId: string, receiverSocketId: string) {
        const room = this.rooms.get(shareId);
        if (!room || !room.isWaiting) return undefined;

        room.receiverSocketIds.add(receiverSocketId);
        this.socketToShare.set(receiverSocketId, shareId);
        this.refreshTTL(room);

        this.bgUpdateRoom(shareId, {
            receiverSocketIds: Array.from(room.receiverSocketIds)
        });

        return room;
    }

    async leaveSocket(socketId: string) {
        const shareId = this.socketToShare.get(socketId);
        if (!shareId) return {type: 'unknown' as const};

        this.socketToShare.delete(socketId);
        const room = this.rooms.get(shareId);

        if (!room) return {type: 'unknown' as const, shareId};

        if (room.senderSocketId === socketId) {
            await this.closeRoomByShareId(shareId);
            return {type: 'sender' as const, shareId};
        } else {
            room.receiverSocketIds.delete(socketId);
            const progMap = this.progress.get(shareId);
            if (progMap) progMap.delete(socketId);

            this.refreshTTL(room);

            this.bgUpdateRoom(shareId, {
                receiverSocketIds: Array.from(room.receiverSocketIds)
            });

            return {type: 'receiver' as const, shareId};
        }
    }

    async getRoom(shareId: string) {
        return this.rooms.get(shareId);
    }

    async closeRoomByShareId(shareId: string) {
        const room = this.rooms.get(shareId);
        if (!room) return {closed: false, receivers: [] as string[]};

        this.rooms.delete(shareId);
        this.deletionToShare.delete(room.deletionKey);
        this.progress.delete(shareId);

        if (room.senderSocketId) this.socketToShare.delete(room.senderSocketId);
        for (const rid of room.receiverSocketIds) this.socketToShare.delete(rid);

        const timer = this.timers.get(shareId);
        if (timer) {
            clearTimeout(timer);
            this.timers.delete(shareId);
        }

        this.bgDeleteRoom(shareId);

        const ret: { closed: boolean; receivers: string[]; sender?: string } = {
            closed: true,
            receivers: Array.from(room.receiverSocketIds)
        };
        if (room.senderSocketId) ret.sender = room.senderSocketId;
        return ret;
    }

    async closeRoomByDeletionKey(deletionKey: string) {
        const shareId = this.deletionToShare.get(deletionKey);
        if (!shareId) return {closed: false};
        const info = await this.closeRoomByShareId(shareId);
        return {...info, shareId};
    }

    async refreshRoomTTLByShareId(shareId: string) {
        const room = this.rooms.get(shareId);
        if (!room) return false;
        this.refreshTTL(room);
        return true;
    }

    async peersExcept(shareId: string, exceptSocketId: string) {
        const room = this.rooms.get(shareId);
        if (!room) return [];
        const peers = new Set(room.receiverSocketIds);
        if (room.senderSocketId) peers.add(room.senderSocketId);
        peers.delete(exceptSocketId);
        return Array.from(peers);
    }

    async updateReceiverProgress(shareId: string, receiverSocketId: string, bytes: number) {
        if (!this.rooms.has(shareId)) return false;

        let map = this.progress.get(shareId);
        if (!map) {
            map = new Map();
            this.progress.set(shareId, map);
        }
        map.set(receiverSocketId, bytes);
        return true;
    }

    async aggregateProgress(shareId: string) {
        const room = this.rooms.get(shareId);
        if (!room) return {totalBytesByReceiver: {}, aggregateBytes: 0, receivers: 0, totalSize: 0};

        const totalSize = room.fileMetadata.reduce((a, f) => a + (f.size || 0), 0);
        const map = this.progress.get(shareId);

        const obj: Record<string, number> = {};
        let agg = 0;

        if (map) {
            for (const [sid, bytes] of map) {
                obj[sid] = bytes;
                agg += bytes;
            }
        }

        return {
            totalBytesByReceiver: obj,
            aggregateBytes: agg,
            receivers: map ? map.size : 0,
            totalSize
        };
    }

    async stats() {
        let receivers = 0;
        let senders = 0;
        for (const r of this.rooms.values()) {
            receivers += r.receiverSocketIds.size;
            if (r.senderSocketId) senders++;
        }
        return {
            rooms: this.rooms.size,
            receivers,
            senders,
            peers: receivers + senders
        };
    }

    async updateTransferConfig(shareId: string, cfg: TransferConfig) {
        const room = this.rooms.get(shareId);
        if (!room) return false;

        room.transferConfig = {...(room.transferConfig || {}), ...cfg};
        this.bgUpdateRoom(shareId, {transferConfig: room.transferConfig});
        return true;
    }

    private saveToMemory(room: Room) {
        this.rooms.set(room.shareId, room);
        this.deletionToShare.set(room.deletionKey, room.shareId);
        this.refreshTTL(room);
    }

    private refreshTTL(room: Room) {
        const existing = this.timers.get(room.shareId);
        if (existing) clearTimeout(existing);

        room.expiresAt = Date.now() + (ROOM_TTL_SECONDS * 1000);

        const timer = setTimeout(() => {
            logger.info({shareId: room.shareId}, 'Room TTL expired');
            this.closeRoomByShareId(room.shareId);
        }, ROOM_TTL_SECONDS * 1000);

        this.timers.set(room.shareId, timer);
    }

    private bgWriteRoom(room: Room) {
        const db = this.db;
        if (!db) return;

        const data = {
            shareId: room.shareId,
            deletionKey: room.deletionKey,
            senderSocketId: room.senderSocketId || null,
            receiverSocketIds: Array.from(room.receiverSocketIds),
            fileMetadata: room.fileMetadata.map(f => ({...f})),
            isWaiting: room.isWaiting,
            createdAt: room.createdAt,
            expiresAt: room.expiresAt,
            transferConfig: room.transferConfig || null
        };

        db.collection(ROOM_COLLECTION).doc(room.shareId).set(data).catch(err => {
            logger.warn({err, shareId: room.shareId}, 'Failed to sync room to Firebase');
        });
    }

    private bgUpdateRoom(shareId: string, data: any) {
        const db = this.db;
        if (!db) return;

        db.collection(ROOM_COLLECTION).doc(shareId).update(data).catch(err => {
            if (err.code !== 5) logger.warn({err, shareId}, 'Failed to update room in Firebase');
        });
    }

    private bgDeleteRoom(shareId: string) {
        const db = this.db;
        if (!db) return;

        db.collection(ROOM_COLLECTION).doc(shareId).delete().catch(err => {
            logger.warn({err, shareId}, 'Failed to delete room from Firebase');
        });
    }
}

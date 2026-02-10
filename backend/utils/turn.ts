import {createHmac, randomBytes} from 'crypto';

function parseList(env?: string, fallback: string[] = []) {
    return (env || '').split(',').map(s => s.trim()).filter(Boolean).concat(fallback);
}

export function buildIceServersAndCreds() {
    const stunUris = parseList(process.env.STUN_URIS, ['stun:stun.l.google.com:19302']);
    const turnUris = parseList(process.env.TURN_URIS);
    const secret = process.env.TURN_SECRET || '';
    const ttlSeconds = Number(process.env.TURN_TTL_SECONDS || 120);

    const expires = Math.floor(Date.now() / 1000) + ttlSeconds;
    const username = `${expires}:${randomBytes(8).toString('hex')}`;
    const credential = secret
        ? createHmac('sha1', secret).update(username).digest('base64')
        : '';

    const iceServers: any[] = [];
    for (const url of stunUris) iceServers.push({urls: url});
    for (const url of turnUris) iceServers.push({urls: url, username, credential});

    const turnCreds = turnUris.length && secret
        ? {username, credential, ttlSeconds, expiresAt: expires}
        : undefined;

    return {iceServers, turnCreds};
}

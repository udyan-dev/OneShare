import {createHmac} from 'crypto';

const TTL = Number(process.env.ROOM_TOKEN_TTL_SECONDS || 900);

function b64url(buf: Buffer) {
    return buf.toString('base64').replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/g, '');
}

export function generateRoomToken(shareId: string): string | undefined {
    const secret = process.env.SIGNING_SECRET;
    if (!secret) return undefined;
    const exp = Math.floor(Date.now() / 1000) + TTL;
    const sig = createHmac('sha256', secret).update(`${shareId}:${exp}`).digest();
    return `${exp}.${b64url(sig)}`;
}

export function verifyRoomToken(shareId: string, token?: string): boolean {
    const secret = process.env.SIGNING_SECRET;
    if (!secret) return true;
    if (!token) return false;
    const [expStr, sigB64] = token.split('.');
    const exp = Number(expStr);
    if (!exp || !sigB64) return false;
    if (exp < Math.floor(Date.now() / 1000)) return false;
    const expected = b64url(createHmac('sha256', secret).update(`${shareId}:${exp}`).digest());
    return expected === sigB64;
}

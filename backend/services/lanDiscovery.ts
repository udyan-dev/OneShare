import os from 'os';
import {logger} from '../utils/logger.js';
import mdns from 'multicast-dns';

function getLocalAddresses(): string[] {
    const nics = os.networkInterfaces();
    const addrs: string[] = [];
    for (const [, infos] of Object.entries(nics)) {
        for (const info of infos || []) {
            if (!info.internal && info.family === 'IPv4') addrs.push(info.address);
        }
    }
    return addrs;
}

let client: any | null = null;

export function startLanMdns(port: number) {
    if (process.env.NODE_ENV === 'production') return;
    try {
        if (client) return;
        client = mdns();
        const name = `OneShare @ ${os.hostname()}`;
        const addresses = getLocalAddresses();
        const txt = [`port=${port}`];
        const respond = () => {
            if (!client) return;
            client.respond({
                answers: [{
                    name: '_oneshare._tcp.local', type: 'PTR', data: `${name}._oneshare._tcp.local`
                }, {
                    name: `${name}._oneshare._tcp.local`,
                    type: 'SRV',
                    data: {port, weight: 0, priority: 10, target: os.hostname()}
                }, ...addresses.map(a => ({
                    name: `${name}._oneshare._tcp.local`, type: 'A', data: a
                })), {name: `${name}._oneshare._tcp.local`, type: 'TXT', data: txt},],
            });
        };
        respond();
        setInterval(respond, 5000);
        logger.info({addresses, port}, 'mDNS: advertising _oneshare._tcp');
    } catch (e) {
        logger.warn({err: (e as any)?.message}, 'mDNS disabled');
    }
}

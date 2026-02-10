import type {TransferConfig} from '../services/IRoomStore.js';

export function validateTransferConfig(cfg: TransferConfig): { ok: true } | { ok: false; error: string } {
    if (cfg.iceHints) {
        if (typeof cfg.iceHints.preferHost !== 'undefined' && typeof cfg.iceHints.preferHost !== 'boolean') {
            return {ok: false, error: 'iceHints.preferHost must be boolean'};
        }
    }
    if (cfg.erasure) {
        if (typeof cfg.erasure.enabled !== 'boolean') return {ok: false, error: 'erasure.enabled must be boolean'};
        if (cfg.erasure.enabled) {
            const {k, m} = cfg.erasure;
            if (typeof k !== 'number' || k <= 0) return {ok: false, error: 'erasure.k must be positive number'};
            if (typeof m !== 'number' || m <= 0) return {ok: false, error: 'erasure.m must be positive number'};
        }
    }
    if (cfg.multiplexing) {
        if (typeof cfg.multiplexing.maxInFlight !== 'undefined' && (typeof cfg.multiplexing.maxInFlight !== 'number' || cfg.multiplexing.maxInFlight <= 0)) {
            return {ok: false, error: 'multiplexing.maxInFlight must be positive number'};
        }
    }
    if (cfg.transportHints) {
        if (typeof cfg.transportHints.allowQUIC !== 'undefined' && typeof cfg.transportHints.allowQUIC !== 'boolean') {
            return {ok: false, error: 'transportHints.allowQUIC must be boolean'};
        }
    }
    return {ok: true};
}

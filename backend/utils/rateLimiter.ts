type Bucket = { tokens: number; last: number };

export class RateLimiter {
    private buckets = new Map<string, Bucket>();

    constructor(private capacity: number, private refillPerSec: number) {}

    allow(key: string, tokens = 1): boolean {
        const now = Date.now();
        const b = this.buckets.get(key) || {tokens: this.capacity, last: now};
        const delta = Math.max(0, now - b.last) / 1000;
        b.tokens = Math.min(this.capacity, b.tokens + delta * this.refillPerSec);
        b.last = now;
        if (b.tokens >= tokens) {
            b.tokens -= tokens;
            this.buckets.set(key, b);
            return true;
        }
        this.buckets.set(key, b);
        return false;
    }
}

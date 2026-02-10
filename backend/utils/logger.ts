import pino from 'pino';

export const logger = pino(process.env.LOG_PRETTY === '1' ? {
    transport: {target: 'pino-pretty', options: {colorize: true, singleLine: true}}
} : {
    serializers: {err: pino.stdSerializers.err},
    messageKey: 'message'
});

export type FileMeta = { name: string; size: number; mime: string };

export type TransferConfig = {
    iceHints?: { preferHost?: boolean };
    erasure?: { enabled: boolean; k?: number; m?: number };
    multiplexing?: { maxInFlight?: number };
    transportHints?: { allowQUIC?: boolean };
};

export type Room = {
    shareId: string;
    deletionKey: string;
    senderSocketId?: string;
    receiverSocketIds: Set<string>;
    fileMetadata: FileMeta[];
    createdAt: number;
    expiresAt: number;
    isWaiting: boolean;
    transferConfig?: TransferConfig;
};

export interface IRoomStore {
    createRoomFromApi(files: FileMeta[], config?: TransferConfig): { shareId: string; deletionKey: string } | Promise<{
        shareId: string; deletionKey: string
    }>;

    createRoomWithSender(senderSocketId: string, files: FileMeta[], config?: TransferConfig): {
        shareId: string; deletionKey: string
    } | Promise<{ shareId: string; deletionKey: string }>;

    attachSender(shareId: string, senderSocketId: string): Room | undefined | Promise<Room | undefined>;

    joinRoom(shareId: string, receiverSocketId: string): Room | undefined | Promise<Room | undefined>;

    leaveSocket(socketId: string): { type: 'sender' | 'receiver' | 'unknown'; shareId?: string } | Promise<{
        type: 'sender' | 'receiver' | 'unknown'; shareId?: string
    }>;

    getRoom(shareId: string): Room | undefined | Promise<Room | undefined>;

    closeRoomByShareId(shareId: string): { closed: boolean; receivers: string[]; sender?: string } | Promise<{
        closed: boolean; receivers: string[]; sender?: string
    }>;

    closeRoomByDeletionKey(deletionKey: string): {
        closed: boolean; shareId?: string; receivers?: string[]; sender?: string
    } | Promise<{ closed: boolean; shareId?: string; receivers?: string[]; sender?: string }>;

    refreshRoomTTLByShareId(shareId: string): boolean | Promise<boolean>;

    peersExcept(shareId: string, exceptSocketId: string): string[] | Promise<string[]>;

    updateReceiverProgress(shareId: string, receiverSocketId: string, bytes: number): boolean | Promise<boolean>;

    aggregateProgress(shareId: string): any | Promise<any>;

    stats(): { rooms: number; receivers: number; senders: number; peers: number } | Promise<{
        rooms: number; receivers: number; senders: number; peers: number
    }>;

    updateTransferConfig(shareId: string, cfg: TransferConfig): Promise<boolean> | boolean;
}


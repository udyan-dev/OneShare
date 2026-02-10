import {FirebaseRoomStore} from './FirebaseRoomStore.js';
import type {IRoomStore} from './IRoomStore.js';

export const store: IRoomStore = new FirebaseRoomStore();

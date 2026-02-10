import admin from 'firebase-admin';
import {ErrorReporting} from '@google-cloud/error-reporting';
import {logger} from '../utils/logger.js';

let initialized = false;
let errors: ErrorReporting | null = null;

const GA_ID = process.env.GA_MEASUREMENT_ID;
const GA_SECRET = process.env.GA_API_SECRET;

export function initFirebase() {
    if (initialized) return;
    try {
        const creds = process.env.FIREBASE_SERVICE_ACCOUNT;
        if (!creds) return;

        const serviceAccount = JSON.parse(creds);
        admin.initializeApp({credential: admin.credential.cert(serviceAccount)});

        if (process.env.NODE_ENV === 'production') {
            errors = new ErrorReporting({
                reportMode: 'production',
                serviceContext: {
                    service: 'oneshare-backend',
                    version: process.env.npm_package_version || '1.0.0'
                },
                projectId: serviceAccount.project_id
            });
        }
        initialized = true;
    } catch (e) {
        logger.error({err: e}, 'Firebase init failed');
    }
}

export function getFirestore() {
    return initialized ? admin.firestore() : null;
}

export async function logEvent(name: string, params: any) {
    if (!initialized || !GA_ID || !GA_SECRET) return;
    try {
        await fetch(`https://www.google-analytics.com/mp/collect?measurement_id=${GA_ID}&api_secret=${GA_SECRET}`, {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({
                client_id: params.socketId || params.shareId || 'server',
                events: [{name, params}]
            })
        });
    } catch (e) {
    }
}

export function reportError(err: Error) {
    errors?.report(err);
    logger.error({err}, 'Error reported');
}

export function updateHealthStatus(status: any) {
    if (!initialized) return;
    admin.firestore().collection('system').doc('health').set({
        ...status,
        lastUpdated: admin.firestore.FieldValue.serverTimestamp()
    }).catch(() => {
    });
}

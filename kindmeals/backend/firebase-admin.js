const admin = require('firebase-admin');
require('dotenv').config();

// Initialize firebase admin
if (!admin.apps.length) {
  try {
    // Check if we have a service account configuration
    if (process.env.FIREBASE_SERVICE_ACCOUNT) {
      admin.initializeApp({
        credential: admin.credential.cert(JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT)),
      });
      console.log('Firebase Admin initialized successfully with service account');
    } else if (process.env.FIREBASE_ENABLE_FALLBACK === 'true') {
      // Initialize with a minimal config in fallback mode
      admin.initializeApp({
        projectId: 'kindmeals-app',
        // This will create a minimal app without actual Firebase services
      });
      console.log('Firebase Admin initialized in fallback mode');
    } else {
      throw new Error('No Firebase configuration provided');
    }
  } catch (error) {
    console.error('Error initializing Firebase Admin:', error);
  }
}

// Special module for token verification in fallback mode
const verifyToken = async (token) => {
  if (process.env.FIREBASE_ENABLE_FALLBACK === 'true') {
    // In fallback mode, assume the token is the UID directly
    // This is for development only!
    return { uid: token };
  } else {
    // In normal mode, verify the token properly
    return await admin.auth().verifyIdToken(token);
  }
};

module.exports = { admin, verifyToken }; 
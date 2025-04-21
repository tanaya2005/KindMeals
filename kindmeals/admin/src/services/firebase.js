import { initializeApp } from 'firebase/app';
import { 
  getAuth, 
  signInWithEmailAndPassword, 
  signOut as firebaseSignOut,
  onAuthStateChanged,
  connectAuthEmulator
} from 'firebase/auth';

// Your web app's Firebase configuration from environment variables
const firebaseConfig = {
  apiKey: process.env.REACT_APP_FIREBASE_API_KEY,
  authDomain: process.env.REACT_APP_FIREBASE_AUTH_DOMAIN,
  projectId: process.env.REACT_APP_FIREBASE_PROJECT_ID,
  storageBucket: process.env.REACT_APP_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: process.env.REACT_APP_FIREBASE_MESSAGING_SENDER_ID,
  appId: process.env.REACT_APP_FIREBASE_APP_ID
};

let auth = null;
let firebaseInitialized = false;

// Check if all required Firebase config values are present
const isFirebaseConfigValid = () => {
  const requiredFields = ['apiKey', 'authDomain', 'projectId'];
  return requiredFields.every(field => firebaseConfig[field]);
};

try {
  if (isFirebaseConfigValid()) {
    // Initialize Firebase app
    console.log('Initializing Firebase with valid configuration');
    const app = initializeApp(firebaseConfig);
    
    // Initialize Firebase authentication
    auth = getAuth(app);
    
    // Connect to auth emulator in development if needed
    if (process.env.NODE_ENV === 'development' && process.env.REACT_APP_USE_AUTH_EMULATOR) {
      connectAuthEmulator(auth, 'http://localhost:9099');
      console.log('Connected to Firebase Auth Emulator');
    }
    
    firebaseInitialized = true;
    console.log('Firebase initialized successfully');
  } else {
    console.warn('Invalid Firebase configuration. Missing required fields.');
  }
} catch (error) {
  console.error('Error initializing Firebase:', error);
}

// Sign in with email and password
export const signIn = async (email, password) => {
  if (!firebaseInitialized) {
    throw new Error('Firebase not initialized. Please check your configuration.');
  }
  
  try {
    return await signInWithEmailAndPassword(auth, email, password);
  } catch (error) {
    console.error('Firebase sign in error:', error.code, error.message);
    
    // Enhance error information
    switch(error.code) {
      case 'auth/invalid-email':
        throw new Error('Invalid email format.');
      case 'auth/user-disabled':
        throw new Error('This account has been disabled.');
      case 'auth/user-not-found':
        throw new Error('Admin account not found.');
      case 'auth/wrong-password':
        throw new Error('Incorrect password.');
      default:
        throw error;
    }
  }
};

// Sign out
export const signOut = async () => {
  if (!firebaseInitialized) {
    console.warn('Firebase not initialized, skipping sign out');
    return;
  }
  return await firebaseSignOut(auth);
};

// Get current user
export const getCurrentUser = () => {
  if (!firebaseInitialized) {
    return null;
  }
  return auth.currentUser;
};

// Get ID token
export const getIdToken = async (user, forceRefresh = false) => {
  if (!firebaseInitialized) {
    throw new Error('Firebase not initialized. Please check your configuration.');
  }
  
  const userObj = user || auth.currentUser;
  if (!userObj) {
    throw new Error('No user signed in');
  }
  
  return await userObj.getIdToken(forceRefresh);
};

// Listen for authentication state changes
export const onAuthStateChange = (callback) => {
  if (!firebaseInitialized) {
    console.warn('Firebase not initialized, auth state changes will not be monitored');
    return () => {}; // Return empty unsubscribe function
  }
  return onAuthStateChanged(auth, callback);
};

export default auth; 
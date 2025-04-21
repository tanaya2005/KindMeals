import { signIn, signOut, getCurrentUser, getIdToken, onAuthStateChange } from './firebase';
import { adminLogin } from './api';

// Login function
export const login = async (email, password) => {
  // Validate if the email is the admin email
  if (email !== 'admin@kindmeals.in') {
    console.warn('Invalid admin email attempted:', email);
    throw new Error('Invalid admin credentials. Please use the correct admin email.');
  }

  try {
    // First authenticate with Firebase
    const userCredential = await signIn(email, password);
    const user = userCredential.user;
    
    // Get the ID token from Firebase
    const idToken = await getIdToken(user);
    
    // Then authenticate with backend
    try {
      const adminData = await adminLogin({ idToken });
      
      // Store authentication data
      localStorage.setItem('adminToken', adminData.token || idToken);
      localStorage.setItem('adminUser', JSON.stringify(adminData.user || {
        uid: user.uid,
        email: user.email,
        name: user.displayName || 'Admin User',
        role: 'admin'
      }));
      
      console.log('Admin login successful');
      return adminData.user || user;
    } catch (backendError) {
      console.error('Backend authentication failed:', backendError);
      throw new Error('Backend authentication failed. Please check server connection.');
    }
  } catch (error) {
    console.error('Login error:', error);
    
    // Check for specific Firebase errors
    if (error.code === 'auth/wrong-password') {
      throw new Error('Incorrect password. Please try again.');
    } else if (error.code === 'auth/user-not-found') {
      throw new Error('Admin account not found.');
    } else if (error.code === 'auth/too-many-requests') {
      throw new Error('Account temporarily locked due to too many failed attempts. Please try again later.');
    } else {
      throw new Error(error.message || 'Authentication failed. Please check your credentials.');
    }
  }
};

// Logout function
export const logout = async () => {
  try {
    // Sign out from Firebase
    await signOut();
  } catch (error) {
    console.error('Firebase sign out error:', error);
  } finally {
    // Always clear localStorage regardless of Firebase success
    localStorage.removeItem('adminToken');
    localStorage.removeItem('adminUser');
  }
};

// Check if a user is authenticated
export const isAuthenticated = () => {
  return !!localStorage.getItem('adminToken');
};

// Get the current admin user
export const getCurrentAdmin = () => {
  try {
    const adminUserJson = localStorage.getItem('adminUser');
    if (!adminUserJson) return null;
    
    return JSON.parse(adminUserJson);
  } catch (error) {
    console.error('Error getting current admin:', error);
    return null;
  }
};

// Refresh the admin token
export const refreshToken = async () => {
  try {
    // Get current Firebase user
    const user = getCurrentUser();
    if (!user) {
      throw new Error('No user logged in');
    }
    
    // Get a fresh token
    const newToken = await getIdToken(user, true);
    
    // Update token in localStorage
    localStorage.setItem('adminToken', newToken);
    
    return newToken;
  } catch (error) {
    console.error('Error refreshing token:', error);
    throw error;
  }
}; 
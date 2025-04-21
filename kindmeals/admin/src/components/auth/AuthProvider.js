import React, { createContext, useContext, useState, useEffect } from 'react';
import { Navigate, useLocation } from 'react-router-dom';
import { CircularProgress, Box } from '@mui/material';
import { onAuthStateChange } from '../../services/firebase';
import { isAuthenticated, getCurrentAdmin, refreshToken } from '../../services/auth';

// Create the auth context
const AuthContext = createContext(null);

// Custom hook to use the auth context
export const useAuth = () => {
  return useContext(AuthContext);
};

// Auth provider component
export const AuthProvider = ({ children }) => {
  // Create a fake admin user object
  const fakeAdmin = {
    uid: "admin-bypass-id",
    email: "admin@kindmeals.in",
    role: "admin"
  };
  
  const [currentUser, setCurrentUser] = useState(fakeAdmin);
  const [loading, setLoading] = useState(false);

  // Store the fake admin in localStorage to bypass authentication checks
  useEffect(() => {
    localStorage.setItem('adminUser', JSON.stringify(fakeAdmin));
    localStorage.setItem('adminToken', 'bypass-token-for-development');
    setLoading(false);
  }, []);

  // Provide authentication value
  const value = {
    currentUser,
    isAuthenticated: true // Always authenticated
  };

  return (
    <AuthContext.Provider value={value}>
      {loading ? (
        <Box
          sx={{
            display: 'flex',
            justifyContent: 'center',
            alignItems: 'center',
            height: '100vh'
          }}
        >
          <CircularProgress />
        </Box>
      ) : (
        children
      )}
    </AuthContext.Provider>
  );
};

// Protected route component - modified to always allow access
export const ProtectedRoute = ({ children }) => {
  return children; // Always render children, bypassing authentication check
}; 
import React, { useEffect, useState } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { ThemeProvider, createTheme } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import Layout from './components/layout/Layout';
import Dashboard from './pages/Dashboard';
import Donors from './pages/Donors';
import Recipients from './pages/Recipients';
import Volunteers from './pages/Volunteers';
import Donations from './pages/Donations';
import Settings from './pages/Settings';
import Login from './pages/Login';
import { isAuthenticated } from './services/auth';
import { Box, CircularProgress } from '@mui/material';

// Create a theme instance
const theme = createTheme({
  palette: {
    primary: {
      main: '#4CAF50', // Green - matches KindMeals brand
    },
    secondary: {
      main: '#FF5722', // Orange
    },
  },
});

// Protected route component
const ProtectedRoute = ({ children }) => {
  if (!isAuthenticated()) {
    // Redirect to login page with return url
    return <Navigate to="/login" replace />;
  }
  return children;
};

// Public route component (accessible only when not authenticated)
const PublicRoute = ({ children }) => {
  if (isAuthenticated()) {
    // Redirect to dashboard if already authenticated
    return <Navigate to="/dashboard" replace />;
  }
  return children;
};

function App() {
  const [loading, setLoading] = useState(true);

  // Add a small delay to allow checking authentication status
  useEffect(() => {
    const timer = setTimeout(() => {
      setLoading(false);
    }, 500);
    return () => clearTimeout(timer);
  }, []);

  if (loading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100vh' }}>
        <CircularProgress />
      </Box>
    );
  }

  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <Router>
        <Routes>
          {/* Public Routes */}
          <Route 
            path="/login" 
            element={
              <PublicRoute>
                <Login />
              </PublicRoute>
            } 
          />
          
          {/* Protected Routes */}
          <Route 
            path="/" 
            element={
              <ProtectedRoute>
                <Layout />
              </ProtectedRoute>
            }
          >
            <Route index element={<Navigate to="/dashboard" replace />} />
            <Route path="dashboard" element={<Dashboard />} />
            <Route path="donors" element={<Donors />} />
            <Route path="recipients" element={<Recipients />} />
            <Route path="volunteers" element={<Volunteers />} />
            <Route path="donations" element={<Donations />} />
            <Route path="settings" element={<Settings />} />
          </Route>
          
          {/* Fallback Route */}
          <Route path="*" element={<Navigate to="/login" replace />} />
        </Routes>
      </Router>
    </ThemeProvider>
  );
}

export default App; 
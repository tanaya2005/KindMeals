import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Box,
  Container,
  Paper,
  Typography,
  TextField,
  Button,
  Alert,
  CircularProgress,
  Grid,
  Divider,
  Link
} from '@mui/material';
import { login } from '../services/auth';
import { checkServerStatus } from '../services/api';

const Login = () => {
  const [email, setEmail] = useState('admin@kindmeals.in');
  const [password, setPassword] = useState('kindmeals123');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [serverStatus, setServerStatus] = useState({ checking: true, online: false, message: 'Checking server status...' });
  const navigate = useNavigate();

  useEffect(() => {
    const checkServer = async () => {
      try {
        const status = await checkServerStatus();
        setServerStatus({ 
          checking: false, 
          online: status.online, 
          message: status.message
        });
      } catch (error) {
        setServerStatus({ 
          checking: false, 
          online: false, 
          message: 'Error connecting to server: ' + (error.message || 'Unknown error')
        });
      }
    };
    
    checkServer();
  }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    
    try {
      await login(email, password);
      navigate('/dashboard');
    } catch (err) {
      console.error('Login error:', err);
      setError(err.message || 'Failed to login. Please check your credentials.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Container maxWidth="sm" sx={{ height: '100vh', display: 'flex', alignItems: 'center' }}>
      <Paper elevation={3} sx={{ p: 4, width: '100%' }}>
        <Box sx={{ mb: 3, textAlign: 'center' }}>
          <Typography variant="h4" component="h1" gutterBottom>
            KindMeals Admin
          </Typography>
          <Typography variant="body2" color="text.secondary">
            Login to access the admin dashboard
          </Typography>
        </Box>
        
        {!serverStatus.checking && (
          <Alert severity={serverStatus.online ? "success" : "warning"} sx={{ mb: 3 }}>
            {serverStatus.message}
          </Alert>
        )}

        {error && <Alert severity="error" sx={{ mb: 3 }}>{error}</Alert>}
        
        <Box component="form" onSubmit={handleSubmit}>
          <TextField
            margin="normal"
            required
            fullWidth
            id="email"
            label="Email Address"
            name="email"
            autoComplete="email"
            autoFocus
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            disabled={loading}
          />
          <TextField
            margin="normal"
            required
            fullWidth
            name="password"
            label="Password"
            type="password"
            id="password"
            autoComplete="current-password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            disabled={loading}
          />
          <Button
            type="submit"
            fullWidth
            variant="contained"
            sx={{ mt: 3, mb: 2 }}
            disabled={loading}
          >
            {loading ? <CircularProgress size={24} /> : 'Sign In'}
          </Button>
        </Box>
        
        <Divider sx={{ my: 3 }} />
        
        <Box sx={{ mt: 2 }}>
          <Typography variant="body2" color="text.secondary" align="center">
            Admin Email: admin@kindmeals.in
          </Typography>
          <Typography variant="body2" color="text.secondary" align="center" sx={{ mt: 1 }}>
            Default Password: kindmeals123
          </Typography>
          <Typography variant="body2" color="text.secondary" align="center" sx={{ mt: 2 }}>
            Note: This is a test account for demonstration purposes.
          </Typography>
        </Box>
      </Paper>
    </Container>
  );
};

export default Login; 
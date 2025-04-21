import axios from 'axios';

// Base configuration for API requests
const API = axios.create({
  baseURL: process.env.REACT_APP_API_URL || 'https://kindmeals-eid0.onrender.com', // Use remote server by default
  timeout: 15000, // Increase timeout for slower connections
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  }
});

// Add authorization token to requests if available
API.interceptors.request.use(config => {
  const token = localStorage.getItem('adminToken');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  
  // Log requests in development
  if (process.env.NODE_ENV === 'development') {
    console.log(`Making ${config.method.toUpperCase()} request to ${config.url}`);
  }
  
  return config;
}, error => {
  console.error('Request error:', error);
  return Promise.reject(error);
});

// Add response interceptor for better error handling
API.interceptors.response.use(
  response => {
    return response;
  },
  error => {
    // Handle token expiration
    if (error.response && error.response.status === 401) {
      console.error('Authentication error. Token may be expired.');
      // Could trigger token refresh here if needed
    }
    
    // Log detailed error information
    console.error('API Error:', {
      status: error.response?.status,
      url: error.config?.url,
      method: error.config?.method,
      message: error.message,
      responseData: error.response?.data
    });
    
    return Promise.reject(error);
  }
);

// User management
export const getAllUsers = async () => {
  const response = await API.get('/admin/users');
  return response.data;
};

export const getDonors = async () => {
  console.log('Fetching donors...');
  try {
    const response = await API.get('/admin/donors');
    console.log('Donors fetched successfully:', response.data.length);
    return response.data;
  } catch (error) {
    console.error('Error fetching donors:', error);
    
    // Try alternative endpoint
    console.log('Trying alternative endpoint for donors...');
    const altResponse = await API.get('/api/admin/donors');
    console.log('Donors fetched from alternative endpoint:', altResponse.data.length);
    return altResponse.data;
  }
};

export const getRecipients = async () => {
  console.log('Fetching recipients...');
  try {
    const response = await API.get('/admin/recipients');
    console.log('Recipients fetched successfully:', response.data.length);
    return response.data;
  } catch (error) {
    console.error('Error fetching recipients:', error);
    
    // Try alternative endpoint
    console.log('Trying alternative endpoint for recipients...');
    const altResponse = await API.get('/api/admin/recipients');
    console.log('Recipients fetched from alternative endpoint:', altResponse.data.length);
    return altResponse.data;
  }
};

export const getVolunteers = async () => {
  console.log('Fetching volunteers...');
  try {
    const response = await API.get('/admin/volunteers');
    console.log('Volunteers fetched successfully:', response.data.length);
    return response.data;
  } catch (error) {
    console.error('Error fetching volunteers:', error);
    
    // Try alternative endpoint
    console.log('Trying alternative endpoint for volunteers...');
    const altResponse = await API.get('/api/admin/volunteers');
    console.log('Volunteers fetched from alternative endpoint:', altResponse.data.length);
    return altResponse.data;
  }
};

// Donation management
export const getDonations = async () => {
  console.log('Fetching all donations...');
  try {
    const response = await API.get('/admin/donations');
    console.log('Donations fetched successfully:', response.data.length);
    return response.data;
  } catch (error) {
    console.error('Error getting donations:', error);
    
    // Try combining individual donation endpoints
    console.log('Trying to fetch donations from individual endpoints...');
    const [liveDonations, acceptedDonations, expiredDonations] = await Promise.all([
      getLiveDonations(),
      getAcceptedDonations(),
      getExpiredDonations()
    ]);
    
    const combinedDonations = [
      ...liveDonations.map(d => ({ ...d, status: 'live' })),
      ...acceptedDonations.map(d => ({ ...d, status: 'accepted' })),
      ...expiredDonations.map(d => ({ ...d, status: 'expired' }))
    ];
    
    console.log('Combined donations from individual endpoints:', combinedDonations.length);
    return combinedDonations;
  }
};

export const getLiveDonations = async () => {
  const response = await API.get('/admin/donations/live');
  return response.data;
};

export const getAcceptedDonations = async () => {
  const response = await API.get('/admin/donations/accepted');
  return response.data;
};

export const getExpiredDonations = async () => {
  const response = await API.get('/admin/donations/expired');
  return response.data;
};

// Dashboard statistics
export const getDashboardStats = async () => {
  const response = await API.get('/admin/dashboard/stats');
  return response.data;
};

export const getRecentActivity = async () => {
  const response = await API.get('/admin/dashboard/activity');
  return response.data;
};

// Admin authentication
export const adminLogin = async (credentials) => {
  const response = await API.post('/admin/login', credentials);
  if (response.data.token) {
    localStorage.setItem('adminToken', response.data.token);
  }
  return response.data;
};

export const adminLogout = () => {
  localStorage.removeItem('adminToken');
};

// Check if the backend server is reachable
export const checkServerStatus = async () => {
  const response = await API.get('/');
  console.log('Server status check:', response.data);
  return {
    online: true,
    message: response.data.message || 'Server is online'
  };
};

export default API; 
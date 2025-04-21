import React, { useState, useEffect } from 'react';
import {
  Box,
  Typography,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  TablePagination,
  Chip,
  IconButton,
  TextField,
  InputAdornment,
  CircularProgress,
  Alert,
  Rating,
  Stack,
  Button
} from '@mui/material';
import SearchIcon from '@mui/icons-material/Search';
import VisibilityIcon from '@mui/icons-material/Visibility';
import EditIcon from '@mui/icons-material/Edit';
import DirectionsCarIcon from '@mui/icons-material/DirectionsCar';
import DirectionsBikeIcon from '@mui/icons-material/DirectionsBike';
import RefreshIcon from '@mui/icons-material/Refresh';
import { getVolunteers, checkServerStatus } from '../services/api';

const Volunteers = () => {
  const [volunteers, setVolunteers] = useState([]);
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(5);
  const [searchQuery, setSearchQuery] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [serverStatus, setServerStatus] = useState({ online: false, message: 'Checking server status...' });

  useEffect(() => {
    const checkServer = async () => {
      const status = await checkServerStatus();
      setServerStatus(status);
      
      if (status.online) {
        fetchVolunteers();
      } else {
        setLoading(false);
        setError(`Server connection error: ${status.message}`);
      }
    };
    
    const fetchVolunteers = async () => {
      try {
        setLoading(true);
        console.log('Initiating volunteer data fetch...');
        
        // Fetch volunteers data
        const data = await getVolunteers();
        console.log('Volunteer data received:', data);
        
        if (Array.isArray(data)) {
          setVolunteers(data);
          if (data.length === 0) {
            console.warn('Received an empty array of volunteers');
          }
        } else {
          console.error('Received invalid volunteer data format:', data);
          setError('Received invalid data format from server');
          setVolunteers([]);
        }
      } catch (err) {
        console.error('Error in volunteer data fetching process:', err);
        setError('Failed to load volunteers. Please try again later.');
        setVolunteers([]);
      } finally {
        setLoading(false);
      }
    };

    checkServer();
  }, []);

  // Filter volunteers based on search query
  const filteredVolunteers = volunteers.filter(volunteer =>
    volunteer.volunteerName?.toLowerCase().includes(searchQuery.toLowerCase()) ||
    volunteer.email?.toLowerCase().includes(searchQuery.toLowerCase()) ||
    volunteer.volunteercontact?.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const handleChangePage = (event, newPage) => {
    setPage(newPage);
  };

  const handleChangeRowsPerPage = (event) => {
    setRowsPerPage(parseInt(event.target.value, 10));
    setPage(0);
  };

  const handleSearchChange = (event) => {
    setSearchQuery(event.target.value);
    setPage(0);
  };

  // Add a refresh function
  const handleRefresh = async () => {
    setLoading(true);
    setError(null);
    const status = await checkServerStatus();
    setServerStatus(status);
    
    if (status.online) {
      try {
        const data = await getVolunteers();
        if (Array.isArray(data)) {
          setVolunteers(data);
        } else {
          setError('Received invalid data format from server');
          setVolunteers([]);
        }
      } catch (err) {
        setError('Failed to refresh volunteer data');
        console.error(err);
      }
    } else {
      setError(`Cannot refresh: ${status.message}`);
    }
    
    setLoading(false);
  };

  return (
    <Box>
      <Typography variant="h4" gutterBottom>
        Volunteers
      </Typography>

      <Box sx={{ mb: 3, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <Box>
          <Chip 
            label={serverStatus.online ? 'Server Connected' : 'Server Offline'} 
            color={serverStatus.online ? 'success' : 'error'}
            size="small"
            sx={{ mr: 1 }}
          />
          <Button 
            size="small" 
            startIcon={<RefreshIcon />} 
            onClick={handleRefresh}
            disabled={loading}
            variant="outlined"
          >
            Refresh
          </Button>
        </Box>
        <TextField
          placeholder="Search volunteers..."
          variant="outlined"
          size="small"
          value={searchQuery}
          onChange={handleSearchChange}
          InputProps={{
            startAdornment: (
              <InputAdornment position="start">
                <SearchIcon />
              </InputAdornment>
            ),
          }}
          sx={{ width: 300 }}
        />
      </Box>

      {loading ? (
        <Box sx={{ display: 'flex', justifyContent: 'center', my: 4 }}>
          <CircularProgress />
        </Box>
      ) : error ? (
        <Alert severity="error" sx={{ mb: 3 }}>{error}</Alert>
      ) : (
        <TableContainer component={Paper}>
          <Table sx={{ minWidth: 650 }} aria-label="volunteers table">
            <TableHead>
              <TableRow>
                <TableCell>Name</TableCell>
                <TableCell>Email</TableCell>
                <TableCell>Contact</TableCell>
                <TableCell>Rating</TableCell>
                <TableCell>Deliveries</TableCell>
                <TableCell>Vehicle</TableCell>
                <TableCell align="center">Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {filteredVolunteers.length > 0 ? (
                filteredVolunteers
                  .slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage)
                  .map((volunteer) => (
                    <TableRow key={volunteer._id || volunteer.id} hover>
                      <TableCell component="th" scope="row">
                        {volunteer.volunteerName}
                      </TableCell>
                      <TableCell>{volunteer.email}</TableCell>
                      <TableCell>{volunteer.volunteercontact}</TableCell>
                      <TableCell>
                        <Stack direction="row" alignItems="center" spacing={1}>
                          <Rating 
                            value={volunteer.rating || 0} 
                            readOnly 
                            precision={0.5} 
                            size="small" 
                          />
                          <Typography variant="body2" color="text.secondary">
                            ({volunteer.totalRatings || 0})
                          </Typography>
                        </Stack>
                      </TableCell>
                      <TableCell>{volunteer.deliveries || 0}</TableCell>
                      <TableCell>
                        {volunteer.hasVehicle ? (
                          <Chip
                            icon={volunteer.vehicleDetails?.vehicleType === 'bike' ? <DirectionsBikeIcon /> : <DirectionsCarIcon />}
                            label={volunteer.vehicleDetails?.vehicleType || 'Yes'}
                            color="success"
                            size="small"
                          />
                        ) : (
                          <Chip label="No" size="small" />
                        )}
                      </TableCell>
                      <TableCell align="center">
                        <IconButton size="small" color="primary">
                          <VisibilityIcon />
                        </IconButton>
                        <IconButton size="small" color="primary">
                          <EditIcon />
                        </IconButton>
                      </TableCell>
                    </TableRow>
                  ))
              ) : (
                <TableRow>
                  <TableCell colSpan={7} align="center">
                    {searchQuery ? 'No volunteers found matching your search' : 'No volunteers available'}
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
          <TablePagination
            rowsPerPageOptions={[5, 10, 25]}
            component="div"
            count={filteredVolunteers.length}
            rowsPerPage={rowsPerPage}
            page={page}
            onPageChange={handleChangePage}
            onRowsPerPageChange={handleChangeRowsPerPage}
          />
        </TableContainer>
      )}
    </Box>
  );
};

export default Volunteers; 
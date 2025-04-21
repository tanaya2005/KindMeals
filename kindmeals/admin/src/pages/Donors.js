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
  Button
} from '@mui/material';
import SearchIcon from '@mui/icons-material/Search';
import VisibilityIcon from '@mui/icons-material/Visibility';
import EditIcon from '@mui/icons-material/Edit';
import RefreshIcon from '@mui/icons-material/Refresh';
import { getDonors, checkServerStatus } from '../services/api';

const Donors = () => {
  const [donors, setDonors] = useState([]);
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
        fetchDonors();
      } else {
        setLoading(false);
        setError(`Server connection error: ${status.message}`);
      }
    };
    
    const fetchDonors = async () => {
      try {
        setLoading(true);
        console.log('Initiating donors data fetch...');
        
        const data = await getDonors();
        console.log('Donors data received:', data);
        
        if (Array.isArray(data)) {
          setDonors(data);
          if (data.length === 0) {
            console.warn('Received an empty array of donors');
          }
        } else {
          console.error('Received invalid donors data format:', data);
          setError('Received invalid data format from server');
          setDonors([]);
        }
      } catch (err) {
        console.error('Error in donors data fetching process:', err);
        setError('Failed to load donors. Please try again later.');
        setDonors([]);
      } finally {
        setLoading(false);
      }
    };

    checkServer();
  }, []);

  // Add a refresh function
  const handleRefresh = async () => {
    setLoading(true);
    setError(null);
    const status = await checkServerStatus();
    setServerStatus(status);
    
    if (status.online) {
      try {
        const data = await getDonors();
        if (Array.isArray(data)) {
          setDonors(data);
        } else {
          setError('Received invalid data format from server');
          setDonors([]);
        }
      } catch (err) {
        setError('Failed to refresh donor data');
        console.error(err);
      }
    } else {
      setError(`Cannot refresh: ${status.message}`);
    }
    
    setLoading(false);
  };

  // Filter donors based on search query
  const filteredDonors = donors.filter(donor =>
    donor.donorname?.toLowerCase().includes(searchQuery.toLowerCase()) ||
    donor.orgName?.toLowerCase().includes(searchQuery.toLowerCase()) ||
    donor.email?.toLowerCase().includes(searchQuery.toLowerCase())
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

  return (
    <Box>
      <Typography variant="h4" gutterBottom>
        Donors
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
          placeholder="Search donors..."
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
          <Table sx={{ minWidth: 650 }} aria-label="donors table">
            <TableHead>
              <TableRow>
                <TableCell>Name</TableCell>
                <TableCell>Organization</TableCell>
                <TableCell>Email</TableCell>
                <TableCell>Phone</TableCell>
                <TableCell>Type</TableCell>
                <TableCell align="center">Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {filteredDonors.length > 0 ? (
                filteredDonors
                  .slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage)
                  .map((donor) => (
                    <TableRow key={donor._id || donor.id} hover>
                      <TableCell component="th" scope="row">
                        {donor.donorname}
                      </TableCell>
                      <TableCell>{donor.orgName}</TableCell>
                      <TableCell>{donor.email}</TableCell>
                      <TableCell>{donor.donorcontact}</TableCell>
                      <TableCell>
                        <Chip
                          label={donor.type}
                          color="primary"
                          size="small"
                        />
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
                  <TableCell colSpan={6} align="center">
                    {searchQuery ? 'No donors found matching your search' : 'No donors available'}
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
          <TablePagination
            rowsPerPageOptions={[5, 10, 25]}
            component="div"
            count={filteredDonors.length}
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

export default Donors; 
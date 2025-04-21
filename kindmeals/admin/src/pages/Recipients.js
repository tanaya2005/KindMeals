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
  Stack,
  Button,
  Grid,
  Card,
  CardContent,
  Avatar,
  CircularProgress,
  Alert
} from '@mui/material';
import SearchIcon from '@mui/icons-material/Search';
import VisibilityIcon from '@mui/icons-material/Visibility';
import EditIcon from '@mui/icons-material/Edit';
import DeleteIcon from '@mui/icons-material/Delete';
import AddIcon from '@mui/icons-material/Add';
import LocalDiningIcon from '@mui/icons-material/LocalDining';
import PeopleIcon from '@mui/icons-material/People';
import PlaceIcon from '@mui/icons-material/Place';
import RefreshIcon from '@mui/icons-material/Refresh';
import { getRecipients, checkServerStatus } from '../services/api';

const Recipients = () => {
  const [recipients, setRecipients] = useState([]);
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
        fetchRecipients();
      } else {
        setLoading(false);
        setError(`Server connection error: ${status.message}`);
      }
    };
    
    const fetchRecipients = async () => {
      try {
        setLoading(true);
        console.log('Initiating recipients data fetch...');
        
        const data = await getRecipients();
        console.log('Recipients data received:', data);
        
        if (Array.isArray(data)) {
          setRecipients(data);
          if (data.length === 0) {
            console.warn('Received an empty array of recipients');
          }
        } else {
          console.error('Received invalid recipients data format:', data);
          setError('Received invalid data format from server');
          setRecipients([]);
        }
      } catch (err) {
        console.error('Error in recipients data fetching process:', err);
        setError('Failed to load recipients. Please try again later.');
        setRecipients([]);
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
        const data = await getRecipients();
        if (Array.isArray(data)) {
          setRecipients(data);
        } else {
          setError('Received invalid data format from server');
          setRecipients([]);
        }
      } catch (err) {
        setError('Failed to refresh recipient data');
        console.error(err);
      }
    } else {
      setError(`Cannot refresh: ${status.message}`);
    }
    
    setLoading(false);
  };

  // Summary data calculated from fetched data
  const summaryData = {
    totalRecipients: recipients.length,
    activeRecipients: recipients.filter(r => r.reciname).length,
    // In a real implementation, this would come from the total meals received by all recipients
    totalMealsDelivered: recipients.length * 50 // Placeholder calculation
  };

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

  // Filter recipients based on search query
  const filteredRecipients = recipients.filter(recipient =>
    recipient.orgName?.toLowerCase().includes(searchQuery.toLowerCase()) ||
    recipient.contactName?.toLowerCase().includes(searchQuery.toLowerCase()) ||
    recipient.email?.toLowerCase().includes(searchQuery.toLowerCase()) ||
    recipient.type?.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <Box>
      <Typography variant="h4" gutterBottom>
        Recipients
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
          placeholder="Search recipients..."
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

      {/* Summary Cards */}
      <Grid container spacing={3} mb={3}>
        <Grid item xs={12} sm={4}>
          <Card>
            <CardContent>
              <Box display="flex" alignItems="center">
                <Avatar sx={{ bgcolor: 'primary.main', mr: 2 }}>
                  <PeopleIcon />
                </Avatar>
                <Box>
                  <Typography color="textSecondary" gutterBottom>
                    Total Recipients
                  </Typography>
                  <Typography variant="h5" component="div">
                    {summaryData.totalRecipients}
                  </Typography>
                </Box>
              </Box>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} sm={4}>
          <Card>
            <CardContent>
              <Box display="flex" alignItems="center">
                <Avatar sx={{ bgcolor: 'success.main', mr: 2 }}>
                  <LocalDiningIcon />
                </Avatar>
                <Box>
                  <Typography color="textSecondary" gutterBottom>
                    Meals Delivered
                  </Typography>
                  <Typography variant="h5" component="div">
                    {summaryData.totalMealsDelivered}
                  </Typography>
                </Box>
              </Box>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} sm={4}>
          <Card>
            <CardContent>
              <Box display="flex" alignItems="center">
                <Avatar sx={{ bgcolor: 'info.main', mr: 2 }}>
                  <PlaceIcon />
                </Avatar>
                <Box>
                  <Typography color="textSecondary" gutterBottom>
                    Active Recipients
                  </Typography>
                  <Typography variant="h5" component="div">
                    {summaryData.activeRecipients}
                  </Typography>
                </Box>
              </Box>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      {/* Recipients Table */}
      {loading ? (
        <Box sx={{ display: 'flex', justifyContent: 'center', my: 4 }}>
          <CircularProgress />
        </Box>
      ) : error ? (
        <Alert severity="error" sx={{ mb: 3 }}>{error}</Alert>
      ) : (
        <TableContainer component={Paper}>
          <Table sx={{ minWidth: 650 }} aria-label="recipients table">
            <TableHead>
              <TableRow>
                <TableCell>Organization</TableCell>
                <TableCell>Contact Person</TableCell>
                <TableCell>Email</TableCell>
                <TableCell>Phone</TableCell>
                <TableCell>Type</TableCell>
                <TableCell align="center">Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {filteredRecipients.length > 0 ? (
                filteredRecipients
                  .slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage)
                  .map((recipient) => (
                    <TableRow key={recipient._id || recipient.id} hover>
                      <TableCell component="th" scope="row">
                        {recipient.orgName}
                      </TableCell>
                      <TableCell>{recipient.contactName}</TableCell>
                      <TableCell>{recipient.email}</TableCell>
                      <TableCell>{recipient.phone}</TableCell>
                      <TableCell>
                        <Chip
                          label={recipient.type || 'Unknown'}
                          color="secondary"
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
                    {searchQuery ? 'No recipients found matching your search' : 'No recipients available'}
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
          <TablePagination
            rowsPerPageOptions={[5, 10, 25]}
            component="div"
            count={filteredRecipients.length}
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

export default Recipients; 
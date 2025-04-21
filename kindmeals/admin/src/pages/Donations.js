import React, { useState, useEffect } from 'react';
import {
  Box,
  Typography,
  Tabs,
  Tab,
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
  Grid,
  Card,
  CardContent,
  Stack,
  CircularProgress,
  Alert,
  Button
} from '@mui/material';
import SearchIcon from '@mui/icons-material/Search';
import VisibilityIcon from '@mui/icons-material/Visibility';
import DeleteIcon from '@mui/icons-material/Delete';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import RefreshIcon from '@mui/icons-material/Refresh';
import VolunteerActivismIcon from '@mui/icons-material/VolunteerActivism';
import PeopleIcon from '@mui/icons-material/People';
import AttachMoneyIcon from '@mui/icons-material/AttachMoney';
import { green, amber, blue } from '@mui/material/colors';
import { getLiveDonations, getAcceptedDonations, getExpiredDonations, getDonations, checkServerStatus } from '../services/api';

// Tab Panel component for showing different donation types
function TabPanel(props) {
  const { children, value, index, ...other } = props;

  return (
    <div
      role="tabpanel"
      hidden={value !== index}
      id={`donations-tabpanel-${index}`}
      aria-labelledby={`donations-tab-${index}`}
      {...other}
    >
      {value === index && <Box sx={{ py: 3 }}>{children}</Box>}
    </div>
  );
}

// Helper function to format date
const formatDate = (dateString) => {
  if (!dateString) return 'N/A';
  try {
    const date = new Date(dateString);
    if (isNaN(date.getTime())) return 'Invalid Date';
    return date.toLocaleDateString('en-IN', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  } catch (error) {
    console.error('Error formatting date:', error);
    return 'Error';
  }
};

const Donations = () => {
  const [tabValue, setTabValue] = useState(0);
  const [liveDonations, setLiveDonations] = useState([]);
  const [acceptedDonations, setAcceptedDonations] = useState([]);
  const [expiredDonations, setExpiredDonations] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  const [serverStatus, setServerStatus] = useState({ online: false, message: 'Checking server status...' });

  useEffect(() => {
    const checkServer = async () => {
      const status = await checkServerStatus();
      setServerStatus(status);
      
      if (status.online) {
        fetchDonations();
      } else {
        setLoading(false);
        setError(`Server connection error: ${status.message}`);
      }
    };
    
    const fetchDonations = async () => {
      try {
        setLoading(true);
        console.log('Initiating donations data fetch...');
        
        const data = await getDonations();
        console.log('Donations data received:', data);
        
        if (Array.isArray(data)) {
          setLiveDonations(data.filter(d => d.status === 'live'));
          setAcceptedDonations(data.filter(d => d.status === 'accepted'));
          setExpiredDonations(data.filter(d => d.status === 'expired'));
          if (data.length === 0) {
            console.warn('Received an empty array of donations');
          }
        } else {
          console.error('Received invalid donations data format:', data);
          setError('Received invalid data format from server');
          setLiveDonations([]);
          setAcceptedDonations([]);
          setExpiredDonations([]);
        }
      } catch (err) {
        console.error('Error in donations data fetching process:', err);
        setError('Failed to load donations. Please try again later.');
        setLiveDonations([]);
        setAcceptedDonations([]);
        setExpiredDonations([]);
      } finally {
        setLoading(false);
      }
    };

    checkServer();
  }, []);

  const handleTabChange = (event, newValue) => {
    setTabValue(newValue);
    setPage(0);
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

  // Filter donations based on search query and current tab
  const filterDonations = (donations) => {
    return donations.filter(donation =>
      donation.foodName?.toLowerCase().includes(searchQuery.toLowerCase()) ||
      donation.donorName?.toLowerCase().includes(searchQuery.toLowerCase()) ||
      donation.description?.toLowerCase().includes(searchQuery.toLowerCase())
    );
  };

  const filteredLive = filterDonations(liveDonations);
  const filteredAccepted = filterDonations(acceptedDonations);
  const filteredExpired = filterDonations(expiredDonations);

  // Get current donations based on active tab
  const getCurrentDonations = () => {
    switch (tabValue) {
      case 0:
        return filteredLive;
      case 1:
        return filteredAccepted;
      case 2:
        return filteredExpired;
      default:
        return filteredLive;
    }
  };

  // Function to safely render food type chip
  const renderFoodTypeChip = (foodType) => {
    let color = 'default';
    if (!foodType) foodType = 'Unknown';
    
    if (foodType.toLowerCase() === 'veg') color = 'success';
    if (foodType.toLowerCase() === 'nonveg') color = 'error';
    if (foodType.toLowerCase() === 'jain') color = 'primary';
    
    return (
      <Chip 
        label={foodType || 'Unknown'} 
        color={color}
        size="small"
      />
    );
  };

  // Add a refresh function
  const handleRefresh = async () => {
    setLoading(true);
    setError(null);
    const status = await checkServerStatus();
    setServerStatus(status);
    
    if (status.online) {
      try {
        const data = await getDonations();
        if (Array.isArray(data)) {
          setLiveDonations(data.filter(d => d.status === 'live'));
          setAcceptedDonations(data.filter(d => d.status === 'accepted'));
          setExpiredDonations(data.filter(d => d.status === 'expired'));
        } else {
          setError('Received invalid data format from server');
          setLiveDonations([]);
          setAcceptedDonations([]);
          setExpiredDonations([]);
        }
      } catch (err) {
        setError('Failed to refresh donation data');
        console.error(err);
      }
    } else {
      setError(`Cannot refresh: ${status.message}`);
    }
    
    setLoading(false);
  };

  // Color-coding for donation status
  const getStatusColor = (status) => {
    switch(status?.toLowerCase()) {
      case 'completed': return 'success';
      case 'pending': return 'warning';
      case 'processing': return 'info';
      case 'canceled': return 'error';
      default: return 'default';
    }
  };

  if (loading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', my: 4 }}>
        <CircularProgress />
      </Box>
    );
  }

  if (error) {
    return (
      <Box sx={{ my: 3 }}>
        <Alert severity="error">{error}</Alert>
      </Box>
    );
  }

  return (
    <Box>
      <Typography variant="h4" gutterBottom>
        Donations
      </Typography>
      
      {/* Summary Cards */}
      <Grid container spacing={3} sx={{ mb: 3 }}>
        <Grid item xs={12} sm={4}>
          <Card>
            <CardContent>
              <Stack direction="row" spacing={2} alignItems="center">
                <VolunteerActivismIcon sx={{ fontSize: 40, color: blue[500] }} />
                <Box>
                  <Typography variant="h5">{liveDonations.length + acceptedDonations.length + expiredDonations.length}</Typography>
                  <Typography variant="body2" color="text.secondary">Total Donations</Typography>
                </Box>
              </Stack>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} sm={4}>
          <Card>
            <CardContent>
              <Stack direction="row" spacing={2} alignItems="center">
                <AttachMoneyIcon sx={{ fontSize: 40, color: green[500] }} />
                <Box>
                  <Typography variant="h5">${(liveDonations.reduce((acc, item) => acc + (parseFloat(item.amount) || 0), 0) + acceptedDonations.reduce((acc, item) => acc + (parseFloat(item.amount) || 0), 0) + expiredDonations.reduce((acc, item) => acc + (parseFloat(item.amount) || 0), 0)).toFixed(2)}</Typography>
                  <Typography variant="body2" color="text.secondary">Total Amount</Typography>
                </Box>
              </Stack>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} sm={4}>
          <Card>
            <CardContent>
              <Stack direction="row" spacing={2} alignItems="center">
                <PeopleIcon sx={{ fontSize: 40, color: amber[500] }} />
                <Box>
                  <Typography variant="h5">{acceptedDonations.length}</Typography>
                  <Typography variant="body2" color="text.secondary">Completed Donations</Typography>
                </Box>
              </Stack>
            </CardContent>
          </Card>
        </Grid>
      </Grid>
      
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
          placeholder="Search donations..."
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
      
      <Box sx={{ mb: 2 }}>
        <Tabs 
          value={tabValue} 
          onChange={handleTabChange}
          variant="fullWidth"
          indicatorColor="primary"
          textColor="primary"
        >
          <Tab label={`Live (${liveDonations.length})`} />
          <Tab label={`Accepted (${acceptedDonations.length})`} />
          <Tab label={`Expired (${expiredDonations.length})`} />
        </Tabs>
      </Box>
      
      <TabPanel value={tabValue} index={0}>
        <TableContainer component={Paper}>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell>Food Item</TableCell>
                <TableCell>Donor</TableCell>
                <TableCell>Quantity</TableCell>
                <TableCell>Type</TableCell>
                <TableCell>Uploaded</TableCell>
                <TableCell>Expires</TableCell>
                <TableCell align="center">Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {filteredLive.length > 0 ? (
                filteredLive
                  .slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage)
                  .map((donation) => (
                    <TableRow key={donation._id || donation.id || Math.random().toString()} hover>
                      <TableCell>{donation.foodName}</TableCell>
                      <TableCell>{donation.donorName}</TableCell>
                      <TableCell>{donation.quantity}</TableCell>
                      <TableCell>{renderFoodTypeChip(donation.foodType)}</TableCell>
                      <TableCell>{formatDate(donation.timeOfUpload)}</TableCell>
                      <TableCell>{formatDate(donation.expiryDateTime)}</TableCell>
                      <TableCell align="center">
                        <IconButton size="small" color="primary">
                          <VisibilityIcon />
                        </IconButton>
                        <IconButton size="small" color="error">
                          <DeleteIcon />
                        </IconButton>
                      </TableCell>
                    </TableRow>
                  ))
              ) : (
                <TableRow>
                  <TableCell colSpan={7} align="center">
                    {searchQuery ? 'No live donations found matching your search' : 'No live donations available'}
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
          <TablePagination
            rowsPerPageOptions={[5, 10, 25]}
            component="div"
            count={filteredLive.length}
            rowsPerPage={rowsPerPage}
            page={page}
            onPageChange={handleChangePage}
            onRowsPerPageChange={handleChangeRowsPerPage}
          />
        </TableContainer>
      </TabPanel>
      
      <TabPanel value={tabValue} index={1}>
        <TableContainer component={Paper}>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell>Food Item</TableCell>
                <TableCell>Donor</TableCell>
                <TableCell>Recipient</TableCell>
                <TableCell>Quantity</TableCell>
                <TableCell>Type</TableCell>
                <TableCell>Accepted At</TableCell>
                <TableCell align="center">Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {filteredAccepted.length > 0 ? (
                filteredAccepted
                  .slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage)
                  .map((donation) => (
                    <TableRow key={donation._id || donation.id || Math.random().toString()} hover>
                      <TableCell>{donation.foodName}</TableCell>
                      <TableCell>{donation.donorName}</TableCell>
                      <TableCell>{donation.recipientName}</TableCell>
                      <TableCell>{donation.quantity}</TableCell>
                      <TableCell>{renderFoodTypeChip(donation.foodType)}</TableCell>
                      <TableCell>{formatDate(donation.acceptedAt)}</TableCell>
                      <TableCell align="center">
                        <IconButton size="small" color="primary">
                          <VisibilityIcon />
                        </IconButton>
                        <IconButton size="small" color="success">
                          <CheckCircleIcon />
                        </IconButton>
                      </TableCell>
                    </TableRow>
                  ))
              ) : (
                <TableRow>
                  <TableCell colSpan={7} align="center">
                    {searchQuery ? 'No accepted donations found matching your search' : 'No accepted donations available'}
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
          <TablePagination
            rowsPerPageOptions={[5, 10, 25]}
            component="div"
            count={filteredAccepted.length}
            rowsPerPage={rowsPerPage}
            page={page}
            onPageChange={handleChangePage}
            onRowsPerPageChange={handleChangeRowsPerPage}
          />
        </TableContainer>
      </TabPanel>
      
      <TabPanel value={tabValue} index={2}>
        <TableContainer component={Paper}>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell>Food Item</TableCell>
                <TableCell>Donor</TableCell>
                <TableCell>Quantity</TableCell>
                <TableCell>Type</TableCell>
                <TableCell>Uploaded At</TableCell>
                <TableCell>Expired At</TableCell>
                <TableCell align="center">Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {filteredExpired.length > 0 ? (
                filteredExpired
                  .slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage)
                  .map((donation) => (
                    <TableRow key={donation._id || donation.id || Math.random().toString()} hover>
                      <TableCell>{donation.foodName}</TableCell>
                      <TableCell>{donation.donorName}</TableCell>
                      <TableCell>{donation.quantity}</TableCell>
                      <TableCell>{renderFoodTypeChip(donation.foodType)}</TableCell>
                      <TableCell>{formatDate(donation.timeOfUpload)}</TableCell>
                      <TableCell>{formatDate(donation.expiredAt || donation.expiryDateTime)}</TableCell>
                      <TableCell align="center">
                        <IconButton size="small" color="primary">
                          <VisibilityIcon />
                        </IconButton>
                        <IconButton size="small" color="error">
                          <DeleteIcon />
                        </IconButton>
                      </TableCell>
                    </TableRow>
                  ))
              ) : (
                <TableRow>
                  <TableCell colSpan={7} align="center">
                    {searchQuery ? 'No expired donations found matching your search' : 'No expired donations available'}
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
          <TablePagination
            rowsPerPageOptions={[5, 10, 25]}
            component="div"
            count={filteredExpired.length}
            rowsPerPage={rowsPerPage}
            page={page}
            onPageChange={handleChangePage}
            onRowsPerPageChange={handleChangeRowsPerPage}
          />
        </TableContainer>
      </TabPanel>
    </Box>
  );
};

export default Donations; 
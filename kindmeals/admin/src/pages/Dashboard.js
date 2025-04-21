import React, { useState, useEffect } from 'react';
import {
  Box,
  Typography,
  Grid,
  Paper,
  Card,
  CardContent,
  CardHeader,
  Divider,
  Stack,
  Avatar,
  List,
  ListItem,
  ListItemAvatar,
  ListItemText,
  ListItemIcon,
  CircularProgress,
  Alert,
  IconButton,
  Button,
  Chip,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  alpha
} from '@mui/material';
import RestaurantIcon from '@mui/icons-material/Restaurant';
import PeopleAltIcon from '@mui/icons-material/PeopleAlt';
import VolunteerActivismIcon from '@mui/icons-material/VolunteerActivism';
import TrendingUpIcon from '@mui/icons-material/TrendingUp';
import LocalShippingIcon from '@mui/icons-material/LocalShipping';
import AutoGraphIcon from '@mui/icons-material/AutoGraph';
import { getDashboardStats, getRecentActivity, getDonors, getRecipients, getStats, checkServerStatus } from '../services/api';
import {
  People as PeopleIcon,
  Business as BusinessIcon,
  LocalDining as FoodIcon,
  Refresh as RefreshIcon,
  GroupAdd as GroupAddIcon,
  MonetizationOn as MonetizationOnIcon,
  Login as LoginIcon,
  PersonAdd as PersonAddIcon,
  Circle as CircleIcon
} from '@mui/icons-material';
import { green, red, blue, orange, purple, amber } from '@mui/material/colors';
import { alpha as alphaStyles } from '@mui/material/styles';
import ReactApexChart from 'react-apexcharts';

const Dashboard = () => {
  const [stats, setStats] = useState({
    totalMeals: 0,
    totalDonors: 0,
    totalRecipients: 0,
    mealsThisMonth: 0,
    growthRate: 0,
    pendingDeliveries: 0,
    totalDonations: 0,
    totalAmount: 0,
    recentDonations: [],
    donationsByMonth: []
  });
  
  const [recentActivities, setRecentActivities] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [serverStatus, setServerStatus] = useState({ online: false, message: 'Checking server status...' });

  useEffect(() => {
    const fetchDashboardData = async () => {
      try {
        setLoading(true);
        
        // Fetch real data from the backend
        const [donors, recipients, dashboardStats, recentActivity] = await Promise.all([
          getDonors(),
          getRecipients(),
          getDashboardStats(),
          getRecentActivity()
        ]);
        
        setStats({
          totalMeals: dashboardStats.totalMeals,
          totalDonors: dashboardStats.totalDonors || donors.length,
          totalRecipients: dashboardStats.totalRecipients || recipients.length,
          mealsThisMonth: dashboardStats.mealsThisMonth,
          growthRate: dashboardStats.growthRate,
          pendingDeliveries: dashboardStats.pendingDeliveries,
          totalDonations: dashboardStats.totalDonations,
          totalAmount: dashboardStats.totalAmount,
          donationsByMonth: dashboardStats.donationsByMonth,
          recentDonations: dashboardStats.recentDonations
        });
        
        setRecentActivities(recentActivity);
        setError(null);
      } catch (err) {
        console.error('Error fetching dashboard data:', err);
        setError('Failed to load dashboard data. Please try again later.');
      } finally {
        setLoading(false);
      }
    };

    const checkServer = async () => {
      const status = await checkServerStatus();
      setServerStatus(status);
      
      if (status.online) {
        fetchDashboardData();
      } else {
        setLoading(false);
        setError(`Server connection error: ${status.message}`);
      }
    };

    checkServer();
  }, []);

  const handleRefresh = async () => {
    setLoading(true);
    setError(null);
    const status = await checkServerStatus();
    setServerStatus(status);
    
    if (status.online) {
      try {
        const dashboardStats = await getDashboardStats();
        const activities = await getRecentActivity();
        const donors = await getDonors();
        const recipients = await getRecipients();
        
        setRecentActivities(activities);
        
        setStats({
          totalMeals: dashboardStats.totalMeals,
          totalDonors: dashboardStats.totalDonors || donors.length,
          totalRecipients: dashboardStats.totalRecipients || recipients.length,
          mealsThisMonth: dashboardStats.mealsThisMonth,
          growthRate: dashboardStats.growthRate,
          pendingDeliveries: dashboardStats.pendingDeliveries,
          totalDonations: dashboardStats.totalDonations,
          totalAmount: dashboardStats.totalAmount,
          donationsByMonth: dashboardStats.donationsByMonth,
          recentDonations: dashboardStats.recentDonations
        });
      } catch (err) {
        console.error('Error refreshing dashboard data:', err);
        setError('Failed to refresh dashboard data');
      } finally {
        setLoading(false);
      }
    } else {
      setError(`Cannot refresh: ${status.message}`);
      setLoading(false);
    }
  };

  // Donation history chart configuration
  const donationChartOptions = {
    chart: {
      type: 'area',
      height: 350,
      toolbar: {
        show: false
      }
    },
    dataLabels: {
      enabled: false
    },
    stroke: {
      curve: 'smooth',
      width: 2
    },
    xaxis: {
      categories: stats.donationsByMonth?.map(item => item.month) || [],
      labels: {
        style: {
          colors: '#777'
        }
      }
    },
    yaxis: {
      labels: {
        style: {
          colors: '#777'
        }
      }
    },
    tooltip: {
      y: {
        formatter: function (val) {
          return "$" + val.toFixed(2);
        }
      }
    },
    colors: [blue[500]]
  };

  const donationChartSeries = [
    {
      name: 'Donations',
      data: stats.donationsByMonth?.map(item => item.amount) || []
    }
  ];

  if (loading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '80vh' }}>
        <CircularProgress />
      </Box>
    );
  }

  return (
    <Box>
      <Box sx={{ mb: 3, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <Typography variant="h4">Dashboard</Typography>
        <Stack direction="row" spacing={1} alignItems="center">
          <Chip 
            label={serverStatus.online ? 'Server Connected' : 'Server Offline'} 
            color={serverStatus.online ? 'success' : 'error'}
            size="small"
          />
          <Button 
            startIcon={<RefreshIcon />} 
            onClick={handleRefresh} 
            disabled={loading}
            variant="outlined"
            size="small"
          >
            Refresh
          </Button>
        </Stack>
      </Box>

      {error && (
        <Alert severity="error" sx={{ mb: 3 }}>
          {error}
        </Alert>
      )}

      {/* Stats Cards */}
      <Grid container spacing={3} sx={{ mb: 4 }}>
        <Grid item xs={12} sm={6} md={4}>
          <StatCard 
            title="Total Donors"
            value={stats.totalDonors}
            icon={<PeopleAltIcon />}
            color={green[500]}
          />
        </Grid>
        <Grid item xs={12} sm={6} md={4}>
          <StatCard 
            title="Total Recipients"
            value={stats.totalRecipients}
            icon={<GroupAddIcon />}
            color={blue[500]}
          />
        </Grid>
        <Grid item xs={12} sm={6} md={4}>
          <StatCard 
            title="Meals This Month"
            value={stats.mealsThisMonth}
            icon={<RestaurantIcon />}
            color={orange[500]}
          />
        </Grid>
        <Grid item xs={12} sm={6} md={4}>
          <StatCard 
            title="Growth Rate"
            value={`${stats.growthRate}%`}
            icon={<TrendingUpIcon />}
            color={purple[500]}
          />
        </Grid>
        <Grid item xs={12} sm={6} md={4}>
          <StatCard 
            title="Pending Deliveries"
            value={stats.pendingDeliveries}
            icon={<LocalShippingIcon />}
            color={amber[700]}
          />
        </Grid>
        <Grid item xs={12} sm={6} md={4}>
          <StatCard 
            title="Total Donations"
            value={stats.totalDonations}
            suffix={`($${stats.totalAmount?.toLocaleString()})`}
            icon={<MonetizationOnIcon />}
            color={green[700]}
          />
        </Grid>
      </Grid>

      {/* Charts & Tables Section */}
      <Grid container spacing={3}>
        {/* Donation History Chart */}
        <Grid item xs={12} md={8}>
          <Paper sx={{ p: 3, height: '100%' }}>
            <Typography variant="h6" gutterBottom>Donation History</Typography>
            <Box sx={{ height: 350 }}>
              <ReactApexChart 
                options={donationChartOptions} 
                series={donationChartSeries} 
                type="area" 
                height={350} 
              />
            </Box>
          </Paper>
          </Grid>

        {/* Recent Activities */}
        <Grid item xs={12} md={4}>
          <Paper sx={{ p: 3, height: '100%' }}>
            <Typography variant="h6" gutterBottom>Recent Activity</Typography>
            <List>
              {recentActivities.map((activity, index) => (
                <Box key={index}>
                  <ListItem disablePadding sx={{ py: 1 }}>
                    <ListItemIcon sx={{ minWidth: 40 }}>
                      {getActivityIcon(activity.type)}
                    </ListItemIcon>
                    <ListItemText 
                      primary={activity.description}
                      secondary={new Date(activity.timestamp).toLocaleString()}
                    />
                  </ListItem>
                  {index < recentActivities.length - 1 && <Divider />}
                </Box>
              ))}
            </List>
          </Paper>
        </Grid>

        {/* Recent Donations */}
        <Grid item xs={12}>
          <Paper sx={{ p: 3, mt: 2 }}>
            <Typography variant="h6" gutterBottom>Recent Donations</Typography>
            <TableContainer>
              <Table>
                <TableHead>
                  <TableRow>
                    <TableCell>Donor</TableCell>
                    <TableCell>Recipient</TableCell>
                    <TableCell>Date</TableCell>
                    <TableCell align="right">Amount</TableCell>
                    <TableCell>Status</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {stats.recentDonations.map((donation, index) => (
                    <TableRow key={index}>
                      <TableCell>{donation.donor}</TableCell>
                      <TableCell>{donation.recipient}</TableCell>
                      <TableCell>{new Date(donation.date).toLocaleDateString()}</TableCell>
                      <TableCell align="right">${donation.amount.toFixed(2)}</TableCell>
                      <TableCell>
                        <Chip 
                          size="small" 
                          label={donation.status} 
                          color={
                            donation.status === 'Completed' ? 'success' : 
                            donation.status === 'Pending' ? 'warning' : 'default'
                          }
                        />
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </TableContainer>
          </Paper>
        </Grid>
      </Grid>
    </Box>
  );
};

// Statistic Card Component
function StatCard({ title, value, icon, color, suffix }) {
  return (
    <Paper sx={{ p: 3, height: '100%' }}>
      <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <Box>
          <Typography variant="subtitle2" color="text.secondary" gutterBottom>
            {title}
          </Typography>
          <Typography variant="h5" component="div" sx={{ fontWeight: 'bold' }}>
            {value} {suffix && <Typography variant="body2" component="span" color="text.secondary">{suffix}</Typography>}
          </Typography>
        </Box>
        <Avatar sx={{ bgcolor: alphaStyles(color, 0.1), color: color }}>
          {icon}
        </Avatar>
      </Box>
    </Paper>
  );
}

// Helper function to get icon based on activity type
function getActivityIcon(type) {
  switch (type) {
    case 'donation':
      return <MonetizationOnIcon color="success" />;
    case 'login':
      return <LoginIcon color="info" />;
    case 'signup':
      return <PersonAddIcon color="primary" />;
    case 'delivery':
      return <LocalShippingIcon color="warning" />;
    default:
      return <CircleIcon color="disabled" />;
  }
}

export default Dashboard; 
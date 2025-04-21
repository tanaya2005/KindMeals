import VolunteerActivismIcon from '@mui/icons-material/VolunteerActivism';
import DirectionsBikeIcon from '@mui/icons-material/DirectionsBike';
import RestaurantIcon from '@mui/icons-material/Restaurant';
import SettingsIcon from '@mui/icons-material/Settings';
import AccountCircleIcon from '@mui/icons-material/AccountCircle';
import LogoutIcon from '@mui/icons-material/Logout';

import { logout, getCurrentAdmin } from '../services/auth';

const drawerWidth = 240;

const menuItems = [
  { text: 'Dashboard', icon: <DashboardIcon />, path: '/dashboard' },
  { text: 'Donors', icon: <PeopleIcon />, path: '/donors' },
  { text: 'Recipients', icon: <VolunteerActivismIcon />, path: '/recipients' },
  { text: 'Volunteers', icon: <DirectionsBikeIcon />, path: '/volunteers' },
  { text: 'Donations', icon: <RestaurantIcon />, path: '/donations' },
  { text: 'Settings', icon: <SettingsIcon />, path: '/settings' },
]; 
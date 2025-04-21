import React, { useState } from 'react';
import {
  Box,
  Typography,
  Paper,
  Grid,
  TextField,
  Button,
  Divider,
  Switch,
  FormControlLabel,
  Alert,
  Card,
  CardContent,
  CardHeader,
  Snackbar
} from '@mui/material';
import { getCurrentAdmin } from '../services/auth';

const Settings = () => {
  const admin = getCurrentAdmin();
  const [saveSuccess, setSaveSuccess] = useState(false);
  
  // Admin profile state
  const [profileData, setProfileData] = useState({
    name: admin?.name || '',
    email: admin?.email || '',
    phone: admin?.phone || '',
  });

  // App settings state
  const [appSettings, setAppSettings] = useState({
    enableEmailNotifications: true,
    enablePushNotifications: true,
    autoApproveNewDonors: false,
    autoApproveNewRecipients: false,
    maxDonationDays: 7
  });

  const handleProfileChange = (e) => {
    setProfileData({
      ...profileData,
      [e.target.name]: e.target.value
    });
  };

  const handleAppSettingsChange = (e) => {
    setAppSettings({
      ...appSettings,
      [e.target.name]: e.target.type === 'checkbox' ? e.target.checked : e.target.value
    });
  };

  const handleSaveProfile = () => {
    // In a real app, this would call an API to update the admin profile
    console.log('Saving profile:', profileData);
    setSaveSuccess(true);
  };

  const handleSaveSettings = () => {
    // In a real app, this would call an API to update the app settings
    console.log('Saving app settings:', appSettings);
    setSaveSuccess(true);
  };

  const handleCloseSnackbar = () => {
    setSaveSuccess(false);
  };

  return (
    <Box>
      <Typography variant="h4" gutterBottom>
        Settings
      </Typography>
      
      <Grid container spacing={3}>
        {/* Admin Profile Section */}
        <Grid item xs={12} md={6}>
          <Card elevation={2}>
            <CardHeader 
              title="Admin Profile" 
              subheader="Update your administrator information" 
            />
            <Divider />
            <CardContent>
              <Box component="form">
                <Grid container spacing={2}>
                  <Grid item xs={12}>
                    <TextField
                      fullWidth
                      label="Name"
                      name="name"
                      value={profileData.name}
                      onChange={handleProfileChange}
                    />
                  </Grid>
                  <Grid item xs={12}>
                    <TextField
                      fullWidth
                      label="Email"
                      name="email"
                      type="email"
                      value={profileData.email}
                      onChange={handleProfileChange}
                      disabled // Email should not be editable as it's tied to Firebase
                    />
                  </Grid>
                  <Grid item xs={12}>
                    <TextField
                      fullWidth
                      label="Phone"
                      name="phone"
                      value={profileData.phone}
                      onChange={handleProfileChange}
                    />
                  </Grid>
                  <Grid item xs={12}>
                    <Button 
                      variant="contained" 
                      color="primary" 
                      onClick={handleSaveProfile}
                      sx={{ mt: 2 }}
                    >
                      Save Profile
                    </Button>
                  </Grid>
                </Grid>
              </Box>
            </CardContent>
          </Card>
        </Grid>
        
        {/* App Settings Section */}
        <Grid item xs={12} md={6}>
          <Card elevation={2}>
            <CardHeader 
              title="App Settings" 
              subheader="Configure application behavior" 
            />
            <Divider />
            <CardContent>
              <Box>
                <Grid container spacing={2}>
                  <Grid item xs={12}>
                    <FormControlLabel
                      control={
                        <Switch
                          checked={appSettings.enableEmailNotifications}
                          onChange={handleAppSettingsChange}
                          name="enableEmailNotifications"
                          color="primary"
                        />
                      }
                      label="Enable Email Notifications"
                    />
                  </Grid>
                  <Grid item xs={12}>
                    <FormControlLabel
                      control={
                        <Switch
                          checked={appSettings.enablePushNotifications}
                          onChange={handleAppSettingsChange}
                          name="enablePushNotifications"
                          color="primary"
                        />
                      }
                      label="Enable Push Notifications"
                    />
                  </Grid>
                  <Grid item xs={12}>
                    <FormControlLabel
                      control={
                        <Switch
                          checked={appSettings.autoApproveNewDonors}
                          onChange={handleAppSettingsChange}
                          name="autoApproveNewDonors"
                          color="primary"
                        />
                      }
                      label="Auto-approve New Donors"
                    />
                  </Grid>
                  <Grid item xs={12}>
                    <FormControlLabel
                      control={
                        <Switch
                          checked={appSettings.autoApproveNewRecipients}
                          onChange={handleAppSettingsChange}
                          name="autoApproveNewRecipients"
                          color="primary"
                        />
                      }
                      label="Auto-approve New Recipients"
                    />
                  </Grid>
                  <Grid item xs={12}>
                    <TextField
                      fullWidth
                      label="Maximum Donation Expiry Days"
                      name="maxDonationDays"
                      type="number"
                      value={appSettings.maxDonationDays}
                      onChange={handleAppSettingsChange}
                      InputProps={{ inputProps: { min: 1, max: 30 } }}
                      helperText="Maximum number of days a donation can be set to expire"
                    />
                  </Grid>
                  <Grid item xs={12}>
                    <Button 
                      variant="contained" 
                      color="primary" 
                      onClick={handleSaveSettings}
                      sx={{ mt: 2 }}
                    >
                      Save Settings
                    </Button>
                  </Grid>
                </Grid>
              </Box>
            </CardContent>
          </Card>
        </Grid>
        
        {/* Database Backup Section */}
        <Grid item xs={12}>
          <Card elevation={2}>
            <CardHeader 
              title="Database Management" 
              subheader="Backup and restore database" 
            />
            <Divider />
            <CardContent>
              <Alert severity="info" sx={{ mb: 2 }}>
                These operations will affect all data in the application. Please use with caution.
              </Alert>
              <Box sx={{ display: 'flex', gap: 2 }}>
                <Button variant="outlined" color="primary">
                  Backup Database
                </Button>
                <Button variant="outlined" color="secondary">
                  Restore Database
                </Button>
                <Button variant="outlined" color="error">
                  Reset Test Data
                </Button>
              </Box>
            </CardContent>
          </Card>
        </Grid>
      </Grid>
      
      <Snackbar
        open={saveSuccess}
        autoHideDuration={6000}
        onClose={handleCloseSnackbar}
        message="Settings saved successfully"
      />
    </Box>
  );
};

export default Settings; 
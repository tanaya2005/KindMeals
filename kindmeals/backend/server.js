const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const multer = require('multer');
const path = require('path');
require('dotenv').config();

// Initialize Express app
const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(express.json());
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Configure Multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  }
});

const upload = multer({ 
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB limit
  fileFilter: (req, file, cb) => {
    const filetypes = /jpeg|jpg|png/;
    const extname = filetypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = filetypes.test(file.mimetype);
    
    if (extname && mimetype) {
      return cb(null, true);
    } else {
      cb('Error: Images only (jpeg, jpg, png)!');
    }
  }
}).fields([
  { name: 'profileImage', maxCount: 1 },
  { name: 'foodImage', maxCount: 1 }
]);

// MongoDB Connection
mongoose.connect(process.env.MONGODB_URI)
  .then(() => console.log('Connected to MongoDB Atlas'))
  .catch(err => console.error('MongoDB connection error:', err));

// Define models
const userSchema = new mongoose.Schema({
  firebaseUid: { type: String, required: true, unique: true },
  email: { type: String, required: true, unique: true },
  role: { type: String, enum: ['donor', 'recipient', 'volunteer'], required: true },
  profileImage: { type: String },
  createdAt: { type: Date, default: Date.now }
});

const donorSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  donorname: { type: String, required: true },
  orgName: { type: String, required: true },
  identificationId: { type: String, required: true },
  donoraddress: { type: String, required: true },
  donorcontact: { type: String, required: true },
  type: { type: String, required: true },
  donorabout: { type: String },
  donorlocation: {
    latitude: { type: Number },
    longitude: { type: Number }
  }
});

const recipientSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  reciname: { type: String, required: true },
  ngoName: { type: String, required: true },
  ngoId: { type: String, required: true },
  reciaddress: { type: String, required: true },
  recicontact: { type: String, required: true },
  type: { type: String, required: true },
  reciabout: { type: String },
  recilocation: {
    latitude: { type: Number },
    longitude: { type: Number }
  }
});

const volunteerSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  volunteerName: { type: String, required: true },
  aadharID: { type: Number, required: true },
  volunteeraddress: { type: String, required: true },
  volunteercontact: { type: String, required: true },
  volunteerabout: { type: String },
  volunteerlocation: {
    latitude: { type: Number },
    longitude: { type: Number }
  }
});

const liveDonationSchema = new mongoose.Schema({
  donorId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  donorName: { type: String, required: true },
  foodName: { type: String, required: true },
  quantity: { type: Number, required: true },
  description: { type: String, required: true },
  expiryDateTime: { type: Date, required: true },
  timeOfUpload: { type: Date, default: Date.now },
  foodType: {
    type: String,
    enum: ['veg', 'nonveg', 'jain'],
    required: true,
  },
  imageUrl: String,
  location: {
    address: { type: String, required: true },
    latitude: Number,
    longitude: Number,
  },
  needsVolunteer: { type: Boolean, default: false },
});

const acceptedDonationSchema = new mongoose.Schema({
  originalDonationId: { type: mongoose.Schema.Types.ObjectId, ref: 'LiveDonation', required: true },
  acceptedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  recipientName: { type: String, required: true },
  donorId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  donorName: { type: String, required: true },
  acceptedAt: { type: Date, default: Date.now },
  foodName: { type: String, required: true },
  quantity: { type: Number, required: true },
  description: { type: String, required: true },
  expiryDateTime: { type: Date, required: true },
  timeOfUpload: { type: Date },
  foodType: {
    type: String,
    enum: ['veg', 'nonveg', 'jain'],
    required: true,
  },
  deliveredby: { type: String, required: true },
  feedback: { type: String, default: '' }
});

// Create models
const User = mongoose.model('User', userSchema);
const Donor = mongoose.model('Donor', donorSchema);
const Recipient = mongoose.model('Recipient', recipientSchema);
const Volunteer = mongoose.model('Volunteer', volunteerSchema);
const LiveDonation = mongoose.model('LiveDonation', liveDonationSchema);
const AcceptedDonation = mongoose.model('AcceptedDonation', acceptedDonationSchema);

// Auth Middleware - Verify Firebase UID
const authMiddleware = async (req, res, next) => {
  try {
    const firebaseUid = req.header('Authorization')?.replace('Bearer ', '');
    if (!firebaseUid) {
      return res.status(401).json({ error: 'No Firebase UID provided' });
    }

    const user = await User.findOne({ firebaseUid });
    
    if (!user) {
      return res.status(401).json({ error: 'User not found' });
    }

    req.user = user;
    next();
  } catch (error) {
    console.error('Error verifying Firebase UID:', error);
    res.status(401).json({ error: 'Not authorized' });
  }
};

// Helper function to get user type and profile
const getUserProfile = async (userId) => {
  const user = await User.findById(userId);
  if (!user) return null;

  let profile = null;
  
  if (user.role === 'donor') {
    profile = await Donor.findOne({ userId });
  } else if (user.role === 'recipient') {
    profile = await Recipient.findOne({ userId });
  } else if (user.role === 'volunteer') {
    profile = await Volunteer.findOne({ userId });
  }
  
  return { user, profile };
};

// Auth Routes

// User Registration (after Firebase auth)
app.post('/api/register', async (req, res) => {
  try {
    const { firebaseUid, email, role } = req.body;
    
    console.log('Registration attempt:', { firebaseUid, email, role });
    
    if (!firebaseUid || !email || !role) {
      console.log('Missing required fields');
      return res.status(400).json({ error: 'Missing required fields' });
    }

    // Check if user already exists
    const existingUser = await User.findOne({ firebaseUid });
    if (existingUser) {
      console.log('User already exists:', existingUser);
      return res.status(400).json({ error: 'User already exists' });
    }

    // Create new user
    const user = new User({
      firebaseUid,
      email,
      role
    });

    await user.save();
    console.log('User created successfully:', user);

    res.status(201).json({ 
      message: 'User created successfully',
      user: { _id: user._id, email: user.email, role: user.role }
    });
  } catch (err) {
    console.error('Error in registration:', err);
    res.status(400).json({ error: err.message });
  }
});

// Delete user (for registration rollback)
app.delete('/api/user', authMiddleware, async (req, res) => {
  try {
    const user = req.user;
    
    // Delete user's profile based on role
    if (user.role === 'donor') {
      await Donor.findOneAndDelete({ userId: user._id });
    } else if (user.role === 'recipient') {
      await Recipient.findOneAndDelete({ userId: user._id });
    } else if (user.role === 'volunteer') {
      await Volunteer.findOneAndDelete({ userId: user._id });
    }
    
    // Delete user from Users collection
    await User.findByIdAndDelete(user._id);
    
    res.status(200).json({ message: 'User deleted successfully' });
  } catch (err) {
    console.error('Error deleting user:', err);
    res.status(400).json({ error: err.message });
  }
});

// Check if user exists
app.get('/api/user/check', authMiddleware, async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    res.status(200).json({ exists: true });
  } catch (err) {
    console.error('Error checking user:', err);
    res.status(400).json({ error: err.message });
  }
});

// User Profile Routes

// Get user profile
app.get('/api/user/profile', authMiddleware, async (req, res) => {
  try {
    const profile = await getUserProfile(req.user._id);
    if (!profile) {
      return res.status(404).json({ error: 'Profile not found' });
    }
    
    res.status(200).json(profile);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Complete donor registration (after signup)
app.post('/api/donor/register', authMiddleware, upload, async (req, res) => {
  try {
    console.log('Donor registration attempt for user:', req.user._id);
    
    if (req.user.role !== 'donor') {
      console.log('User role mismatch. Expected: donor, Got:', req.user.role);
      return res.status(403).json({ error: 'Only users with donor role can register as donors' });
    }

    // Check if donor already registered
    const existingDonor = await Donor.findOne({ userId: req.user._id });
    if (existingDonor) {
      console.log('Donor already registered:', existingDonor);
      return res.status(400).json({ error: 'Donor already registered' });
    }

    // Handle profile image upload - safely check if files exist
    let profileImage = '';
    if (req.files && req.files['profileImage'] && req.files['profileImage'][0]) {
      profileImage = `/uploads/${req.files['profileImage'][0].filename}`;
      // Update user with profile image
      await User.findByIdAndUpdate(req.user._id, { profileImage });
    }

    // Create donor profile
    const donor = new Donor({
      userId: req.user._id,
      donorname: req.body.donorname,
      orgName: req.body.orgName,
      identificationId: req.body.identificationId,
      donoraddress: req.body.donoraddress,
      donorcontact: req.body.donorcontact,
      type: req.body.type,
      donorabout: req.body.donorabout || '',
      donorlocation: {
        latitude: req.body.latitude || 0,
        longitude: req.body.longitude || 0
      }
    });

    const savedDonor = await donor.save();
    console.log('Donor registered successfully:', savedDonor);
    res.status(201).json(savedDonor);
  } catch (err) {
    console.error('Error in donor registration:', err);
    res.status(400).json({ error: err.message });
  }
});

// Complete recipient registration (after signup)
app.post('/api/recipient/register', authMiddleware, upload, async (req, res) => {
  try {
    console.log('Recipient registration attempt for user:', req.user._id);
    
    if (req.user.role !== 'recipient') {
      console.log('User role mismatch. Expected: recipient, Got:', req.user.role);
      return res.status(403).json({ error: 'Only users with recipient role can register as recipients' });
    }

    // Check if recipient already registered
    const existingRecipient = await Recipient.findOne({ userId: req.user._id });
    if (existingRecipient) {
      console.log('Recipient already registered:', existingRecipient);
      return res.status(400).json({ error: 'Recipient already registered' });
    }

    // Handle profile image upload - safely check if files exist
    let profileImage = '';
    if (req.files && req.files['profileImage'] && req.files['profileImage'][0]) {
      profileImage = `/uploads/${req.files['profileImage'][0].filename}`;
      // Update user with profile image
      await User.findByIdAndUpdate(req.user._id, { profileImage });
    }

    // Create recipient profile
    const recipient = new Recipient({
      userId: req.user._id,
      reciname: req.body.reciname,
      ngoName: req.body.ngoName,
      ngoId: req.body.ngoId,
      reciaddress: req.body.reciaddress,
      recicontact: req.body.recicontact,
      type: req.body.type,
      reciabout: req.body.reciabout || '',
      recilocation: {
        latitude: req.body.latitude || 0,
        longitude: req.body.longitude || 0
      }
    });

    const savedRecipient = await recipient.save();
    console.log('Recipient registered successfully:', savedRecipient);
    res.status(201).json(savedRecipient);
  } catch (err) {
    console.error('Error in recipient registration:', err);
    res.status(400).json({ error: err.message });
  }
});

// Complete volunteer registration (after signup)
app.post('/api/volunteer/register', authMiddleware, upload, async (req, res) => {
  try {
    if (req.user.role !== 'volunteer') {
      return res.status(403).json({ error: 'Only users with volunteer role can register as volunteers' });
    }

    // Check if volunteer already registered
    const existingVolunteer = await Volunteer.findOne({ userId: req.user._id });
    if (existingVolunteer) {
      return res.status(400).json({ error: 'Volunteer already registered' });
    }

    // Handle profile image upload
    const profileImage = req.files['profileImage'] ? 
      `/uploads/${req.files['profileImage'][0].filename}` : '';

    // Update user with profile image if uploaded
    if (profileImage) {
      await User.findByIdAndUpdate(req.user._id, { profileImage });
    }

    // Create volunteer profile
    const volunteer = new Volunteer({
      userId: req.user._id,
      volunteerName: req.body.volunteerName,
      aadharID: req.body.aadharID,
      volunteeraddress: req.body.volunteeraddress,
      volunteercontact: req.body.volunteercontact,
      volunteerabout: req.body.volunteerabout || '',
      volunteerlocation: {
        latitude: req.body.latitude || 0,
        longitude: req.body.longitude || 0
      }
    });

    const savedVolunteer = await volunteer.save();
    res.status(201).json(savedVolunteer);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Donation Management Routes

// Create a new live donation (with food image upload)
app.post('/api/donations/create', authMiddleware, upload, async (req, res) => {
  try {
    // Check if user is a donor
    const donor = await Donor.findOne({ userId: req.user._id });
    if (!donor) {
      return res.status(403).json({ error: 'Only registered donors can create donations' });
    }

    // Handle food image upload
    const foodImage = req.files['foodImage'] ? 
      `/uploads/${req.files['foodImage'][0].filename}` : '';

    const newDonation = new LiveDonation({
      donorId: req.user._id,
      donorName: donor.donorname,
      foodName: req.body.foodName,
      quantity: req.body.quantity,
      description: req.body.description,
      expiryDateTime: new Date(req.body.expiryDateTime),
      timeOfUpload: new Date(),
      foodType: req.body.foodType,
      imageUrl: foodImage,
      location: {
        address: req.body.address || donor.donoraddress,
        latitude: req.body.latitude || donor.donorlocation.latitude,
        longitude: req.body.longitude || donor.donorlocation.longitude
      },
      needsVolunteer: req.body.needsVolunteer || false
    });

    const savedDonation = await newDonation.save();
    res.status(201).json(savedDonation);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Get all live donations
app.get('/api/donations/live', async (req, res) => {
  try {
    // Get current time
    const currentTime = new Date();
    
    // Find all donations that haven't expired
    const donations = await LiveDonation.find({
      expiryDateTime: { $gt: currentTime }
    }).sort({ timeOfUpload: -1 });
    
    res.status(200).json(donations);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Accept a donation
app.post('/api/donations/accept/:donationId', authMiddleware, async (req, res) => {
  try {
    // Check if user is a recipient
    const recipient = await Recipient.findOne({ userId: req.user._id });
    if (!recipient) {
      return res.status(403).json({ error: 'Only registered recipients can accept donations' });
    }

    const donation = await LiveDonation.findById(req.params.donationId);
    if (!donation) {
      return res.status(404).json({ error: 'Donation not found' });
    }

    // Check if donation has expired
    if (new Date(donation.expiryDateTime) < new Date()) {
      return res.status(400).json({ error: 'This donation has expired' });
    }

    let volunteerInfo = req.body.volunteerName || "Self-pickup";

    // Create accepted donation record
    const acceptedDonation = new AcceptedDonation({
      originalDonationId: donation._id,
      acceptedBy: req.user._id,
      recipientName: recipient.reciname,
      donorId: donation.donorId,
      donorName: donation.donorName,
      acceptedAt: new Date(),
      foodName: donation.foodName,
      quantity: donation.quantity,
      description: donation.description,
      expiryDateTime: donation.expiryDateTime,
      timeOfUpload: donation.timeOfUpload,
      foodType: donation.foodType,
      deliveredby: volunteerInfo,
      feedback: "" // Initialize empty feedback
    });

    const savedAcceptedDonation = await acceptedDonation.save();
    
    // Remove from live donations
    await LiveDonation.findByIdAndDelete(req.params.donationId);
    
    res.status(200).json(savedAcceptedDonation);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Add feedback to an accepted donation
app.post('/api/donations/feedback/:acceptedDonationId', authMiddleware, async (req, res) => {
  try {
    const acceptedDonation = await AcceptedDonation.findById(req.params.acceptedDonationId);
    if (!acceptedDonation) {
      return res.status(404).json({ error: 'Accepted donation not found' });
    }
    
    // Verify the user is the recipient who accepted this donation
    if (!acceptedDonation.acceptedBy.equals(req.user._id)) {
      return res.status(403).json({ error: 'You can only provide feedback for donations you accepted' });
    }

    // Update the feedback
    acceptedDonation.feedback = req.body.feedback;
    const updatedDonation = await acceptedDonation.save();
    
    res.status(200).json(updatedDonation);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Clean up expired donations
app.delete('/api/donations/cleanup', async (req, res) => {
  try {
    const currentTime = new Date();
    
    // Find and delete expired donations
    const result = await LiveDonation.deleteMany({
      expiryDateTime: { $lt: currentTime }
    });
    
    res.status(200).json({ message: `Deleted ${result.deletedCount} expired donations` });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Update donor profile (with optional profile image upload)
app.put('/api/donor/profile', authMiddleware, upload, async (req, res) => {
  try {
    const donor = await Donor.findOne({ userId: req.user._id });
    if (!donor) {
      return res.status(404).json({ error: 'Donor not found' });
    }
    
    // Handle profile image upload if provided
    if (req.files['profileImage']) {
      const profileImage = `/uploads/${req.files['profileImage'][0].filename}`;
      await User.findByIdAndUpdate(req.user._id, { profileImage });
    }

    const updatedDonor = await Donor.findOneAndUpdate(
      { userId: req.user._id },
      {
        donorname: req.body.donorname || donor.donorname,
        orgName: req.body.orgName || donor.orgName,
        donoraddress: req.body.donoraddress || donor.donoraddress,
        donorcontact: req.body.donorcontact || donor.donorcontact,
        donorabout: req.body.donorabout || donor.donorabout,
        donorlocation: {
          latitude: req.body.latitude || donor.donorlocation.latitude,
          longitude: req.body.longitude || donor.donorlocation.longitude
        }
      },
      { new: true }
    );
    
    res.status(200).json(updatedDonor);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Get donor donation history
app.get('/api/donor/donations', authMiddleware, async (req, res) => {
  try {
    const donor = await Donor.findOne({ userId: req.user._id });
    if (!donor) {
      return res.status(404).json({ error: 'Donor not found' });
    }
    
    // Get live donations by this donor
    const liveDonations = await LiveDonation.find({ donorId: req.user._id });
    
    // Get accepted donations that were originally created by this donor
    const acceptedDonations = await AcceptedDonation.find({ donorId: req.user._id });
    
    res.status(200).json({
      liveDonations,
      acceptedDonations
    });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Update recipient profile (with optional profile image upload)
app.put('/api/recipient/profile', authMiddleware, upload, async (req, res) => {
  try {
    const recipient = await Recipient.findOne({ userId: req.user._id });
    if (!recipient) {
      return res.status(404).json({ error: 'Recipient not found' });
    }
    
    // Handle profile image upload if provided
    if (req.files['profileImage']) {
      const profileImage = `/uploads/${req.files['profileImage'][0].filename}`;
      await User.findByIdAndUpdate(req.user._id, { profileImage });
    }

    const updatedRecipient = await Recipient.findOneAndUpdate(
      { userId: req.user._id },
      {
        reciname: req.body.reciname || recipient.reciname,
        ngoName: req.body.ngoName || recipient.ngoName,
        reciaddress: req.body.reciaddress || recipient.reciaddress,
        recicontact: req.body.recicontact || recipient.recicontact,
        reciabout: req.body.reciabout || recipient.reciabout,
        recilocation: {
          latitude: req.body.latitude || recipient.recilocation.latitude,
          longitude: req.body.longitude || recipient.recilocation.longitude
        }
      },
      { new: true }
    );
    
    res.status(200).json(updatedRecipient);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Get recipient donation history
app.get('/api/recipient/donations', authMiddleware, async (req, res) => {
  try {
    const recipient = await Recipient.findOne({ userId: req.user._id });
    if (!recipient) {
      return res.status(404).json({ error: 'Recipient not found' });
    }
    
    // Get accepted donations by this recipient
    const acceptedDonations = await AcceptedDonation.find({ acceptedBy: req.user._id });
    
    res.status(200).json(acceptedDonations);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Update volunteer profile (with optional profile image upload)
app.put('/api/volunteer/profile', authMiddleware, upload, async (req, res) => {
  try {
    const volunteer = await Volunteer.findOne({ userId: req.user._id });
    if (!volunteer) {
      return res.status(404).json({ error: 'Volunteer not found' });
    }
    
    // Handle profile image upload if provided
    if (req.files['profileImage']) {
      const profileImage = `/uploads/${req.files['profileImage'][0].filename}`;
      await User.findByIdAndUpdate(req.user._id, { profileImage });
    }

    const updatedVolunteer = await Volunteer.findOneAndUpdate(
      { userId: req.user._id },
      {
        volunteerName: req.body.volunteerName || volunteer.volunteerName,
        volunteeraddress: req.body.volunteeraddress || volunteer.volunteeraddress,
        volunteercontact: req.body.volunteercontact || volunteer.volunteercontact,
        volunteerabout: req.body.volunteerabout || volunteer.volunteerabout,
        volunteerlocation: {
          latitude: req.body.latitude || volunteer.volunteerlocation.latitude,
          longitude: req.body.longitude || volunteer.volunteerlocation.longitude
        }
      },
      { new: true }
    );
    
    res.status(200).json(updatedVolunteer);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Get all available volunteer delivery opportunities
app.get('/api/volunteer/opportunities', authMiddleware, async (req, res) => {
  try {
    const volunteer = await Volunteer.findOne({ userId: req.user._id });
    if (!volunteer) {
      return res.status(404).json({ error: 'Volunteer not found' });
    }
    
    // Find donations that need volunteer delivery
    const opportunities = await LiveDonation.find({ 
      needsVolunteer: true,
      expiryDateTime: { $gt: new Date() }
    });
    
    res.status(200).json(opportunities);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.status(200).json({ status: 'OK', message: 'Server is running properly' });
});

// Start the server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
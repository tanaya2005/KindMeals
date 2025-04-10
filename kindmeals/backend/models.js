const mongoose = require('mongoose');

const donorSchema = new mongoose.Schema({
  donorname: { type: String, required: true },
  orgName: { type: String, required: true }, // Organization name or individual
  identificationId: { type: String, required: true }, // Aadhar ID or equivalent
  donoraddress: { type: String, required: true },
  donoremail: { type: String, required: true, unique: true },
  donorcontact: { type: String, required: true },
  donorpasswordHash: { type: String, required: true }, // Store hashed password
  type: { type: String, required: true }, // Define possible values as needed
  donorabout: { type: String },
  donorprofileImage: { type: String },
  donorlocation: {
    latitude: { type: Number },
    longitude: { type: Number }
  }
});


const recipientSchema = new mongoose.Schema({
  reciname: { type: String, required: true },
  ngoName: { type: String, required: true }, // NGO name or individual
  ngoId: { type: String, required: true }, // NGO ID or equivalent
  reciaddress: { type: String, required: true },
  reciemail: { type: String, required: true, unique: true },
  recicontact: { type: String, required: true },
  recipasswordHash: { type: String, required: true }, // Store hashed password
  type: { type: String, required: true }, // Define possible values as needed
  reciabout: { type: String },
  reciprofileImage: { type: String },
  recilocation: {
    latitude: { type: Number },
    longitude: { type: Number }
  }
});

const Recipient = mongoose.model('Recipient', recipientSchema);

module.exports = Recipient;

// Schema for live donations
const liveDonationSchema = new mongoose.Schema({
  donorId: { type: mongoose.Schema.Types.ObjectId, ref: 'Donor', required: true },
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

const LiveDonation = mongoose.model('LiveDonation', liveDonationSchema);

// Schema for accepted donations
const acceptedDonationSchema = new mongoose.Schema({
  originalDonationId: { type: mongoose.Schema.Types.ObjectId, ref: 'LiveDonation', required: true },
  acceptedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'Recipient', required: true },
  acceptedAt: { type: Date, default: Date.now },
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
  deliveredby: { type: String, required: true },
});

const AcceptedDonation = mongoose.model('AcceptedDonation', acceptedDonationSchema);

const volunteerSchema= new mongoose.Schema({
  volunteerName: { type: String, required: true },
  aadharID: { type: Number, required: true }, // Aadhar ID or equivalent
  volunteeraddress: { type: String, required: true },
  volunteeremail: { type: String, required: true, unique: true },
  volunteercontact: { type: String, required: true },
  volunteerpasswordHash: { type: String, required: true }, // Store hashed password
  volunteerabout: { type: String },
  volunteerprofileImage: { type: String },
  volunteerlocation: {
    latitude: { type: Number },
    longitude: { type: Number }
  }
})
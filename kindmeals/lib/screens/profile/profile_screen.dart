import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:kindmeals/services/api_service.dart';
import 'package:kindmeals/config/api_config.dart';
import 'package:kindmeals/services/firebase_service.dart';
import 'edit_profile_screen.dart';
import 'donor_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _profileImage;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _profileData;
  final ApiService _apiService = ApiService();
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Try the new direct API first
      try {
        final directProfileData = await _apiService.getDirectUserProfile();
        print('=== DEBUG: Direct Profile Data ===');
        print('Full direct profile data: $directProfileData');
        print('User Type: ${directProfileData['userType']}');
        print('Profile section: ${directProfileData['profile']}');

        setState(() {
          _userData = {
            'email': directProfileData['profile']['email'],
            'profileImage': directProfileData['profile']['profileImage'],
            'type': directProfileData['userType'],
          };
          _profileData = directProfileData['profile'];
          _isLoading = false;
        });
        return;
      } catch (directError) {
        print(
            'Error loading profile with direct API, falling back: $directError');
        // Fall back to the old API
      }

      // Legacy API as fallback
      final profileData = await _apiService.getUserProfile();
      setState(() {
        _userData = profileData['user'];
        _profileData = profileData['profile'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
      print('Error loading profile: $e');
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });

      try {
        // Determine if user is donor or recipient
        final userType = _userData?['type']?.toString().toLowerCase();

        if (userType == 'donor') {
          await _apiService.updateDirectDonorProfile(
              profileImage: _profileImage);
        } else if (userType == 'recipient') {
          await _apiService.updateDirectRecipientProfile(
              profileImage: _profileImage);
        } else {
          throw Exception('Unknown user type');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile image updated successfully'),
            backgroundColor: Colors.green,
          ),
        );

        _loadUserProfile(); // Reload profile to get updated image URL
      } catch (e) {
        print('Error uploading profile image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload profile image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _firebaseService.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildProfileSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8, top: 16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(
                    userData: _userData,
                    profileData: _profileData,
                  ),
                ),
              ).then((result) {
                // Reload profile data if successfully updated
                if (result == true) {
                  _loadUserProfile();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserProfile,
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Log Out'),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _handleLogout();
                      },
                      child: const Text('Log Out'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading profile',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUserProfile,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile header with image
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: _pickImage,
                                child: Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 60,
                                      backgroundImage: _profileImage != null
                                          ? FileImage(_profileImage!)
                                          : (_userData?['profileImage'] !=
                                                      null &&
                                                  _userData!['profileImage']
                                                      .toString()
                                                      .isNotEmpty)
                                              ? NetworkImage(
                                                      ApiConfig.getImageUrl(
                                                          _userData![
                                                              'profileImage']))
                                                  as ImageProvider
                                              : null,
                                      backgroundColor: Colors.grey[200],
                                      child: (_profileImage == null &&
                                              (_userData?['profileImage'] ==
                                                      null ||
                                                  _userData!['profileImage']
                                                      .toString()
                                                      .isEmpty))
                                          ? const Icon(
                                              Icons.person,
                                              size: 60,
                                              color: Colors.grey,
                                            )
                                          : null,
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _profileData?['donorname'] ??
                                    _profileData?['reciname'] ??
                                    'User',
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                _profileData?['orgName'] ??
                                    _profileData?['ngoName'] ??
                                    '',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.grey),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _userData?['type']
                                          ?.toString()
                                          .toUpperCase() ??
                                      'USER',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Profile sections
                      _buildProfileSection('Personal Information', [
                        _buildProfileItem(
                          Icons.person,
                          'Name',
                          _profileData?['donorname'] ??
                              _profileData?['reciname'] ??
                              'N/A',
                        ),
                        _buildProfileItem(
                          Icons.email,
                          'Email',
                          _userData?['email'] ?? 'N/A',
                        ),
                      ]),

                      _buildProfileSection('Contact Information', [
                        _buildProfileItem(
                          Icons.phone,
                          'Contact',
                          _profileData?['donorcontact'] ??
                              _profileData?['recicontact'] ??
                              'N/A',
                        ),
                        _buildProfileItem(
                          Icons.location_on,
                          'Address',
                          _profileData?['donoraddress'] ??
                              _profileData?['reciaddress'] ??
                              'N/A',
                        ),
                      ]),

                      _buildProfileSection('Organization Information', [
                        _buildProfileItem(
                          Icons.business,
                          'Organization Name',
                          _profileData?['orgName'] ??
                              _profileData?['ngoName'] ??
                              'N/A',
                        ),
                        _buildProfileItem(
                          Icons.badge,
                          'ID',
                          _profileData?['identificationId'] ??
                              _profileData?['ngoId'] ??
                              'N/A',
                        ),
                      ]),

                      _buildProfileSection('About', [
                        _buildProfileItem(
                          Icons.info,
                          'Description',
                          _profileData?['donorabout'] ??
                              _profileData?['reciabout'] ??
                              'No description available',
                        ),
                      ]),

                      // Donation History Button (Only for Donors)
                      if (_userData?['type']?.toString().toLowerCase() ==
                          'donor')
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const DonorHistoryScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.history),
                            label: const Text('View Donation History'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }
}

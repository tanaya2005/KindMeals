import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:kindmeals/services/api_service.dart';
import 'package:kindmeals/config/api_config.dart';

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
        print('Loaded profile using direct API: $directProfileData');
        setState(() {
          _userData = {
            'email': directProfileData['profile']['email'],
            'profileImage': directProfileData['profile']['profileImage'],
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
      // TODO: Upload image to server
    }
  }

  Widget _buildProfileSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
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
              // TODO: Navigate to edit profile screen
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserProfile,
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
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 60,
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : (_userData?['profileImage'] != null &&
                                        _userData!['profileImage']
                                            .toString()
                                            .isNotEmpty)
                                    ? NetworkImage(ApiConfig.getImageUrl(
                                            _userData!['profileImage']))
                                        as ImageProvider
                                    : null,
                            child: _profileImage == null &&
                                    (_userData?['profileImage'] == null ||
                                        _userData!['profileImage']
                                            .toString()
                                            .isEmpty)
                                ? const Icon(
                                    Icons.add_a_photo,
                                    size: 40,
                                    color: Colors.grey,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 20),
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
                          style:
                              const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 30),
                        _buildProfileSection('Personal Information', [
                          _buildProfileItem(
                              Icons.person,
                              'Name',
                              _profileData?['donorname'] ??
                                  _profileData?['reciname'] ??
                                  'N/A'),
                          _buildProfileItem(Icons.email, 'Email',
                              _userData?['email'] ?? 'N/A'),
                          _buildProfileItem(
                              Icons.phone,
                              'Contact',
                              _profileData?['donorcontact'] ??
                                  _profileData?['recicontact'] ??
                                  'N/A'),
                          _buildProfileItem(
                            Icons.location_on,
                            'Address',
                            _profileData?['donoraddress'] ??
                                _profileData?['reciaddress'] ??
                                'N/A',
                          ),
                        ]),
                        const SizedBox(height: 30),
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
                                  'N/A'),
                          _buildProfileItem(
                              Icons.category,
                              'Type',
                              _userData?['role']?.toString().toUpperCase() ??
                                  'N/A'),
                        ]),
                        const SizedBox(height: 30),
                        _buildProfileSection('About', [
                          _buildProfileItem(
                            Icons.info,
                            'Description',
                            _profileData?['donorabout'] ??
                                _profileData?['reciabout'] ??
                                'No description available',
                          ),
                        ]),
                      ],
                    ),
                  ),
                ),
    );
  }
}

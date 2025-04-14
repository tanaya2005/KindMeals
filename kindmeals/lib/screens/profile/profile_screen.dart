// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'package:kindmeals/services/api_service.dart';
// import 'package:kindmeals/config/api_config.dart';

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   File? _profileImage;
//   bool _isLoading = true;
//   bool _hasError = false;
//   bool _isEditing = false;
//   String _errorMessage = '';
//   Map<String, dynamic>? _userData;
//   Map<String, dynamic>? _profileData;
//   final ApiService _apiService = ApiService();

//   @override
//   void initState() {
//     super.initState();
//     _loadUserProfile();
//   }

//   Future<void> _loadUserProfile() async {
//     setState(() {
//       _isLoading = true;
//       _hasError = false;
//     });

//     try {
//       // Try the new direct API first
//       try {
//         final directProfileData = await _apiService.getDirectUserProfile();
//         print('=== DEBUG: Direct Profile Data ===');
//         print('Full direct profile data: $directProfileData');
//         print('User Type: ${directProfileData['userType']}');
//         print('Profile section: ${directProfileData['profile']}');

//         setState(() {
//           _userData = {
//             'email': directProfileData['profile']['email'],
//             'profileImage': directProfileData['profile']['profileImage'],
//             'type': directProfileData['userType'],
//           };
//           _profileData = directProfileData['profile'];
//           _isLoading = false;
//         });
//         return;
//       } catch (directError) {
//         print(
//             'Error loading profile with direct API, falling back: $directError');
//         // Fall back to the old API
//       }

//       // Legacy API as fallback
//       final profileData = await _apiService.getUserProfile();
//       setState(() {
//         _userData = profileData['user'];
//         _profileData = profileData['profile'];
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _hasError = true;
//         _errorMessage = e.toString();
//         _isLoading = false;
//       });
//       print('Error loading profile: $e');
//     }
//   }

//   Future<void> _pickImage() async {
//     final ImagePicker picker = ImagePicker();
//     final XFile? image = await picker.pickImage(source: ImageSource.gallery);
//     if (image != null) {
//       setState(() {
//         _profileImage = File(image.path);
//       });

//       try {
//         // Determine if user is donor or recipient
//         final userType = _userData?['type']?.toString().toLowerCase();

//         if (userType == 'donor') {
//           await _apiService.updateDirectDonorProfile(
//               profileImage: _profileImage);
//         } else if (userType == 'recipient') {
//           await _apiService.updateDirectRecipientProfile(
//               profileImage: _profileImage);
//         } else {
//           throw Exception('Unknown user type');
//         }

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Profile image updated successfully'),
//             backgroundColor: Colors.green,
//           ),
//         );

//         _loadUserProfile(); // Reload profile to get updated image URL
//       } catch (e) {
//         print('Error uploading profile image: $e');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to upload profile image: ${e.toString()}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   Widget _buildProfileSection(String title, List<Widget> children) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 10),
//         Card(
//           elevation: 2,
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: children,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildProfileItem(IconData icon, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         children: [
//           Icon(icon, color: Colors.grey),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   value,
//                   style: const TextStyle(
//                     fontSize: 16,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Profile'),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: Icon(_isEditing ? Icons.save : Icons.edit),
//             onPressed: () {
//               setState(() {
//                 _isEditing = !_isEditing;
//               });
//               if (!_isEditing) {
//                 // Save profile changes here if needed
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Edit mode disabled'),
//                     backgroundColor: Colors.green,
//                   ),
//                 );
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Now you can edit your profile'),
//                     backgroundColor: Colors.blue,
//                   ),
//                 );
//               }
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _loadUserProfile,
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _hasError
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Icon(
//                         Icons.error_outline,
//                         color: Colors.red,
//                         size: 60,
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         'Error loading profile',
//                         style: Theme.of(context).textTheme.titleLarge,
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         _errorMessage,
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(color: Colors.red),
//                       ),
//                       const SizedBox(height: 16),
//                       ElevatedButton(
//                         onPressed: _loadUserProfile,
//                         child: const Text('Try Again'),
//                       ),
//                     ],
//                   ),
//                 )
//               : SingleChildScrollView(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         GestureDetector(
//                           onTap: _isEditing ? _pickImage : null,
//                           child: Stack(
//                             children: [
//                               CircleAvatar(
//                                 radius: 60,
//                                 backgroundImage: _profileImage != null
//                                     ? FileImage(_profileImage!)
//                                     : (_userData?['profileImage'] != null &&
//                                             _userData!['profileImage']
//                                                 .toString()
//                                                 .isNotEmpty)
//                                         ? NetworkImage(ApiConfig.getImageUrl(
//                                                 _userData!['profileImage']))
//                                             as ImageProvider
//                                         : null,
//                                 backgroundColor: Colors.grey[200],
//                                 child: (_profileImage == null &&
//                                         (_userData?['profileImage'] == null ||
//                                             _userData!['profileImage']
//                                                 .toString()
//                                                 .isEmpty))
//                                     ? const Icon(
//                                         Icons.person,
//                                         size: 60,
//                                         color: Colors.grey,
//                                       )
//                                     : null,
//                               ),
//                               if (_isEditing)
//                                 Positioned(
//                                   bottom: 0,
//                                   right: 0,
//                                   child: Container(
//                                     padding: const EdgeInsets.all(4),
//                                     decoration: BoxDecoration(
//                                       color: Colors.green,
//                                       shape: BoxShape.circle,
//                                     ),
//                                     child: Icon(
//                                       Icons.edit,
//                                       color: Colors.white,
//                                       size: 18,
//                                     ),
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         Text(
//                           _profileData?['donorname'] ??
//                               _profileData?['reciname'] ??
//                               'User',
//                           style: const TextStyle(
//                               fontSize: 24, fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 5),
//                         Text(
//                           _profileData?['orgName'] ??
//                               _profileData?['ngoName'] ??
//                               '',
//                           style:
//                               const TextStyle(fontSize: 16, color: Colors.grey),
//                         ),
//                         const SizedBox(height: 5),
//                         Text(
//                           _userData?['type']?.toString().toUpperCase() ??
//                               'USER',
//                           style: const TextStyle(
//                               fontSize: 16,
//                               color: Colors.green,
//                               fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 30),
//                         _buildProfileSection('Personal Information', [
//                           _buildProfileItem(
//                               Icons.person,
//                               'Name',
//                               _profileData?['donorname'] ??
//                                   _profileData?['reciname'] ??
//                                   'N/A'),
//                           _buildProfileItem(Icons.email, 'Email',
//                               _userData?['email'] ?? 'N/A'),
//                           _buildProfileItem(
//                               Icons.phone,
//                               'Contact',
//                               _profileData?['donorcontact'] ??
//                                   _profileData?['recicontact'] ??
//                                   'N/A'),
//                           _buildProfileItem(
//                             Icons.location_on,
//                             'Address',
//                             _profileData?['donoraddress'] ??
//                                 _profileData?['reciaddress'] ??
//                                 'N/A',
//                           ),
//                         ]),
//                         const SizedBox(height: 30),
//                         _buildProfileSection('Organization Information', [
//                           _buildProfileItem(
//                             Icons.business,
//                             'Organization Name',
//                             _profileData?['orgName'] ??
//                                 _profileData?['ngoName'] ??
//                                 'N/A',
//                           ),
//                           _buildProfileItem(
//                               Icons.badge,
//                               'ID',
//                               _profileData?['identificationId'] ??
//                                   _profileData?['ngoId'] ??
//                                   'N/A'),
//                           // _buildProfileItem(
//                           //     Icons.category,
//                           //     'Type',
//                           //     _userData?['role']?.toString().toUpperCase() ??
//                           //         'N/A'),
//                         ]),
//                         const SizedBox(height: 30),
//                         _buildProfileSection('About', [
//                           _buildProfileItem(
//                             Icons.info,
//                             'Description',
//                             _profileData?['donorabout'] ??
//                                 _profileData?['reciabout'] ??
//                                 'No description available',
//                           ),
//                         ]),
//                       ],
//                     ),
//                   ),
//                 ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:kindmeals/services/api_service.dart';
import 'package:kindmeals/config/api_config.dart';
import 'package:kindmeals/services/firebase_service.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  File? _profileImage;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isEditing = false;
  String _errorMessage = '';
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _profileData;
  final ApiService _apiService = ApiService();
  late AnimationController _animationController;
  late Animation<double> _animation;
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
    
    if (_isEditing) {
      _animationController.forward();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Now you can edit your profile'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      _animationController.reverse();
      // Save profile changes here if needed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Changes saved'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildProfileHeader() {
    final String displayName = _profileData?['donorname'] ?? 
                              _profileData?['reciname'] ?? 
                              'User';
    final String orgName = _profileData?['orgName'] ?? 
                          _profileData?['ngoName'] ?? 
                          '';
    final String userType = _userData?['type']?.toString().toUpperCase() ?? 'USER';
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.shade700,
            Colors.green.shade500,
          ],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
      child: Column(
        children: [
          GestureDetector(
            onTap: _isEditing ? _pickImage : null,
            child: Stack(
              children: [
                Hero(
                  tag: 'profileImage',
                  child: Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : (_userData?['profileImage'] != null &&
                                  _userData!['profileImage'].toString().isNotEmpty)
                              ? NetworkImage(ApiConfig.getImageUrl(_userData!['profileImage']))
                                  as ImageProvider
                              : null,
                      backgroundColor: Colors.grey[200],
                      child: (_profileImage == null &&
                              (_userData?['profileImage'] == null ||
                                  _userData!['profileImage'].toString().isEmpty))
                          ? const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                  ),
                ),
                if (_isEditing)
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            displayName,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 2,
                  offset: Offset(1, 1),
                ),
              ],
            ),
          ),
          if (orgName.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              orgName,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.5)),
            ),
            child: Text(
              userType,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Row(
              children: [
                Container(
                  height: 24,
                  width: 4,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            elevation: 3,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.green,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (_isEditing)
            FadeTransition(
              opacity: _animation,
              child: Icon(
                Icons.edit,
                color: Colors.green,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading your profile...',
            style: TextStyle(
              color: Colors.green,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Error loading profile',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadUserProfile,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                setState(() {
                  _isEditing = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Edit mode disabled'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                // Navigate to edit profile screen
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
              }
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
          ? _buildLoadingView()
          : _hasError
              ? _buildErrorView()
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildProfileHeader(),
                      const SizedBox(height: 24),
                      _buildProfileSection('Personal Information', [
                        _buildProfileItem(
                          Icons.person_rounded,
                          'Name',
                          _profileData?['donorname'] ??
                              _profileData?['reciname'] ??
                              'N/A',
                        ),
                        const Divider(height: 4),
                        _buildProfileItem(
                          Icons.email_rounded,
                          'Email',
                          _userData?['email'] ?? 'N/A',
                        ),
                        const Divider(height: 4),
                        _buildProfileItem(
                          Icons.phone_rounded,
                          'Contact',
                          _profileData?['donorcontact'] ??
                              _profileData?['recicontact'] ??
                              'N/A',
                        ),
                        const Divider(height: 4),
                        _buildProfileItem(
                          Icons.location_on_rounded,
                          'Address',
                          _profileData?['donoraddress'] ??
                              _profileData?['reciaddress'] ??
                              'N/A',
                        ),
                      ]),
                      _buildProfileSection('Organization Information', [
                        _buildProfileItem(
                          Icons.business_rounded,
                          'Organization Name',
                          _profileData?['orgName'] ??
                              _profileData?['ngoName'] ??
                              'N/A',
                        ),
                        const Divider(height: 4),
                        _buildProfileItem(
                          Icons.badge_rounded,
                          'ID',
                          _profileData?['identificationId'] ??
                              _profileData?['ngoId'] ??
                              'N/A',
                        ),
                      ]),
                      _buildProfileSection('About', [
                        _buildProfileItem(
                          Icons.info_rounded,
                          'Description',
                          _profileData?['donorabout'] ??
                              _profileData?['reciabout'] ??
                              'No description available',
                        ),
                      ]),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }
}
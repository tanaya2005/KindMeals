// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../config/api_config.dart';
import 'package:flutter/foundation.dart';
import '../../utils/date_time_helper.dart';
import '../../services/location_service.dart';

class PostDonationScreen extends StatefulWidget {
  const PostDonationScreen({super.key});

  @override
  State<PostDonationScreen> createState() => _PostDonationScreenState();
}

class _PostDonationScreenState extends State<PostDonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _foodNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _apiService = ApiService();

  String? _selectedFoodType;
  File? _foodImage;
  bool _isLoading = false;
  bool _needsVolunteer = false;
  DateTime? _expiryDateTime;
  bool _isUserDonor = false;
  bool _isCheckingUserType = true;
  String _errorMessage = '';
  double? _latitude;
  double? _longitude;
  bool _isGettingLocation = false;

  final List<String> _foodTypes = ['veg', 'nonveg', 'jain'];

  @override
  void initState() {
    super.initState();
    // Print API configuration for debugging
    ApiConfig.printAPIConfig();
    _checkUserType();
  }

  Future<void> _checkUserType() async {
    try {
      setState(() {
        _isCheckingUserType = true;
        _errorMessage = '';
      });

      if (kDebugMode) {
        print('DEBUG: Checking user type and fetching profile...');
      }
      final currentUser = FirebaseAuth.instance.currentUser;
      if (kDebugMode) {
        print('DEBUG: Current Firebase user: ${currentUser?.uid}');
      }

      final userProfile = await _apiService.getDirectUserProfile();
      if (kDebugMode) {
        print('DEBUG: User profile received: ${userProfile.toString()}');
      }

      // Store the user profile for later use

      final userType = userProfile['userType'] ?? '';

      // Check if profile data is available
      if (userProfile.containsKey('profile') &&
          userProfile['profile'] != null &&
          userProfile['profile'].containsKey('_id')) {
        if (kDebugMode) {
          print('DEBUG: MongoDB ID: ${userProfile['profile']['_id']}');
        }

        // If the user has a stored location, use that as the default
        if (userProfile['profile'].containsKey('latitude') &&
            userProfile['profile'].containsKey('longitude')) {
          setState(() {
            _latitude = userProfile['profile']['latitude'];
            _longitude = userProfile['profile']['longitude'];
            if (kDebugMode) {
              print('Using stored location: $_latitude, $_longitude');
            }
          });
        }

        // If the user has a stored address, use that as the default
        if (userProfile['profile'].containsKey('address') &&
            userProfile['profile']['address'] != null) {
          _addressController.text = userProfile['profile']['address'];
        }
      } else {
        if (kDebugMode) {
          print('WARNING: MongoDB ID not found in profile data');
        }
      }

      // Check if the user is a donor
      if (userType.toLowerCase() != 'donor') {
        setState(() {
          _isUserDonor = false;
          _errorMessage =
              'You need to register as a donor to post donations. Please update your profile or contact support.';
          _isCheckingUserType = false;
        });
        return;
      }

      // If we get here, the user is a donor in the directdonors collection
      setState(() {
        _isUserDonor = true;
        _isCheckingUserType = false;
      });

      if (kDebugMode) {
        print('DEBUG: User type check completed. Is Donor: $_isUserDonor');
      }
    } catch (e) {
      if (kDebugMode) {
        print('DEBUG: User type check error: $e');
      }
      setState(() {
        _isUserDonor = false;
        _errorMessage =
            'Could not verify your account type. Please try again later.';
        _isCheckingUserType = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // Reduced quality to prevent large file sizes
        maxWidth: 800,
        maxHeight: 800,
      );
      if (image != null) {
        setState(() {
          _foodImage = File(image.path);
        });
        if (kDebugMode) {
          print('Image selected: ${image.path}');
        }
        if (kDebugMode) {
          print('Image size: ${await _foodImage!.length()} bytes');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _getLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
        });

        // Attempt to get the address from coordinates
        final address = await LocationService.getAddressFromCoordinates(
            position.latitude, position.longitude);
        if (address != null && address.isNotEmpty) {
          setState(() {
            _addressController.text = address;
          });

          if (kDebugMode) {
            print('Address updated: $address');
          }
        } else {
          if (kDebugMode) {
            print('Could not get address from coordinates');
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Could not get your location. Please ensure location services are enabled.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting location: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
        });
      }
    }
  }

  Future<void> _selectDateTime() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        // Create DateTime object in local time (which should match IST on the device)
        final newDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        setState(() {
          _expiryDateTime = newDateTime;
        });

        if (kDebugMode) {
          print('====== SELECTED DATETIME DEBUG ======');
          print('Selected date/time (local): $_expiryDateTime');
          print('Current time (local): ${DateTime.now()}');
          // Calculate the offset from current time
          final difference = _expiryDateTime!.difference(DateTime.now());
          print(
              'Time difference from now: ${difference.inHours}h ${difference.inMinutes % 60}m');
          // For debugging purposes, also show in UTC
          print('Selected date/time (UTC): ${_expiryDateTime!.toUtc()}');
          print(
              'ISO8601 string for API: ${DateTimeHelper.toISOString(_expiryDateTime!)}');
          print('==================================');
        }
      }
    }
  }

  void _submitDonation() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Validate required fields that might not be caught by form validation
      if (_expiryDateTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a valid expiry date and time'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedFoodType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a food type'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // If we have an address but no coordinates, try to get coordinates from the address
      if (_latitude == null && _addressController.text.isNotEmpty) {
        try {
          final coords = await LocationService.getCoordinatesFromAddress(
              _addressController.text);
          if (coords != null) {
            setState(() {
              _latitude = coords['latitude'];
              _longitude = coords['longitude'];
            });
            if (kDebugMode) {
              print('Coordinates from address: $_latitude, $_longitude');
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Could not get coordinates from address: $e');
          }
          // Continue without coordinates
        }
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Make sure we reload the user before posting
        await FirebaseAuth.instance.currentUser?.reload();

        // Force token refresh to ensure we have the latest token
        await FirebaseAuth.instance.currentUser?.getIdToken(true);

        // Add note to explain volunteer option to users
        if (_needsVolunteer) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Note: When your donation is accepted by a recipient, they will be able to request a volunteer for delivery.'),
              duration: Duration(seconds: 5),
            ),
          );
        }

        await _apiService.createDonation(
          foodName: _foodNameController.text,
          quantity: int.parse(_quantityController.text),
          description: _descriptionController.text,
          expiryDateTime:
              _expiryDateTime!, // Now safe to use ! since we checked above
          foodType: _selectedFoodType!,
          address: _addressController.text,
          needsVolunteer: _needsVolunteer,
          foodImage: _foodImage,
          latitude: _latitude,
          longitude: _longitude,
        );

        setState(() {
          _isLoading = false;
          _foodImage = null;
        });

        _formKey.currentState!.reset();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Donation posted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        String errorMessage = 'Failed to post donation. Please try again.';

        // Handle specific authentication errors
        if (e.toString().contains('User not found in database') ||
            e.toString().contains('Authentication error') ||
            e.toString().contains('authentication token')) {
          errorMessage =
              'Authentication error: Please sign out and sign in again to refresh your credentials.';

          // Show a dialog with more detailed instructions
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Authentication Error'),
              content: const Text(
                  'Your donor profile could not be verified. This could happen if:\n\n'
                  '1. You recently registered and your profile is not fully synced\n'
                  '2. Your authentication token has expired\n\n'
                  'Please sign out and sign back in to refresh your credentials.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
                TextButton(
                  onPressed: () async {
                    // Sign out and navigate to login
                    await FirebaseAuth.instance.signOut();
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text('Sign Out Now'),
                ),
              ],
            ),
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );

        if (kDebugMode) {
          print('Error posting donation: $e');
        }
      }
    }
  }

  Future<void> _signOut() async {
    try {
      setState(() {
        _isLoading = true;
      });

      await FirebaseAuth.instance.signOut();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signed out successfully. Please sign in again.'),
            backgroundColor: Colors.blue,
          ),
        );

        // Navigate to login screen
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $e'),
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

  Future<void> _refreshAuthState() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Force token refresh
        await currentUser.reload();
        await currentUser.getIdToken(true);

        // Re-check user type
        await _checkUserType();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Authentication refreshed!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('No user is signed in');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error refreshing authentication: $e'),
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

  @override
  Widget build(BuildContext context) {
    if (_isCheckingUserType) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Post Donation'),
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Donation'),
        centerTitle: true,
      ),
      body: _errorMessage.isNotEmpty && !_isUserDonor
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 70,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage,
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _refreshAuthState,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh Authentication'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _signOut,
                      icon: const Icon(Icons.logout),
                      label: const Text('Sign Out & Sign In Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/profile');
                      },
                      icon: const Icon(Icons.person_add),
                      label: const Text('Go to Profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Go Back'),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Note: If you just registered, please log out and log back in to refresh your profile status.",
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: _checkUserType,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh Status'),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: _foodImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    _foodImage!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(
                                  Icons.add_a_photo,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _foodNameController,
                        decoration: InputDecoration(
                          labelText: 'Food Name',
                          prefixIcon: const Icon(Icons.fastfood),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter food name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _quantityController,
                        decoration: InputDecoration(
                          labelText: 'Quantity',
                          prefixIcon: const Icon(Icons.numbers),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter quantity';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          prefixIcon: const Icon(Icons.description),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedFoodType,
                        decoration: InputDecoration(
                          labelText: 'Food Type',
                          prefixIcon: const Icon(Icons.category),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        items: _foodTypes.map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedFoodType = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select food type';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Pickup Address (Click to detect)',
                          prefixIcon: const Icon(Icons.location_on),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixIcon: IconButton(
                            icon: _isGettingLocation
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.green,
                                    ),
                                  )
                                : Icon(Icons.my_location, color: Colors.green),
                            onPressed: _isGettingLocation ? null : _getLocation,
                            tooltip: 'Get Current Location',
                          ),
                        ),
                        onTap: _isGettingLocation ? null : _getLocation,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please get pickup address by clicking the location button';
                          }
                          return null;
                        },
                      ),
                      if (_latitude != null && _longitude != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                          child: Text(
                            'Location: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      _buildDateTimeField(),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Need Volunteer for Delivery'),
                        value: _needsVolunteer,
                        onChanged: (bool value) {
                          setState(() {
                            _needsVolunteer = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _submitDonation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                'Post Donation',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildDateTimeField() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expiry Date & Time *',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _selectDateTime,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _expiryDateTime != null
                          ? DateTimeHelper.formatDateTime(_expiryDateTime!)
                          : 'Select expiry date and time',
                      style: TextStyle(
                        color: _expiryDateTime != null
                            ? Colors.black87
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
          if (_expiryDateTime != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  'Local time: ${_expiryDateTime!.hour}:${_expiryDateTime!.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}

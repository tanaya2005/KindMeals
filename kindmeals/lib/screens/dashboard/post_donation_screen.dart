import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/api_service.dart';

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

  final List<String> _foodTypes = ['veg', 'nonveg', 'jain'];

  @override
  void initState() {
    super.initState();
    _checkUserType();
  }

  Future<void> _checkUserType() async {
    try {
      setState(() {
        _isCheckingUserType = true;
        _errorMessage = '';
      });

      print('DEBUG: Checking user type...');
      final userProfile = await _apiService.getDirectUserProfile();
      print('DEBUG: User profile received: ${userProfile.toString()}');
      final userType = userProfile['userType'] ?? '';

      if (userType.toLowerCase() != 'donor') {
        setState(() {
          _isUserDonor = false;
          _errorMessage =
              'You need to register as a donor to post donations. Please update your profile or contact support.';
          _isCheckingUserType = false;
        });
        return;
      }

      // Check if donor profile exists
      try {
        print('DEBUG: Checking donor profile...');
        await _apiService.getDonorProfile();
        setState(() {
          _isUserDonor = true;
          _isCheckingUserType = false;
        });
      } catch (e) {
        print('DEBUG: Donor profile check failed: $e');
        setState(() {
          _isUserDonor = false;
          _errorMessage =
              'Your donor profile was not found in our system. Please ensure you have completed registration as a donor.';
          _isCheckingUserType = false;
        });
      }

      print('DEBUG: User type check completed. Is Donor: $_isUserDonor');
    } catch (e) {
      print('DEBUG: User type check error: $e');
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
        print('Image selected: ${image.path}');
        print('Image size: ${await _foodImage!.length()} bytes');
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting image: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
        setState(() {
          _expiryDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _handleSubmit() async {
    print('DEBUG: Submit button pressed');
    if (!_isUserDonor) {
      print('DEBUG: Submission attempt by non-donor user');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Only donors can post donations. Please register as a donor to continue.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      if (_expiryDateTime == null) {
        print('DEBUG: Expiry date time not selected');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select expiry date and time'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedFoodType == null) {
        print('DEBUG: Food type not selected');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a food type'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Validate image if provided
        if (_foodImage != null) {
          final String extension =
              _foodImage!.path.split('.').last.toLowerCase();
          print('DEBUG: Image extension: $extension');
          if (!['jpg', 'jpeg', 'png'].contains(extension)) {
            throw Exception('Only JPG, JPEG and PNG images are supported');
          }
        }

        print('DEBUG: All validation passed, creating donation with:');
        print('DEBUG: Food name: ${_foodNameController.text}');
        print('DEBUG: Quantity: ${_quantityController.text}');
        print('DEBUG: Food type: $_selectedFoodType');
        print('DEBUG: Description: ${_descriptionController.text}');
        print('DEBUG: Address: ${_addressController.text}');
        print('DEBUG: Needs volunteer: $_needsVolunteer');
        print('DEBUG: Expiry date: $_expiryDateTime');
        print('DEBUG: Image path: ${_foodImage?.path}');
        print('DEBUG: Calling API to create donation...');

        await _apiService.createDonation(
          foodName: _foodNameController.text,
          quantity: int.parse(_quantityController.text),
          description: _descriptionController.text,
          expiryDateTime: _expiryDateTime!,
          foodType: _selectedFoodType!,
          address: _addressController.text,
          needsVolunteer: _needsVolunteer,
          foodImage: _foodImage,
        );

        print('DEBUG: Donation created successfully!');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Donation posted successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(16),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        print('DEBUG ERROR: Error posting donation: $e');

        String errorMsg = e.toString().replaceAll('Exception: ', '');
        // Check for common errors
        if (errorMsg.contains('User not found in database')) {
          print('DEBUG: User not found in database error detected');
          errorMsg =
              'Your donor profile was not found. Please ensure you have registered as a donor.';

          // Set state to show the error screen
          setState(() {
            _isUserDonor = false;
            _errorMessage = errorMsg;
          });
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $errorMsg'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
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
    } else {
      print('DEBUG: Form validation failed');
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
                        decoration: InputDecoration(
                          labelText: 'Pickup Address',
                          prefixIcon: const Icon(Icons.location_on),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter pickup address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: const Text('Expiry Date & Time'),
                        subtitle: Text(
                          _expiryDateTime != null
                              ? '${_expiryDateTime!.day}/${_expiryDateTime!.month}/${_expiryDateTime!.year} ${_expiryDateTime!.hour}:${_expiryDateTime!.minute}'
                              : 'Not set',
                        ),
                        leading: const Icon(Icons.access_time),
                        onTap: _selectDateTime,
                      ),
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
                        onPressed: _isLoading ? null : _handleSubmit,
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

  @override
  void dispose() {
    _foodNameController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}

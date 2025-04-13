// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';

// class PostDonationScreen extends StatefulWidget {
//   const PostDonationScreen({super.key});

//   @override
//   State<PostDonationScreen> createState() => _PostDonationScreenState();
// }

// class _PostDonationScreenState extends State<PostDonationScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _foodNameController = TextEditingController();
//   final _quantityController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _locationController = TextEditingController();

//   DateTime? _expiryDateTime;
//   String? _selectedFoodType;
//   File? _foodImage;
//   bool _isLoading = false;
//   bool _volunteerNeeded = false;

//   final List<String> _foodTypes = ['Vegetarian', 'Non-Vegetarian', 'Jain'];

//   Future<void> _pickImage() async {
//     final ImagePicker picker = ImagePicker();
//     final XFile? image = await picker.pickImage(source: ImageSource.gallery);
//     if (image != null) {
//       setState(() {
//         _foodImage = File(image.path);
//       });
//     }
//   }

//   Future<void> _selectDateTime() async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 7)),
//     );
//     if (picked != null) {
//       final TimeOfDay? pickedTime = await showTimePicker(
//         context: context,
//         initialTime: TimeOfDay.now(),
//       );
//       if (pickedTime != null) {
//         setState(() {
//           _expiryDateTime = DateTime(
//             picked.year,
//             picked.month,
//             picked.day,
//             pickedTime.hour,
//             pickedTime.minute,
//           );
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Post Donation'), centerTitle: true),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 GestureDetector(
//                   onTap: _pickImage,
//                   child: Container(
//                     height: 200,
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade200,
//                       borderRadius: BorderRadius.circular(10),
//                       image:
//                           _foodImage != null
//                               ? DecorationImage(
//                                 image: FileImage(_foodImage!),
//                                 fit: BoxFit.cover,
//                               )
//                               : null,
//                     ),
//                     child:
//                         _foodImage == null
//                             ? const Center(
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(
//                                     Icons.add_photo_alternate,
//                                     size: 50,
//                                     color: Colors.grey,
//                                   ),
//                                   SizedBox(height: 10),
//                                   Text(
//                                     'Tap to add food image',
//                                     style: TextStyle(
//                                       color: Colors.grey,
//                                       fontSize: 16,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             )
//                             : null,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   controller: _foodNameController,
//                   decoration: InputDecoration(
//                     labelText: 'Food Name',
//                     prefixIcon: const Icon(Icons.fastfood),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter food name';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _quantityController,
//                   decoration: InputDecoration(
//                     labelText: 'Quantity',
//                     prefixIcon: const Icon(Icons.scale),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   keyboardType: TextInputType.number,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter quantity';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _descriptionController,
//                   decoration: InputDecoration(
//                     labelText: 'Description',
//                     prefixIcon: const Icon(Icons.description),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   maxLines: 3,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter description';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _locationController,
//                   decoration: InputDecoration(
//                     labelText: 'Location',
//                     prefixIcon: const Icon(Icons.location_on),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter location';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 InkWell(
//                   onTap: _selectDateTime,
//                   child: InputDecorator(
//                     decoration: InputDecoration(
//                       labelText: 'Expiry Date & Time',
//                       prefixIcon: const Icon(Icons.calendar_today),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     child: Text(
//                       _expiryDateTime != null
//                           ? '${_expiryDateTime!.day}/${_expiryDateTime!.month}/${_expiryDateTime!.year} ${_expiryDateTime!.hour}:${_expiryDateTime!.minute}'
//                           : 'Select date and time',
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 DropdownButtonFormField<String>(
//                   value: _selectedFoodType,
//                   decoration: InputDecoration(
//                     labelText: 'Food Type',
//                     prefixIcon: const Icon(Icons.category),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   items:
//                       _foodTypes.map((String type) {
//                         return DropdownMenuItem<String>(
//                           value: type,
//                           child: Text(type),
//                         );
//                       }).toList(),
//                   onChanged: (String? newValue) {
//                     setState(() {
//                       _selectedFoodType = newValue;
//                     });
//                   },
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please select food type';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 SwitchListTile(
//                   title: const Text('Volunteer Needed'),
//                   subtitle: const Text(
//                     'Check if you need a volunteer for delivery',
//                   ),
//                   value: _volunteerNeeded,
//                   onChanged: (bool value) {
//                     setState(() {
//                       _volunteerNeeded = value;
//                     });
//                   },
//                 ),
//                 const SizedBox(height: 30),
//                 ElevatedButton(
//                   onPressed:
//                       _isLoading
//                           ? null
//                           : () {
//                             if (_formKey.currentState!.validate()) {
//                               setState(() {
//                                 _isLoading = true;
//                               });
//                               // TODO: Implement donation posting logic
//                             }
//                           },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     padding: const EdgeInsets.symmetric(vertical: 15),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   child:
//                       _isLoading
//                           ? const CircularProgressIndicator(color: Colors.white)
//                           : const Text(
//                             'Post Donation',
//                             style: TextStyle(fontSize: 18, color: Colors.white),
//                           ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _foodNameController.dispose();
//     _quantityController.dispose();
//     _descriptionController.dispose();
//     _locationController.dispose();
//     super.dispose();
//   }
// }


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

  final List<String> _foodTypes = ['veg', 'nonveg', 'jain'];

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
    if (_formKey.currentState!.validate()) {
      if (_expiryDateTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select expiry date and time'),
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

      setState(() {
        _isLoading = true;
      });

      try {
        // Validate image if provided
        if (_foodImage != null) {
          final String extension =
              _foodImage!.path.split('.').last.toLowerCase();
          if (!['jpg', 'jpeg', 'png'].contains(extension)) {
            throw Exception('Only JPG, JPEG and PNG images are supported');
          }
        }

        print('Creating donation with:');
        print('Food name: ${_foodNameController.text}');
        print('Quantity: ${_quantityController.text}');
        print('Food type: $_selectedFoodType');
        print('Expiry date: $_expiryDateTime');
        print('Image: ${_foodImage?.path}');

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
        print('Error posting donation: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Donation'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
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
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Post Donation',
                          style: TextStyle(fontSize: 18, color: Colors.white),
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

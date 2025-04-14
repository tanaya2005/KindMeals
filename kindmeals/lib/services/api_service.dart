import 'package:firebase_auth/firebase_auth.dart';
import '../config/api_config.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  static const String baseUrl = ApiConfig.apiBaseUrl;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper method to get auth headers
  Map<String, String> get _headers {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${user.uid}',
    };
  }

  // Helper method to get auth headers with token
  Future<Map<String, String>> get _authHeaders async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }
    final idToken = await user.getIdToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $idToken',
    };
  }

  // Auth Methods
  Future<void> registerUser(String role) async {
    // This method is now just a placeholder for backward compatibility
    // We'll directly register the user in their respective collection
    print(
        'Skipping generic user registration, will directly register in specific role collection');
  }

  Future<void> deleteUser() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user found');

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/user'),
        headers: await _authHeaders,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete user: ${response.body}');
      }
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }

  Future<bool> isUserDeleted() async {
    final user = _auth.currentUser;
    if (user == null) return true; // If no user, consider it deleted

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/check'),
        headers: await _authHeaders,
      );

      // If we get a 404, the user is deleted
      return response.statusCode == 404;
    } catch (e) {
      print('Error checking if user is deleted: $e');
      return false; // If there's an error, assume user still exists
    }
  }

  // Get user profile data
  Future<Map<String, dynamic>> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user found');

    try {
      print('Fetching user profile for: ${user.uid}');
      final response = await http.get(
        Uri.parse('$baseUrl/user/profile'),
        headers: await _authHeaders,
      );

      print('Profile response status: ${response.statusCode}');
      print('Profile response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch user profile: ${response.body}');
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      rethrow;
    }
  }

  // Register directly to donor collection
  Future<void> registerDonor({
    required String name,
    required String orgName,
    required String identificationId,
    required String address,
    required String contact,
    required String type,
    String? about,
    double? latitude,
    double? longitude,
    File? profileImage,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user found');

    try {
      print('=== DEBUG: Starting Donor Registration ===');
      print('Firebase UID: ${user.uid}');
      print('Firebase Email: ${user.email}');

      final idToken = await user.getIdToken();

      // Create multipart request for sending form data with file
      final request = http.MultipartRequest(
          'POST', Uri.parse('$baseUrl/direct/donor/register'));

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $idToken';

      // Add text fields
      request.fields['firebaseUid'] = user.uid;
      request.fields['email'] = user.email ?? '';
      request.fields['donorname'] = name;
      request.fields['orgName'] = orgName;
      request.fields['identificationId'] = identificationId;
      request.fields['donoraddress'] = address;
      request.fields['donorcontact'] = contact;
      request.fields['type'] = type;
      if (about != null) request.fields['donorabout'] = about;
      if (latitude != null) request.fields['latitude'] = latitude.toString();
      if (longitude != null) request.fields['longitude'] = longitude.toString();

      // Add profile image if provided
      if (profileImage != null) {
        print('Adding profile image to request: ${profileImage.path}');
        final fileName = profileImage.path.split('/').last;
        final extension = fileName.split('.').last.toLowerCase();

        // Determine content type
        String contentType;
        if (extension == 'png') {
          contentType = 'image/png';
        } else {
          contentType = 'image/jpeg';
        }

        // Add file to request
        request.files.add(
          await http.MultipartFile.fromPath(
            'profileImage',
            profileImage.path,
            contentType: MediaType.parse(contentType),
          ),
        );
      } else {
        print('No profile image provided');
      }

      // Send the request
      print(
          'Sending registration request with ${request.fields.length} fields and ${request.files.length} files');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 201) {
        throw Exception('Failed to register donor: ${response.body}');
      }
    } catch (e) {
      print('Error during donor registration: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDonorProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/donor/profile'),
      headers: await _authHeaders,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get donor profile: ${response.body}');
    }

    return jsonDecode(response.body);
  }

  Future<void> updateDonorProfile({
    String? name,
    String? orgName,
    String? address,
    String? contact,
    String? about,
    double? latitude,
    double? longitude,
    File? profileImage,
  }) async {
    if (profileImage == null) {
      // Use simple PUT request if no image is provided
      final response = await http.put(
        Uri.parse('$baseUrl/donor/profile'),
        headers: await _authHeaders,
        body: jsonEncode({
          if (name != null) 'donorname': name,
          if (orgName != null) 'orgName': orgName,
          if (address != null) 'donoraddress': address,
          if (contact != null) 'donorcontact': contact,
          if (about != null) 'donorabout': about,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update donor profile: ${response.body}');
      }
    } else {
      // Use direct API with image upload support
      await updateDirectDonorProfile(
        name: name,
        orgName: orgName,
        address: address,
        contact: contact,
        about: about,
        latitude: latitude,
        longitude: longitude,
        profileImage: profileImage,
      );
    }
  }

  // Register directly to recipient collection
  Future<void> registerRecipient({
    required String name,
    required String ngoName,
    required String ngoId,
    required String address,
    required String contact,
    required String type,
    String? about,
    double? latitude,
    double? longitude,
    File? profileImage,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user found');

    try {
      print('=== DEBUG: Starting Recipient Registration ===');
      print('Firebase UID: ${user.uid}');
      print('Firebase Email: ${user.email}');

      final idToken = await user.getIdToken();

      // Create multipart request for sending form data with file
      final request = http.MultipartRequest(
          'POST', Uri.parse('$baseUrl/direct/recipient/register'));

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $idToken';

      // Add text fields
      request.fields['firebaseUid'] = user.uid;
      request.fields['email'] = user.email ?? '';
      request.fields['reciname'] = name;
      request.fields['ngoName'] = ngoName;
      request.fields['ngoId'] = ngoId;
      request.fields['reciaddress'] = address;
      request.fields['recicontact'] = contact;
      request.fields['type'] = type;
      if (about != null) request.fields['reciabout'] = about;
      if (latitude != null) request.fields['latitude'] = latitude.toString();
      if (longitude != null) request.fields['longitude'] = longitude.toString();

      // Add profile image if provided
      if (profileImage != null) {
        print('Adding profile image to request: ${profileImage.path}');
        final fileName = profileImage.path.split('/').last;
        final extension = fileName.split('.').last.toLowerCase();

        // Determine content type
        String contentType;
        if (extension == 'png') {
          contentType = 'image/png';
        } else {
          contentType = 'image/jpeg';
        }

        // Add file to request
        request.files.add(
          await http.MultipartFile.fromPath(
            'profileImage',
            profileImage.path,
            contentType: MediaType.parse(contentType),
          ),
        );
      } else {
        print('No profile image provided');
      }

      // Send the request
      print(
          'Sending registration request with ${request.fields.length} fields and ${request.files.length} files');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 201) {
        throw Exception('Failed to register recipient: ${response.body}');
      }
    } catch (e) {
      print('Error during recipient registration: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getRecipientProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/recipient/profile'),
      headers: await _authHeaders,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get recipient profile: ${response.body}');
    }

    return jsonDecode(response.body);
  }

  Future<void> updateRecipientProfile({
    String? name,
    String? ngoName,
    String? address,
    String? contact,
    String? about,
    double? latitude,
    double? longitude,
    File? profileImage,
  }) async {
    if (profileImage == null) {
      // Use simple PUT request if no image is provided
      final response = await http.put(
        Uri.parse('$baseUrl/recipient/profile'),
        headers: await _authHeaders,
        body: jsonEncode({
          if (name != null) 'reciname': name,
          if (ngoName != null) 'ngoName': ngoName,
          if (address != null) 'reciaddress': address,
          if (contact != null) 'recicontact': contact,
          if (about != null) 'reciabout': about,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update recipient profile: ${response.body}');
      }
    } else {
      // Use direct API with image upload support
      await updateDirectRecipientProfile(
        name: name,
        ngoName: ngoName,
        address: address,
        contact: contact,
        about: about,
        latitude: latitude,
        longitude: longitude,
        profileImage: profileImage,
      );
    }
  }

  // Donation Methods
  Future<void> createDonation({
    required String foodName,
    required int quantity,
    required String description,
    required DateTime expiryDateTime,
    required String foodType,
    required String address,
    required bool needsVolunteer,
    File? foodImage,
  }) async {
    try {
      print('DEBUG API: Starting createDonation process...');
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('DEBUG API ERROR: No authenticated user found');
        throw Exception('No authenticated user found');
      }
      print('DEBUG API: Current user UID: ${currentUser.uid}');

      // Get user profile first to find the MongoDB ID
      Map<String, dynamic> userProfile;
      try {
        print('DEBUG API: Fetching direct user profile before donation...');
        userProfile = await getDirectUserProfile();
        print(
            'DEBUG API: User profile found with type: ${userProfile['userType']}');

        if (userProfile['userType'].toString().toLowerCase() != 'donor') {
          print('DEBUG API ERROR: User is not a donor');
          throw Exception('Only donors can post donations');
        }

        // Extract MongoDB ID if available
        print('DEBUG API: User profile ID: ${userProfile['profile']['_id']}');
      } catch (e) {
        print('DEBUG API ERROR: Failed to verify donor profile: $e');
        rethrow;
      }

      // Create the request
      // Use the direct donations create endpoint for direct donors
      final String url = '$baseUrl/direct/donations/create';
      print('DEBUG API: API endpoint: $url');
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Add auth token to headers
      print('DEBUG API: Getting user ID token...');
      await currentUser.reload();
      final String? idTokenRaw = await currentUser.getIdToken(true);
      if (idTokenRaw == null) {
        print('DEBUG ERROR: Failed to get ID token');
        throw Exception('Authentication error: Failed to get ID token');
      }
      final String idToken = idTokenRaw;
      print('DEBUG: ID token received with length: ${idToken.length}');
      request.headers['Authorization'] = 'Bearer $idToken';

      // Add form fields with MongoDB IDs
      print('DEBUG API: Adding form fields to request...');
      request.fields['firebaseUid'] = currentUser.uid;
      request.fields['email'] = currentUser.email ?? '';

      // Add MongoDB ID if available
      if (userProfile.containsKey('profile') &&
          userProfile['profile'] != null &&
          userProfile['profile'].containsKey('_id')) {
        request.fields['donorId'] = userProfile['profile']['_id'].toString();
        print(
            'DEBUG API: Including donor MongoDB ID: ${userProfile['profile']['_id']}');
      }

      request.fields['foodName'] = foodName;
      request.fields['quantity'] = quantity.toString();
      request.fields['description'] = description;
      request.fields['expiryDateTime'] = expiryDateTime.toIso8601String();
      request.fields['foodType'] = foodType;
      request.fields['address'] = address;
      request.fields['needsVolunteer'] = needsVolunteer.toString();

      // Add food image if provided
      if (foodImage != null) {
        print('DEBUG API: Processing food image: ${foodImage.path}');
        final File processedImage = await _processImage(foodImage);
        print('DEBUG API: Image processed: ${processedImage.path}');

        final fileName = processedImage.path.split('/').last;
        final extension = fileName.split('.').last.toLowerCase();

        // Validate file extension
        if (!['jpg', 'jpeg', 'png'].contains(extension)) {
          print('DEBUG API ERROR: Invalid image format: $extension');
          throw Exception('Only JPG, JPEG and PNG images are supported');
        }

        // Determine content type based on extension
        String contentType;
        if (extension == 'png') {
          contentType = 'image/png';
        } else {
          contentType = 'image/jpeg';
        }

        // Add file to request with correct content type
        request.files.add(
          await http.MultipartFile.fromPath(
            'foodImage',
            processedImage.path,
            contentType: MediaType.parse(contentType),
          ),
        );

        print('DEBUG API: Added food image to request');
        print('DEBUG API: Image content type: $contentType');
      } else {
        print('DEBUG API: No food image provided');
      }

      // Send the request
      print('DEBUG API: Sending donation creation request...');
      print(
          'DEBUG API: Request contains ${request.fields.length} fields and ${request.files.length} files');

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      print('DEBUG API: Response status code: ${response.statusCode}');
      print('DEBUG API: Donation creation response: $responseBody');

      if (response.statusCode != 201) {
        print(
            'DEBUG API ERROR: Request failed with status ${response.statusCode}');

        try {
          final responseData = json.decode(responseBody);
          final errorMessage =
              responseData['error']?.toString() ?? 'Failed to create donation';
          print('DEBUG API ERROR: $errorMessage');

          // Special handling for auth errors
          if (response.statusCode == 401 &&
              errorMessage.contains('User not found')) {
            throw Exception(
                'Authentication error: Your account may need to be re-verified. Please log out and log back in.');
          }

          throw Exception(errorMessage);
        } catch (e) {
          if (e is Exception) rethrow;
          throw Exception('Failed to create donation: $responseBody');
        }
      }

      print('DEBUG API: Donation created successfully!');
    } catch (e) {
      print('DEBUG API ERROR: Error in createDonation: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getLiveDonations() async {
    try {
      print('DEBUG: Fetching live donations...');
      // Use the correct route as defined in server.js
      final response = await http.get(
        Uri.parse('$baseUrl/donations/live'),
        headers: await _authHeaders,
      );

      print('DEBUG: Live donations response status: ${response.statusCode}');
      if (response.statusCode != 200) {
        print(
            'DEBUG ERROR: Failed to get live donations. Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to get live donations: ${response.body}');
      }

      final List<dynamic> data = jsonDecode(response.body);
      print('DEBUG: Fetched ${data.length} live donations');
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      print('DEBUG ERROR: Exception in getLiveDonations: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> acceptDonation(String donationId,
      {String? volunteerName}) async {
    try {
      print('DEBUG: Starting acceptDonation process for ID: $donationId');

      // Get current user
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('DEBUG: No authenticated user found');
        throw Exception('No authenticated user found');
      }

      // Get fresh token
      print('DEBUG: Getting fresh ID token...');
      await currentUser.reload();
      final String? idTokenRaw = await currentUser.getIdToken(true);
      if (idTokenRaw == null) {
        print('DEBUG ERROR: Failed to get ID token');
        throw Exception('Authentication error: Failed to get ID token');
      }
      final String idToken = idTokenRaw;
      print('DEBUG: ID token received with length: ${idToken.length}');

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      };
      print('DEBUG: Request headers prepared');

      // Prepare request body
      final Map<String, dynamic> requestBody = {};
      if (volunteerName != null) {
        requestBody['volunteerName'] = volunteerName;
      }
      print('DEBUG: Request body: $requestBody');

      // Make the API call - use the direct endpoint that works with DirectRecipient
      final String url = '$baseUrl/direct/donations/accept/$donationId';
      print('DEBUG: Making POST request to: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print('DEBUG: Response status code: ${response.statusCode}');
      print('DEBUG: Response body: ${response.body}');

      if (response.statusCode != 200) {
        print(
            'DEBUG ERROR: Failed to accept donation. Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to accept donation: ${response.body}');
      }

      print('DEBUG: Donation accepted successfully!');
      return jsonDecode(response.body);
    } catch (e) {
      print('DEBUG ERROR: Exception in acceptDonation: $e');
      rethrow;
    }
  }

  Future<void> addFeedback(String acceptedDonationId, String feedback) async {
    try {
      print('DEBUG: Adding feedback for donation: $acceptedDonationId');

      // Use direct API endpoint that works with DirectRecipient
      final response = await http.post(
        Uri.parse('$baseUrl/direct/donations/feedback/$acceptedDonationId'),
        headers: await _authHeaders,
        body: jsonEncode({
          'feedback': feedback,
        }),
      );

      print('DEBUG: Feedback response status: ${response.statusCode}');
      if (response.statusCode != 200) {
        print(
            'DEBUG ERROR: Failed to add feedback. Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to add feedback: ${response.body}');
      }

      print('DEBUG: Feedback added successfully');
    } catch (e) {
      print('DEBUG ERROR: Exception in addFeedback: $e');
      rethrow;
    }
  }

  // Volunteer Methods
  Future<void> registerVolunteer({
    required String name,
    required String aadharId,
    required String address,
    required String contact,
    String? about,
    double? latitude,
    double? longitude,
    File? profileImage,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/volunteer/register'),
      headers: await _authHeaders,
      body: jsonEncode({
        'volunteerName': name,
        'aadharID': aadharId,
        'volunteeraddress': address,
        'volunteercontact': contact,
        'volunteerabout': about,
        'latitude': latitude,
        'longitude': longitude,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to register volunteer: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> getVolunteerOpportunities() async {
    final response = await http.get(
      Uri.parse('$baseUrl/volunteer/opportunities'),
      headers: await _authHeaders,
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to get volunteer opportunities: ${response.body}');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.cast<Map<String, dynamic>>();
  }

  // Get recipient donation history
  Future<List<Map<String, dynamic>>> getRecipientDonations() async {
    try {
      print('DEBUG: Fetching recipient donations...');
      // Use direct API endpoint that works with DirectRecipient
      final response = await http.get(
        Uri.parse('$baseUrl/direct/recipient/donations'),
        headers: await _authHeaders,
      );

      print(
          'DEBUG: Recipient donations response status: ${response.statusCode}');
      if (response.statusCode != 200) {
        print(
            'DEBUG ERROR: Failed to get recipient donations. Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to get recipient donations: ${response.body}');
      }

      final List<dynamic> data = jsonDecode(response.body);
      print('DEBUG: Fetched ${data.length} accepted donations');
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      print('DEBUG ERROR: Exception in getRecipientDonations: $e');
      rethrow;
    }
  }

  // Get donor donation history
  Future<Map<String, dynamic>> getDonorDonations() async {
    try {
      print('DEBUG: Fetching donor donations history...');
      // Use direct API endpoint that works with DirectDonor
      final response = await http.get(
        Uri.parse('$baseUrl/direct/donor/donations'),
        headers: await _authHeaders,
      );

      print('DEBUG: Donor donations response status: ${response.statusCode}');
      if (response.statusCode != 200) {
        print(
            'DEBUG ERROR: Failed to get donor donations. Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to get donor donations: ${response.body}');
      }

      final Map<String, dynamic> data = jsonDecode(response.body);
      print('DEBUG: Fetched donor donation history:');
      print('  - Active: ${data['active']?.length ?? 0}');
      print('  - Accepted: ${data['accepted']?.length ?? 0}');
      print('  - Expired: ${data['expired']?.length ?? 0}');
      print('  - Combined: ${data['combined']?.length ?? 0}');

      return data;
    } catch (e) {
      print('DEBUG ERROR: Exception in getDonorDonations: $e');
      rethrow;
    }
  }

  // Get user profile data from direct collections
  Future<Map<String, dynamic>> getDirectUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user found');

    try {
      print('=== DEBUG: Getting Direct User Profile ===');
      print('Current Firebase UID: ${user.uid}');
      print('Current User Email: ${user.email}');

      final idToken = await user.getIdToken();
      print('Current ID Token: $idToken');

      print('Fetching direct user profile for: ${user.uid}');
      final response = await http.get(
        Uri.parse('$baseUrl/direct/profile'),
        headers: await _authHeaders,
      );

      print('Profile response status: ${response.statusCode}');
      print('Profile response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch user profile: ${response.body}');
      }
    } catch (e) {
      print('Error fetching direct user profile: $e');
      rethrow;
    }
  }

  // Update direct donor profile
  Future<void> updateDirectDonorProfile({
    File? profileImage,
    String? name,
    String? orgName,
    String? address,
    String? contact,
    String? about,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      final String url = '$baseUrl/direct/donor/profile';
      final request = http.MultipartRequest('PUT', Uri.parse(url));

      // Add auth token to headers
      final String? token = await currentUser.getIdToken();
      request.headers['Authorization'] = 'Bearer $token';

      // Add form fields
      if (name != null) request.fields['donorname'] = name;
      if (orgName != null) request.fields['orgName'] = orgName;
      if (address != null) request.fields['donoraddress'] = address;
      if (contact != null) request.fields['donorcontact'] = contact;
      if (about != null) request.fields['donorabout'] = about;
      if (latitude != null) request.fields['latitude'] = latitude.toString();
      if (longitude != null) request.fields['longitude'] = longitude.toString();

      // Add image if provided
      if (profileImage != null) {
        final String fileName = profileImage.path.split('/').last;
        final String extension = fileName.split('.').last.toLowerCase();

        // Validate file extension
        if (!['jpg', 'jpeg', 'png'].contains(extension)) {
          throw Exception('Only JPG, JPEG and PNG images are supported');
        }

        // Determine content type based on extension
        String contentType;
        if (extension == 'png') {
          contentType = 'image/png';
        } else {
          contentType = 'image/jpeg';
        }

        // Add file to request with correct content type
        request.files.add(
          await http.MultipartFile.fromPath(
            'profileImage',
            profileImage.path,
            contentType: MediaType.parse(contentType),
          ),
        );

        print('Adding profile image: ${profileImage.path}');
        print('Image content type: $contentType');
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      print('Profile update response: ${response.body}');

      if (response.statusCode != 200) {
        final responseData = json.decode(response.body);
        throw Exception(
            responseData['error']?.toString() ?? 'Failed to update profile');
      }
    } catch (e) {
      print('Error in updateDirectDonorProfile: $e');
      rethrow;
    }
  }

  // Update direct recipient profile
  Future<void> updateDirectRecipientProfile({
    File? profileImage,
    String? name,
    String? ngoName,
    String? address,
    String? contact,
    String? about,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      final String url = '$baseUrl/direct/recipient/profile';
      final request = http.MultipartRequest('PUT', Uri.parse(url));

      // Add auth token to headers
      final String? token = await currentUser.getIdToken();
      request.headers['Authorization'] = 'Bearer $token';

      // Add form fields
      if (name != null) request.fields['reciname'] = name;
      if (ngoName != null) request.fields['ngoName'] = ngoName;
      if (address != null) request.fields['reciaddress'] = address;
      if (contact != null) request.fields['recicontact'] = contact;
      if (about != null) request.fields['reciabout'] = about;
      if (latitude != null) request.fields['latitude'] = latitude.toString();
      if (longitude != null) request.fields['longitude'] = longitude.toString();

      // Add image if provided
      if (profileImage != null) {
        final String fileName = profileImage.path.split('/').last;
        final String extension = fileName.split('.').last.toLowerCase();

        // Validate file extension
        if (!['jpg', 'jpeg', 'png'].contains(extension)) {
          throw Exception('Only JPG, JPEG and PNG images are supported');
        }

        // Determine content type based on extension
        String contentType;
        if (extension == 'png') {
          contentType = 'image/png';
        } else {
          contentType = 'image/jpeg';
        }

        // Add file to request with correct content type
        request.files.add(
          await http.MultipartFile.fromPath(
            'profileImage',
            profileImage.path,
            contentType: MediaType.parse(contentType),
          ),
        );

        print('Adding profile image: ${profileImage.path}');
        print('Image content type: $contentType');
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      print('Profile update response: ${response.body}');

      if (response.statusCode != 200) {
        final responseData = json.decode(response.body);
        throw Exception(
            responseData['error']?.toString() ?? 'Failed to update profile');
      }
    } catch (e) {
      print('Error in updateDirectRecipientProfile: $e');
      rethrow;
    }
  }

  // Helper method to process images before upload (resize and compress)
  // This is a simplified version without additional dependencies
  Future<File> _processImage(File image) async {
    try {
      // In a real implementation, you would resize and compress the image
      // For now, we'll return the original image without processing
      print('Image would normally be processed for better performance');
      // Just return the original file as is
      return image;
    } catch (e) {
      print('Error in _processImage: $e');
      return image;
    }
  }

  // Generic user profile update for volunteer or other types
  Future<void> updateUserProfile({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? about,
    File? profileImage,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No authenticated user found');

      // Get user type first
      final profile = await getDirectUserProfile();
      final userType = profile['userType']?.toString().toLowerCase() ?? '';

      if (userType.contains('donor')) {
        await updateDonorProfile(
          name: name,
          contact: phone,
          address: address,
          about: about,
          profileImage: profileImage,
        );
      } else if (userType.contains('recipient')) {
        await updateRecipientProfile(
          name: name,
          contact: phone,
          address: address,
          about: about,
          profileImage: profileImage,
        );
      } else {
        // For volunteers or other user types
        // Implement volunteer profile update when volunteer API is available
        throw Exception('Profile update not supported for this user type yet');
      }
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }
}

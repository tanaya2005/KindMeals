import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.109.46:5000/api';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper method to get auth headers
  Map<String, String> get _headers {
    final user = _auth.currentUser;
    return {
      'Content-Type': 'application/json',
      if (user != null) 'Authorization': 'Bearer ${user.uid}',
    };
  }

  // Auth Methods
  Future<void> registerUser(String role) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user found');

    try {
      print('Attempting to register user with Firebase UID: ${user.uid}');
      print('API URL: $baseUrl/register');

      final response = await http
          .post(
        Uri.parse('$baseUrl/register'),
        headers: _headers,
        body: jsonEncode({
          'firebaseUid': user.uid,
          'email': user.email,
          'role': role.toLowerCase(),
        }),
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception(
              'Connection timeout. Please check your internet connection and try again.');
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 201) {
        throw Exception('Failed to register user: ${response.body}');
      }
    } on http.ClientException catch (e) {
      print('Client Exception during registration: $e');
      if (e.toString().contains('Connection refused')) {
        throw Exception(
            'Cannot connect to server. Please make sure the server is running and try again.');
      }
      rethrow;
    } catch (e) {
      print('Error during registration: $e');
      rethrow;
    }
  }

  Future<void> deleteUser() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user found');

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/user'),
        headers: _headers,
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
        headers: _headers,
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
        headers: _headers,
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

  // Donor Methods
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
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user found');

    try {
      print('Attempting to register donor with Firebase UID: ${user.uid}');
      print('API URL: $baseUrl/donor/register');

      final response = await http.post(
        Uri.parse('$baseUrl/donor/register'),
        headers: _headers,
        body: jsonEncode({
          'donorname': name,
          'orgName': orgName,
          'identificationId': identificationId,
          'donoraddress': address,
          'donorcontact': contact,
          'type': type,
          'donorabout': about,
          'latitude': latitude,
          'longitude': longitude,
        }),
      );

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
      headers: _headers,
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
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/donor/profile'),
      headers: _headers,
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
  }

  // Recipient Methods
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
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user found');

    try {
      print('Attempting to register recipient with Firebase UID: ${user.uid}');
      print('API URL: $baseUrl/recipient/register');

      final response = await http.post(
        Uri.parse('$baseUrl/recipient/register'),
        headers: _headers,
        body: jsonEncode({
          'reciname': name,
          'ngoName': ngoName,
          'ngoId': ngoId,
          'reciaddress': address,
          'recicontact': contact,
          'type': type,
          'reciabout': about,
          'latitude': latitude,
          'longitude': longitude,
        }),
      );

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
      headers: _headers,
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
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/recipient/profile'),
      headers: _headers,
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
  }

  // Donation Methods
  Future<Map<String, dynamic>> createDonation({
    required String foodName,
    required int quantity,
    required String description,
    required DateTime expiryDateTime,
    required String foodType,
    required String address,
    double? latitude,
    double? longitude,
    bool needsVolunteer = false,
    File? foodImage,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/donations/create'),
    );

    request.headers.addAll(_headers);

    request.fields.addAll({
      'foodName': foodName,
      'quantity': quantity.toString(),
      'description': description,
      'expiryDateTime': expiryDateTime.toIso8601String(),
      'foodType': foodType,
      'address': address,
      if (latitude != null) 'latitude': latitude.toString(),
      if (longitude != null) 'longitude': longitude.toString(),
      'needsVolunteer': needsVolunteer.toString(),
    });

    if (foodImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'foodImage',
          foodImage.path,
        ),
      );
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode != 201) {
      throw Exception('Failed to create donation: $responseBody');
    }

    return jsonDecode(responseBody);
  }

  Future<List<Map<String, dynamic>>> getLiveDonations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/donations/live'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get live donations: ${response.body}');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> acceptDonation(String donationId,
      {String? volunteerName}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/donations/accept/$donationId'),
      headers: _headers,
      body: jsonEncode({
        if (volunteerName != null) 'volunteerName': volunteerName,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to accept donation: ${response.body}');
    }

    return jsonDecode(response.body);
  }

  Future<void> addFeedback(String acceptedDonationId, String feedback) async {
    final response = await http.post(
      Uri.parse('$baseUrl/donations/feedback/$acceptedDonationId'),
      headers: _headers,
      body: jsonEncode({
        'feedback': feedback,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add feedback: ${response.body}');
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
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/volunteer/register'),
      headers: _headers,
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
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to get volunteer opportunities: ${response.body}');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.cast<Map<String, dynamic>>();
  }
}

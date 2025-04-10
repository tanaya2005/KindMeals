import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  static const String baseUrl =
      'http://localhost:5000/api'; // Change this to your backend URL

  // Register user in MongoDB after Firebase auth
  Future<void> registerUser(String role) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${user.uid}',
        },
        body: jsonEncode({
          'firebaseUid': user.uid,
          'email': user.email,
          'role': role.toLowerCase(),
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to register user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to register user: $e');
    }
  }

  // Register donor profile
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
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/donor/register'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${user.uid}',
        },
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

      if (response.statusCode != 201) {
        throw Exception('Failed to register donor: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to register donor: $e');
    }
  }

  // Register recipient profile
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
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/recipient/register'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${user.uid}',
        },
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

      if (response.statusCode != 201) {
        throw Exception('Failed to register recipient: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to register recipient: $e');
    }
  }
}

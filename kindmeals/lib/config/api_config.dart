import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // API base URL - use environment variable
  static String get serverBaseUrl =>
      dotenv.env['API_URL'] ?? 'http://192.168.0.101:5000';
  static String get apiBaseUrl => '$serverBaseUrl/api';

  // Debug information
  static void printAPIConfig() {
    print('====== API Configuration ======');
    print('Server Base URL: $serverBaseUrl');
    print('API Base URL: $apiBaseUrl');
    print('==============================');
  }

  // Method to get full image URL
  static String getImageUrl(String? imagePath) {
    // If the path is empty or null, return empty string
    if (imagePath == null || imagePath.isEmpty) return '';

    // If the path already contains the full URL, return it as is
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }

    // If the path starts with /uploads, add the server base URL
    if (imagePath.startsWith('/uploads/')) {
      return serverBaseUrl + imagePath;
    }

    // For any other case, assume it's a relative path and append to server base URL
    return serverBaseUrl + (imagePath.startsWith('/') ? '' : '/') + imagePath;
  }
}

class ApiConfig {
  static const String baseUrl = 'http://192.168.221.180:5000';
  static const String apiBaseUrl = '$baseUrl/api';

  // Image URL helper
  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    return '$baseUrl$imagePath';
  }
}

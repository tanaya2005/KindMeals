class ApiConfig {
  // API base URL - update with your actual server IP address
  static const String serverBaseUrl = 'http://192.168.1.27:5000';
  static const String apiBaseUrl = '$serverBaseUrl/api';

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
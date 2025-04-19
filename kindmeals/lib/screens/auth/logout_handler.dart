import 'package:flutter/material.dart';
import '../../screens/welcome_screen.dart';
import '../../services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogoutHandler {
  final BuildContext context;
  final FirebaseService _firebaseService = FirebaseService();

  LogoutHandler(this.context);

  Future<void> logout() async {
    try {
      // Show loading indicator
      _showLoadingDialog();

      // Clear authentication state
      await _firebaseService.signOut();

      // Clear any local storage/preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Dismiss loading dialog if still showing
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // Navigate to welcome screen and clear navigation stack
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      // Dismiss loading dialog if error occurs
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: $e')),
        );
      }
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Logging out..."),
            ],
          ),
        );
      },
    );
  }
}

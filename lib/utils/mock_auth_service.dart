import 'package:shared_preferences/shared_preferences.dart';
import '../utils/shared_pref_util.dart';
import 'dart:async';

class MockAuthService {
  // Simulate API delay
  static const _simulatedDelay = Duration(milliseconds: 800);

  // Register a new user
  static Future<Map<String, dynamic>> registerUser(
      String name, String email, String password, String phone) async {
    // Simulate network delay
    await Future.delayed(_simulatedDelay);

    // Parse first and last name from full name
    final nameParts = name.split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    // Generate a mock user ID
    final userId = 'mock_${DateTime.now().millisecondsSinceEpoch}';
    final mockToken = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';

    // Save credentials for future login
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mock_${email}_password', password);

    return {
      'success': true,
      'message': 'Registration successful',
      'token': mockToken,
      'user': {
        'id': userId,
        'name': name,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
      }
    };
  }

  // Login user
  static Future<Map<String, dynamic>> loginUser(
      String email, String password) async {
    // Simulate network delay
    await Future.delayed(_simulatedDelay);

    // Get saved password
    final prefs = await SharedPreferences.getInstance();
    final savedPassword = prefs.getString('mock_${email}_password');

    // Check if we have credentials for this email
    if (savedPassword != null) {
      // Check if password matches
      if (savedPassword == password) {
        // Generate name from email if no previous registration
        final userName =
            await SharedPrefUtil.getUserName() ?? email.split('@')[0];
        final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';

        return {
          'success': true,
          'message': 'Login successful',
          'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
          'user': {
            'id': userId,
            'name': userName,
            'email': email,
          }
        };
      } else {
        // Password doesn't match
        return {
          'success': false,
          'message': 'Invalid email or password',
        };
      }
    } else {
      // Auto-register new users for demo purposes
      final userName = email.split('@')[0];
      final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';

      // Save this credential for future logins
      await prefs.setString('mock_${email}_password', password);

      return {
        'success': true,
        'message': 'Login successful (auto-registered)',
        'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        'user': {
          'id': userId,
          'name': userName,
          'email': email,
        }
      };
    }
  }

  // Forgot password
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    // Simulate network delay
    await Future.delayed(_simulatedDelay);

    return {
      'success': true,
      'message':
          'If an account exists with this email, a password reset link has been sent.',
    };
  }

  // Reset password
  static Future<Map<String, dynamic>> resetPassword(
      String token, String password) async {
    // Simulate network delay
    await Future.delayed(_simulatedDelay);

    return {
      'success': true,
      'message': 'Password reset successful',
    };
  }
}

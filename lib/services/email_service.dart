import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EmailService {
  static final String _serviceUrl = dotenv.get('EMAIL_SERVICE_URL', fallback: '');
  static final String _apiKey = dotenv.get('EMAIL_SERVICE_KEY', fallback: '');
  static final String _appName = dotenv.get('APP_NAME', fallback: 'TailorMate');

  static Future<EmailResult> sendVerificationEmail({
    required String toEmail,
    required String verificationCode,
    required String userName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_serviceUrl/send-verification'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'to_email': toEmail,
          'verification_code': verificationCode,
          'user_name': userName,
          'app_name': _appName,
          'expiry_hours': 12,
        }),
      );

      if (response.statusCode == 200) {
        return EmailResult(success: true, message: 'Email envoyé avec succès');
      } else {
        final errorData = jsonDecode(response.body);
        return EmailResult(
          success: false,
          message: errorData['message'] ?? 'Erreur lors de l\'envoi de l\'email',
        );
      }
    } catch (e) {
      return EmailResult(
        success: false,
        message: 'Erreur de connexion: $e',
      );
    }
  }

  static Future<EmailResult> sendWelcomeEmail({
    required String toEmail,
    required String userName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_serviceUrl/send-welcome'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'to_email': toEmail,
          'user_name': userName,
          'app_name': _appName,
        }),
      );

      if (response.statusCode == 200) {
        return EmailResult(success: true, message: 'Email de bienvenue envoyé');
      } else {
        return EmailResult(
          success: false,
          message: 'Erreur lors de l\'envoi de l\'email de bienvenue',
        );
      }
    } catch (e) {
      return EmailResult(
        success: false,
        message: 'Erreur de connexion: $e',
      );
    }
  }
}

class EmailResult {
  final bool success;
  final String message;

  EmailResult({required this.success, required this.message});
}
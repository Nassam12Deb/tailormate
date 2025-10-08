import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EmailJSService {
  static final String _baseUrl = 'https://api.emailjs.com/api/v1.0/email/send';
  static final String _serviceId = dotenv.get('EMAILJS_SERVICE_ID', fallback: '');
  static final String _templateIdVerification = dotenv.get('EMAILJS_TEMPLATE_ID_VERIFICATION', fallback: '');
  static final String _publicKey = dotenv.get('EMAILJS_PUBLIC_KEY', fallback: '');
  static final String _appName = dotenv.get('APP_NAME', fallback: 'TailorMate');

  static Future<EmailResult> sendVerificationEmail({
    required String toEmail,
    required String verificationCode,
    required String userName,
  }) async {
    try {
      // Validation des paramètres
      if (_serviceId.isEmpty || _templateIdVerification.isEmpty || _publicKey.isEmpty) {
        return EmailResult(
          success: false,
          message: 'Configuration EmailJS manquante. Vérifiez le fichier .env',
        );
      }

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'origin': 'http://localhost',
        },
        body: jsonEncode({
          'service_id': _serviceId,
          'template_id': _templateIdVerification,
          'user_id': _publicKey,
          'template_params': {
            'to_email': toEmail,
            'user_name': userName,
            'user_email': toEmail,
            'verification_code': verificationCode,
            'app_name': _appName,
          },
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Email de vérification envoyé à: $toEmail');
        return EmailResult(success: true, message: 'Email de vérification envoyé avec succès');
      } else {
        final error = _getErrorDescription(response.statusCode);
        print('❌ Erreur EmailJS: ${response.statusCode} - ${response.body}');
        return EmailResult(
          success: false,
          message: '${error['title']}: ${error['message']}',
        );
      }
    } catch (e) {
      print('❌ Exception EmailJS: $e');
      return EmailResult(
        success: false,
        message: 'Erreur de connexion: $e',
      );
    }
  }

  static Map<String, String> _getErrorDescription(int statusCode) {
    switch (statusCode) {
      case 400:
        return {
          'title': 'Requête invalide',
          'message': 'Vérifiez les paramètres du template'
        };
      case 401:
        return {
          'title': 'Clé API invalide',
          'message': 'Vérifiez vos clés EmailJS dans le fichier .env'
        };
      case 403:
        return {
          'title': 'Accès refusé',
          'message': 'Vérifiez les permissions de votre compte EmailJS'
        };
      case 429:
        return {
          'title': 'Trop de requêtes',
          'message': 'Limite d\'emails dépassée. Réessayez plus tard.'
        };
      default:
        return {
          'title': 'Erreur EmailJS',
          'message': 'Code d\'erreur: $statusCode'
        };
    }
  }

  // Méthode pour tester la configuration
  static Future<EmailResult> testConfiguration() async {
    try {
      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/validate/user'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': _publicKey,
        }),
      );

      if (response.statusCode == 200) {
        return EmailResult(success: true, message: 'Configuration EmailJS valide');
      } else {
        return EmailResult(success: false, message: 'Clé publique EmailJS invalide');
      }
    } catch (e) {
      return EmailResult(success: false, message: 'Erreur de test: $e');
    }
  }

  // Log de configuration pour le débogage
  static void logConfiguration() {
    print('🔧 Configuration EmailJS:');
    print('   Service ID: ${_serviceId.isNotEmpty ? "✓" : "✗"}');
    print('   Template Verification: ${_templateIdVerification.isNotEmpty ? "✓" : "✗"}');
    print('   Public Key: ${_publicKey.isNotEmpty ? "✓" : "✗"}');
    print('   App Name: $_appName');
  }
}

class EmailResult {
  final bool success;
  final String message;

  EmailResult({required this.success, required this.message});
}
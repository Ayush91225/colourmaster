import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyHelper {
  static const String privacyPolicyUrl = "https://maajasolpaints.com/privacy_policy.html";
  static const String termsOfServiceUrl = "https://maajasolpaints.com/terms_of_service.html";
  
  static Future<void> showPrivacyPolicyDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Privacy Policy'),
          content: const SingleChildScrollView(
            child: Text(
              'By using this app, you agree to our Privacy Policy and Terms of Service. '
              'We collect and process your personal data including mobile number, name, '
              'email, address, and Aadhaar details for account verification and service delivery. '
              'Your data is stored securely and used only for loyalty program services.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => _launchUrl(privacyPolicyUrl),
              child: const Text('Read Full Policy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Accept'),
            ),
          ],
        );
      },
    );
  }
  
  static Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }
}
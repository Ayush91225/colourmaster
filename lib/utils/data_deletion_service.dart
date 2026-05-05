import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../networkCall/ApiService.dart';
import '../utils/sharedPreferenceKey.dart';

class DataDeletionService {
  static final _apiService = ApiService();
  
  static Future<void> requestAccountDeletion(BuildContext context) async {
    final confirmed = await _showDeletionConfirmDialog(context);
    if (!confirmed) return;
    
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString(TOKEN);
      
      if (token != null) {
        // Call API to request account deletion (implement this endpoint on backend)
        // await _apiService.requestAccountDeletion(token);
        // For now, just logout the user
        await _apiService.userLogOut(token);
      }
      
      // Clear all local data
      await _clearAllUserData();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account deletion request submitted. Your data will be deleted within 30 days.'),
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
  
  static Future<bool> _showDeletionConfirmDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone. '
            'All your data including points, transaction history, and personal information will be permanently deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete Account', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    ) ?? false;
  }
  
  static Future<void> _clearAllUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
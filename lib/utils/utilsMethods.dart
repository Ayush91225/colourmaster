// ignore_for_file: depend_on_referenced_packages
import 'dart:async';
import 'dart:io';

import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../provider/user_provider.dart';
import '../ui/component/primaryButton.dart';
import '../ui/component/secondaryButton.dart';
import '../ui/component/textView.dart';
import 'global_key.dart';
import 'sharedPreferenceKey.dart';
import 'style/color_constants.dart';
import 'style/text_view_style.dart';

Future<bool> check() async {
  final result = await Connectivity().checkConnectivity();
  return result.contains(ConnectivityResult.mobile) ||
      result.contains(ConnectivityResult.ethernet) ||
      result.contains(ConnectivityResult.wifi);
}

showSuccessToast(BuildContext context, String message) {
  //Your new account has been successfully created
  CherryToast.success(
      shadowColor: Colors.grey[300]!,
      borderRadius: 17,
      animationDuration: const Duration(milliseconds: 500),
      iconWidget: Image.asset(
        'assets/images/check-mark.png',
        width: 40,
        height: 40,
      ),
      animationType: AnimationType.fromTop,
      autoDismiss: true,
      title: Text(message,
          style: TextStyle(
            fontSize: textLabelFontSize_14,
            fontWeight: FontWeight.w400,
            color: ColorConstants.textViewLabeledColor,
          ))).show(context);
}

showFailedToast(BuildContext context, String message) {
  //Your new account has been successfully created
  CherryToast.error(
      shadowColor: Colors.grey[300]!,
      borderRadius: 17,
      animationDuration: const Duration(seconds: 2),
      iconWidget: Image.asset(
        'assets/images/error_icon.png',
        width: 40,
        height: 40,
      ),
      animationType: AnimationType.fromTop,
      autoDismiss: true,
      title: Text(message,
          style: TextStyle(
            fontSize: textLabelFontSize_14,
            fontWeight: FontWeight.w400,
            color: ColorConstants.textViewLabeledColor,
          ))).show(context);
}

showErrorToast(String message) {
  //Your new account has been successfully created
  message = message;
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: ColorConstants.errorTextColor,
      textColor: Colors.white,
      fontSize: 14.0);
}

showWarningToast(String message) {
  //Your new account has been successfully created
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: ColorConstants.warningColor,
      textColor: Colors.white,
      fontSize: 14.0);
}

void showToastMessage(String message) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: ColorConstants.primaryColor,
      textColor: Colors.white,
      fontSize: 14.0);
}

PageTransitionsTheme removeTransitions() {
  return PageTransitionsTheme(
    builders: {
      for (final platform in TargetPlatform.values)
        platform: const _NoTransitionsBuilder(),
    },
  );
}

String getPlatform() {
  String platform = "";
  if (Platform.isAndroid) {
    platform = "android";
  } else if (Platform.isIOS) {
    platform = "ios";
  } else if (Platform.isFuchsia) {
    platform = "fuchsia";
  } else if (Platform.isLinux) {
    platform = "linux";
  } else if (Platform.isMacOS) {
    platform = "macos";
  } else if (Platform.isWindows) {
    platform = "windows";
  }
  return platform;
}

class _NoTransitionsBuilder extends PageTransitionsBuilder {
  const _NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T>? route,
    BuildContext? context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget? child,
  ) {
    return child!;
  }
}

String? validateEmail(String? value) {
  const pattern =
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
  final regex = RegExp(pattern);
  if (value == null || value.trim().isEmpty) {
    return 'Please enter an email address';
  } else if (value.isNotEmpty && !regex.hasMatch(value)) {
    return 'Enter valid email address';
  }
  return null;
}

Future<String?> getUserName() async {
  var userName = "";
  SharedPreferences prefs = await SharedPreferences.getInstance();
  userName = prefs.getString(FULLNAME)!;
  return userName;
}

Future<String?> getUserEmail() async {
  var userEmail = "";
  SharedPreferences prefs = await SharedPreferences.getInstance();
  userEmail = prefs.getString(USEREMAIL)!;
  return userEmail;
}

Future<String?> getUserToken() async {
  var userToken = "";
  SharedPreferences prefs = await SharedPreferences.getInstance();
  userToken = prefs.getString(TOKEN) ?? "";
  return userToken;
}

Future<String?> getUserPhoto() async {
  var userPhoto = "";
  SharedPreferences prefs = await SharedPreferences.getInstance();
  userPhoto = prefs.getString(USERPHOTO) ?? "";
  return userPhoto;
}

checkLoginStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getBool(LOGIN_STATUS) != null) {
    loginStatus = prefs.getBool(LOGIN_STATUS)!;
  }
  return loginStatus;
}

Future<bool> getLoginStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getBool(LOGIN_STATUS) != null) {
    loginStatus = prefs.getBool(LOGIN_STATUS)!;
  }
  return loginStatus;
}

redirectToBrowser(var webUrl) async {
  var webURL = webUrl;
  if (!webUrl.toString().startsWith("http") ||
      !webUrl.toString().startsWith("https")) {
    webURL = "";
    webURL = "https://$webUrl";
  }

  final Uri url = Uri.parse(webURL.toString());
  await launchUrl(url);
}

openWhatsApp(BuildContext context, var whatsAppNumber) async {
  var androidUrl =
      "whatsapp://send?phone=$whatsAppNumber&text=Hi, I need some help";
  var iosUrl =
      "https://wa.me/$whatsAppNumber?text=${Uri.parse('Hi, I need some help')}";
  try {
    if (Platform.isIOS) {
      await launchUrl(Uri.parse(iosUrl));
    } else {
      await launchUrl(Uri.parse(androidUrl));
    }
  } on Exception {
    if (!context.mounted) return;
    showFailedToast(context, 'WhatsApp is not installed.');
  }
}

openEmail(var emailAddress) async {
  final Uri launchUri = Uri(
      scheme: 'mailto',
      path: emailAddress,
      query: encodeQueryParameters(<String, String>{
        'subject': 'Email subject',
      }));
  await launchUrl(launchUri);
}

makePhoneCall(var phone) async {
  final Uri launchUri = Uri(
    scheme: 'tel',
    path: phone,
  );
  await launchUrl(launchUri);
}

String getFormattedDate(var time) {
  DateTime dt1 = DateTime.parse(time.toString());
  return DateFormat("dd/MM/yyyy").format(dt1);
}

String getFormattedDate1(var time) {
  DateTime dt1 = DateTime.parse(time.toString());
  return DateFormat("yyyy/MM/dd").format(dt1);
}

String lastTransactionDate(var date) {
  DateTime dt1 = DateTime.parse(date.toString());
  return DateFormat("dd MMMM, yyyy").format(dt1);
}

String lastTransactionDateOnHome(var date) {
  DateTime dt1 = DateTime.parse(date.toString());
  return DateFormat("dd/MM/yyyy").format(dt1);
}

String? getFormattedTime(var date) {
  DateTime dt1 = DateTime.parse(date.toString());
  return DateFormat('HH:mm a').format(dt1);
}

String? encodeQueryParameters(Map<String, String> params) {
  return params.entries
      .map((MapEntry<String, String> e) =>
          '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');
}

Future<File> fileFromImageUrl(var url) async {
  final response = await http.get(Uri.parse(url));
  final documentDirectory = await getApplicationDocumentsDirectory();
  final file = File(join(documentDirectory.path,
      '${DateTime.now().millisecondsSinceEpoch}img.png'));
  file.writeAsBytesSync(response.bodyBytes);
  return file;
}

logOutDialog(BuildContext context) async {
  return showDialog(
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.5),
    context: context,
    builder: (BuildContext dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F0),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFD8D8D2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B00).withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFF6B00).withOpacity(0.2)),
              ),
              child: const Icon(Icons.logout_rounded, color: Color(0xFFFF6B00), size: 28),
            ),
            const SizedBox(height: 20),
            const Text(
              'Log out?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You will be signed out of your Colour Master account.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF999999),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(dialogContext),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEEE8),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFD8D8D2)),
                    ),
                    alignment: Alignment.center,
                    child: const Text('Cancel',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF666666))),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final navigator = Navigator.of(context);
                    final ok = await check();
                    final token = await getUserToken();
                    if (!context.mounted) return;
                    navigator.pop();
                    if (ok) {
                      Provider.of<UserProvider>(context, listen: false)
                          .userLogout(token, context);
                    } else {
                      showWarningToast('No network connection');
                    }
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B00),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: const Text('Log out',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    ),
  );
}

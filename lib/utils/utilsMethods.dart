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
    context: context,
    builder: (BuildContext dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: ColorConstants.errorTextColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.logout_rounded,
                color: ColorConstants.errorTextColor,
                size: 32,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Logout',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: ColorConstants.blackColor,
                fontFamily: 'Outfit',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Are you sure you want to logout from Color Master?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: ColorConstants.blackButtonColor.withOpacity(0.7),
                fontFamily: 'Outfit',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF6C5CE7), width: 1.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: const Color(0xFF6C5CE7),
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: ColorConstants.errorTextColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: ColorConstants.errorTextColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        check().then((internet) async {
                          getUserToken().then((userToken) async {
                            Navigator.of(dialogContext).pop();
                            final userProvider = Provider.of<UserProvider>(
                                dialogContext,
                                listen: false);
                            if (internet) {
                              userProvider.userLogout(userToken, context);
                            } else {
                              showWarningToast("No network connection");
                            }
                          });
                        });
                      },
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

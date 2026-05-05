// ignore_for_file: depend_on_referenced_packages

import 'package:colourmaster/main_screen.dart';
import 'package:colourmaster/ui/premium_login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'provider/user_provider.dart';
import 'utils/sharedPreferenceKey.dart';
import 'utils/style/color_constants.dart';
import 'utils/utilsMethods.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final bool _isLoading = false;
  late SharedPreferences sharedPreferences;

  @override
  void initState() {
    super.initState();
    initializePref();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
  }

  Future initializePref() async {
    sharedPreferences = await SharedPreferences.getInstance();
    Future.delayed(const Duration(seconds: 2), () => checkLoginStatus(context));
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values); // to re-show bars
  }

  checkLoginStatus(BuildContext context) async {
    if (sharedPreferences.getBool(LOGIN_STATUS) == false ||
        sharedPreferences.getBool(LOGIN_STATUS) == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => const PremiumLoginScreen()),
          (Route<dynamic> route) => false);
    } else {
      check().then((internet) async {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.checkLogin(context, sharedPreferences.getString(TOKEN)) ??
            "";
      });
    }
  }

  redirectToHomeScreen() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (BuildContext context) => const MainScreen(0, "")),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorConstants.bodyBackgroundColor,
        body: Stack(
          children: [
            Align(
                alignment: Alignment.center,
                child: Image.asset(
                    height: 200, width: 200, 'assets/images/logo.png')),
          ],
        )
        //  )
        );
  }
}

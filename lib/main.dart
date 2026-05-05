// ignore_for_file: depend_on_referenced_packages

import 'package:colourmaster/provider/user_provider.dart';
import 'package:colourmaster/premium_splash_screen.dart';
import 'package:colourmaster/utils/premium_theme.dart';
import 'package:colourmaster/utils/connectivity_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));
  
  // Initialize connectivity service
  await ConnectivityService().initialize();
  
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => UserProvider()),
    ChangeNotifierProvider(create: (context) => ConnectivityService()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          title: 'Painter Point',
          theme: PremiumTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          builder: (context, Widget? widget) {
            return MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.0)),
              child: ConnectivityWrapper(
                child: widget!,
              ),
            );
          },
          home: child,
        );
      },
      child: const PremiumSplashScreen(),
    );
  }
}

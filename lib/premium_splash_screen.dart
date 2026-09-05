import 'package:colourmaster/utils/premium_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'provider/user_provider.dart';
import 'ui/premium_login_screen.dart';
import 'utils/sharedPreferenceKey.dart';
import 'utils/utilsMethods.dart';

class PremiumSplashScreen extends StatefulWidget {
  const PremiumSplashScreen({super.key});
  @override
  State<PremiumSplashScreen> createState() => _State();
}

class _State extends State<PremiumSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;
  late Animation<double> _taglineFade;
  late Animation<double> _loaderFade;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.black,
    ));

    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));

    _fade = CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut));

    _scale = Tween(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack)));

    _taglineFade = CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut));

    _loaderFade = CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut));

    _ctrl.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;
    if (prefs.getBool(LOGIN_STATUS) != true) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const PremiumLoginScreen()),
          (_) => false);
    } else {
      check().then((_) {
        if (!mounted) return;
        Provider.of<UserProvider>(context, listen: false)
            .checkLogin(context, prefs.getString(TOKEN));
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final s  = (sw / 390).clamp(0.8, 1.3);

    return Scaffold(
      backgroundColor: AppTheme.black,
      body: Stack(
        children: [
          // Subtle orange radial glow behind logo
          Positioned.fill(
            child: FadeTransition(
              opacity: _fade,
              child: Center(
                child: Container(
                  width: 260 * s,
                  height: 260 * s,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.orange.withOpacity(0.07),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                FadeTransition(
                  opacity: _fade,
                  child: ScaleTransition(
                    scale: _scale,
                    child: Container(
                      width: 88 * s,
                      height: 88 * s,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.black2,
                        border: Border.all(
                            color: AppTheme.orange.withOpacity(0.35),
                            width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.orange.withOpacity(0.12),
                            blurRadius: 40,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(20 * s),
                      child: Image.asset('assets/images/logo.png',
                          fit: BoxFit.contain),
                    ),
                  ),
                ),

                SizedBox(height: 28 * s),

                // App name
                FadeTransition(
                  opacity: _fade,
                  child: Text(
                    'COLOUR MASTER',
                    style: TextStyle(
                      fontSize: 17 * s,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.white,
                      letterSpacing: 5,
                    ),
                  ),
                ),

                SizedBox(height: 10 * s),

                // Orange divider line
                FadeTransition(
                  opacity: _taglineFade,
                  child: Container(
                    width: 32 * s,
                    height: 1.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.transparent,
                        AppTheme.orange,
                        Colors.transparent,
                      ]),
                    ),
                  ),
                ),

                SizedBox(height: 10 * s),

                // Tagline
                FadeTransition(
                  opacity: _taglineFade,
                  child: Text(
                    'REWARDS & LOYALTY',
                    style: TextStyle(
                      fontSize: 10 * s,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.white.withOpacity(0.35),
                      letterSpacing: 3.5,
                    ),
                  ),
                ),

                SizedBox(height: 72 * s),

                // Loader
                FadeTransition(
                  opacity: _loaderFade,
                  child: SizedBox(
                    width: 18 * s,
                    height: 18 * s,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      valueColor: AlwaysStoppedAnimation(
                          AppTheme.orange.withOpacity(0.5)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
  late Animation<double> _slide;
  late Animation<double> _loaderFade;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppTheme.black,
    ));

    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

    _fade = CurvedAnimation(
        parent: _ctrl, curve: const Interval(0.0, 0.65, curve: Curves.easeOut));

    _slide = Tween(begin: 16.0, end: 0.0).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.65, curve: Curves.easeOut)));

    _loaderFade = CurvedAnimation(
        parent: _ctrl, curve: const Interval(0.65, 1.0, curve: Curves.easeOut));

    _ctrl.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(milliseconds: 2200));
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
    final sh = MediaQuery.of(context).size.height;
    final s  = (sw / 390).clamp(0.8, 1.3);

    return Scaffold(
      backgroundColor: AppTheme.black,
      body: Stack(
        children: [
          // ── Centre content ──────────────────────────────────────────────────
          Center(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => Opacity(
                opacity: _fade.value,
                child: Transform.translate(
                  offset: Offset(0, _slide.value),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      Container(
                        width: 80 * s,
                        height: 80 * s,
                        decoration: BoxDecoration(
                          color: AppTheme.black2,
                          borderRadius: BorderRadius.circular(22 * s),
                          border: Border.all(color: AppTheme.black5),
                          boxShadow: const [AppTheme.cardShadow],
                        ),
                        padding: EdgeInsets.all(18 * s),
                        child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                      ),

                      SizedBox(height: 20 * s),

                      // App name
                      Text(
                        'Colour Master',
                        style: TextStyle(
                          fontSize: 22 * s,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.white,
                          letterSpacing: -0.3,
                        ),
                      ),

                      SizedBox(height: 6 * s),

                      // Tagline
                      Text(
                        'Rewards & Loyalty',
                        style: TextStyle(
                          fontSize: 13 * s,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.white30,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Bottom loader ───────────────────────────────────────────────────
          Positioned(
            bottom: sh * 0.1,
            left: 0, right: 0,
            child: AnimatedBuilder(
              animation: _loaderFade,
              builder: (_, __) => Opacity(
                opacity: _loaderFade.value,
                child: Center(
                  child: SizedBox(
                    width: 20 * s, height: 20 * s,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      valueColor: AlwaysStoppedAnimation(AppTheme.orange),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Bottom brand line ───────────────────────────────────────────────
          Positioned(
            bottom: sh * 0.05,
            left: 0, right: 0,
            child: AnimatedBuilder(
              animation: _loaderFade,
              builder: (_, __) => Opacity(
                opacity: _loaderFade.value,
                child: Center(
                  child: Text(
                    'by Maajasolpaints',
                    style: TextStyle(
                      fontSize: 11 * s,
                      color: AppTheme.white30,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

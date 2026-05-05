import 'package:colourmaster/main_screen.dart';
import 'package:colourmaster/utils/premium_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'provider/user_provider.dart';
import 'ui/premium_login_screen.dart';
import 'utils/sharedPreferenceKey.dart';
import 'utils/utilsMethods.dart';

class PremiumSplashScreen extends StatefulWidget {
  const PremiumSplashScreen({super.key});

  @override
  State<PremiumSplashScreen> createState() => _PremiumSplashScreenState();
}

class _PremiumSplashScreenState extends State<PremiumSplashScreen>
    with TickerProviderStateMixin {
  late SharedPreferences sharedPreferences;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    initializePref();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  Future initializePref() async {
    sharedPreferences = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 3));
    checkLoginStatus(context);
  }

  @override
  void dispose() {
    _animationController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with premium styling
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 140,
                        height: 140,
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 50),
              
              // App name with premium typography
              Text(
                'Colour Master',
                style: PremiumTheme.textTheme.displayMedium?.copyWith(
                  color: PremiumTheme.textPrimary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),
              
              const SizedBox(height: 12),
              
              // Tagline with subtle styling
              Text(
                'Premium Rewards Experience',
                style: PremiumTheme.textTheme.titleMedium?.copyWith(
                  color: PremiumTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ).animate().fadeIn(delay: 1200.ms).slideY(begin: 0.2),
              
              const SizedBox(height: 100),
              
              // Premium loading indicator
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: PremiumTheme.primaryColor.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      PremiumTheme.primaryColor,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 1600.ms).scale(delay: 1600.ms),
              
              const SizedBox(height: 24),
              
              Text(
                'Loading your experience...',
                style: PremiumTheme.textTheme.bodyMedium?.copyWith(
                  color: PremiumTheme.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ).animate().fadeIn(delay: 1800.ms),
            ],
          ),
        ),
      ),
    );
  }
}
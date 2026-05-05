import 'dart:io';

import 'package:colourmaster/ui/widget/premium_buttons.dart';
import 'package:colourmaster/utils/premium_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';

import '../provider/user_provider.dart';
import '../utils/utilsMethods.dart';
import 'premium_register_screen.dart';

class PremiumLoginScreen extends StatefulWidget {
  const PremiumLoginScreen({super.key});

  @override
  State<PremiumLoginScreen> createState() => _PremiumLoginScreenState();
}

class _PremiumLoginScreenState extends State<PremiumLoginScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController mobileController = TextEditingController();
  ScrollController scrollController = ScrollController();
  SharedPreferences? sharedPreferences;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
    ));

    mobileController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    mobileController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      barrierDismissible: false,
      dialogStyle: !kIsWeb
          ? Platform.isIOS
              ? UpgradeDialogStyle.cupertino
              : UpgradeDialogStyle.material
          : UpgradeDialogStyle.material,
      child: Scaffold(
        backgroundColor: PremiumTheme.backgroundColor,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Consumer<UserProvider>(
            builder: (context, UserProvider userProvider, child) {
              return SizedBox(
                height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
                child: Column(
                  children: [
                    // Top section with logo
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/logo.png',
                              width: 80,
                              height: 80,
                              fit: BoxFit.contain,
                            ).animate().scale(delay: 200.ms),
                            const SizedBox(height: 16),
                            Text(
                              'Welcome to',
                              style: PremiumTheme.textTheme.bodyLarge?.copyWith(
                                color: PremiumTheme.textSecondary,
                                fontWeight: FontWeight.w400,
                              ),
                            ).animate().fadeIn(delay: 400.ms),
                            const SizedBox(height: 4),
                            Text(
                              'Color Master',
                              style: PremiumTheme.textTheme.headlineLarge?.copyWith(
                                color: PremiumTheme.textPrimary,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ).animate().fadeIn(delay: 600.ms),
                            const SizedBox(height: 8),
                            Text(
                              'Your Premium Rewards Partner',
                              style: PremiumTheme.textTheme.bodyMedium?.copyWith(
                                color: PremiumTheme.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ).animate().fadeIn(delay: 800.ms),
                          ],
                        ),
                      ),
                    ),
                    
                    // Login form section (dock style)
                    Expanded(
                      flex: 2,
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Form(
                            key: formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20),
                                Text(
                                  'Sign In',
                                  style: PremiumTheme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: PremiumTheme.textPrimary,
                                  ),
                                ).animate().slideX(delay: 1000.ms),
                                const SizedBox(height: 8),
                                Text(
                                  'Enter your mobile number to continue',
                                  style: PremiumTheme.textTheme.bodyLarge?.copyWith(
                                    color: PremiumTheme.textSecondary,
                                  ),
                                ).animate().slideX(delay: 1200.ms),
                                const SizedBox(height: 24),
                                
                                Text(
                                  'Mobile Number',
                                  style: PremiumTheme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: PremiumTheme.textPrimary,
                                  ),
                                ).animate().fadeIn(delay: 1400.ms),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: mobileController,
                                  keyboardType: TextInputType.phone,
                                  maxLength: 10,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  decoration: InputDecoration(
                                    hintText: 'Enter your mobile number',
                                    prefixIcon: Container(
                                      margin: const EdgeInsets.all(12),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: PremiumTheme.primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '+91',
                                        style: PremiumTheme.textTheme.titleMedium?.copyWith(
                                          color: PremiumTheme.primaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    counterText: '',
                                  ),
                                  validator: (String? value) {
                                    if (value!.isEmpty) {
                                      return 'Mobile Number Required';
                                    } else if (value.length < 10) {
                                      return 'Please enter a valid 10 digit mobile number';
                                    }
                                    return null;
                                  },
                                ).animate().slideY(delay: 1600.ms),
                                
                                const SizedBox(height: 24),
                                
                                PremiumButton(
                                  text: 'Sign In',
                                  isLoading: userProvider.isLoading,
                                  width: double.infinity,
                                  onPressed: () async {
                                    if (formKey.currentState!.validate()) {
                                      check().then((internet) async {
                                        if (internet) {
                                          FocusManager.instance.primaryFocus?.unfocus();
                                          await userProvider.loginUser(
                                              mobileController.text.toString().trim(),
                                              context);
                                        } else {
                                          showWarningToast("No network connection");
                                        }
                                      });
                                    }
                                  },
                                ).animate().slideY(delay: 1800.ms),
                                
                                const Spacer(),
                                
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Don't have an account? ",
                                      style: PremiumTheme.textTheme.bodyMedium?.copyWith(
                                        color: PremiumTheme.textSecondary,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => const PremiumRegisterScreen()),
                                        );
                                      },
                                      child: Text(
                                        'Sign Up',
                                        style: PremiumTheme.textTheme.bodyMedium?.copyWith(
                                          color: PremiumTheme.primaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ).animate().fadeIn(delay: 2000.ms),
                                
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ).animate().slideY(begin: 0.3, delay: 1000.ms),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
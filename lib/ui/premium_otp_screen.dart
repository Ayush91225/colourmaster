import 'dart:async';

import 'package:colourmaster/ui/widget/premium_buttons.dart' as premium;
import 'package:colourmaster/utils/premium_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import '../models/loginModel/Login.dart';
import '../networkCall/ApiService.dart';
import '../provider/user_provider.dart';
import '../utils/utilsMethods.dart';

class PremiumOTPScreen extends StatefulWidget {
  final String userMobile;
  const PremiumOTPScreen(this.userMobile, {super.key});
  
  @override
  State<PremiumOTPScreen> createState() => _PremiumOTPScreenState();
}

class _PremiumOTPScreenState extends State<PremiumOTPScreen> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  bool enableResend = false;
  int timerMaxSeconds = 30;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
    ));
    
    // Auto-focus on OTP input
    startTimer();
  }

  void _resendCode() {
    setState(() {
      timerMaxSeconds = 30;
      enableResend = false;
    });
    startTimer();
  }

  startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (timerMaxSeconds != 0) {
        setState(() {
          timerMaxSeconds--;
        });
      } else {
        setState(() {
          enableResend = true;
        });
        timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: PremiumTheme.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: PremiumTheme.textPrimary,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(
          color: PremiumTheme.primaryColor,
          width: 2,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: PremiumTheme.backgroundColor,
      body: SafeArea(
        child: Consumer<UserProvider>(
          builder: (context, UserProvider userProvider, child) {
            return Column(
              children: [
                // Header section
                Container(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.arrow_back_rounded,
                              color: PremiumTheme.textPrimary,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Icon(
                        Icons.sms_rounded,
                        color: PremiumTheme.primaryColor,
                        size: 48,
                      ).animate().scale(delay: 200.ms),
                      const SizedBox(height: 24),
                      Text(
                        'Verify Mobile Number',
                        style: PremiumTheme.textTheme.headlineLarge?.copyWith(
                          color: PremiumTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ).animate().fadeIn(delay: 400.ms),
                      const SizedBox(height: 8),
                      Text(
                        'We sent a verification code to',
                        style: PremiumTheme.textTheme.bodyLarge?.copyWith(
                          color: PremiumTheme.textSecondary,
                        ),
                      ).animate().fadeIn(delay: 600.ms),
                      const SizedBox(height: 4),
                      Text(
                        '+91 ${widget.userMobile}',
                        style: PremiumTheme.textTheme.titleLarge?.copyWith(
                          color: PremiumTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ).animate().fadeIn(delay: 800.ms),
                    ],
                  ),
                ),
                
                // OTP form section (dock style)
                Expanded(
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
                          children: [
                            const SizedBox(height: 20),
                            Text(
                              'Enter Verification Code',
                              style: PremiumTheme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: PremiumTheme.textPrimary,
                              ),
                            ).animate().slideX(delay: 1000.ms),
                            
                            const SizedBox(height: 32),
                            
                            Pinput(
                              length: 4,
                              controller: pinController,
                              focusNode: focusNode,
                              autofocus: true,
                              defaultPinTheme: defaultPinTheme,
                              focusedPinTheme: focusedPinTheme,
                              submittedPinTheme: focusedPinTheme,
                              pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                              hapticFeedbackType: HapticFeedbackType.lightImpact,
                              onCompleted: (pin) => _verifyOTP(),
                              onChanged: (value) {
                                if (kDebugMode) {
                                  print('onChanged: $value');
                                }
                              },
                            ).animate().slideY(delay: 1200.ms),
                            
                            const SizedBox(height: 24),
                            
                            Text(
                              'Please enter the 4-digit code sent to your mobile number',
                              style: PremiumTheme.textTheme.bodyMedium?.copyWith(
                                color: PremiumTheme.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ).animate().fadeIn(delay: 1400.ms),
                            
                            const SizedBox(height: 32),
                            
                            premium.PremiumButton(
                              text: 'Verify Code',
                              isLoading: userProvider.isLoading,
                              width: double.infinity,
                              onPressed: () {
                                if (pinController.text.length != 4) {
                                  showWarningToast('Please enter complete OTP');
                                  return;
                                }
                                _verifyOTP();
                              },
                            ).animate().slideY(delay: 1600.ms),
                            
                            const Spacer(),
                            
                            TextButton(
                              onPressed: enableResend ? _resendOTP : null,
                              child: enableResend
                                  ? Text(
                                      'Resend Code',
                                      style: PremiumTheme.textTheme.bodyMedium?.copyWith(
                                        color: PremiumTheme.primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )
                                  : Text(
                                      'Resend code in ${timerMaxSeconds}s',
                                      style: PremiumTheme.textTheme.bodyMedium?.copyWith(
                                        color: PremiumTheme.textTertiary,
                                      ),
                                    ),
                            ).animate().fadeIn(delay: 1800.ms),
                            
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ).animate().slideY(begin: 0.3, delay: 1000.ms),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _verifyOTP() async {
    check().then((internet) async {
      if (internet) {
        FocusManager.instance.primaryFocus?.unfocus();
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.userOTPVerify(
          widget.userMobile,
          pinController.text.toString().trim(),
          context,
        );
        pinController.clear();
        FocusScope.of(context).requestFocus(focusNode);
      } else {
        showWarningToast("No network connection");
      }
    });
  }

  void _resendOTP() async {
    check().then((internet) async {
      if (internet) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.isLoading = true;
        pinController.clear();
        
        Login? verifyOTPRes = await ApiService().resendOTP(widget.userMobile);
        userProvider.isLoading = false;
        
        if (verifyOTPRes!.status == 1) {
          _resendCode();
          if (!context.mounted) return;
          showSuccessToast(context, verifyOTPRes.message!.toString());
        } else {
          setState(() {
            pinController.clear();
          });
          if (!context.mounted) return;
          showFailedToast(context, verifyOTPRes.message!.toString());
        }
      } else {
        showWarningToast("No network connection");
      }
    });
  }
}
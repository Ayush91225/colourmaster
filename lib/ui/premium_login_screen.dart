import 'dart:io';
import 'package:colourmaster/ui/widget/premium_buttons.dart';
import 'package:colourmaster/utils/premium_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';

import '../provider/user_provider.dart';
import '../utils/utilsMethods.dart';
import 'premium_register_screen.dart';

class PremiumLoginScreen extends StatefulWidget {
  const PremiumLoginScreen({super.key});
  @override
  State<PremiumLoginScreen> createState() => _State();
}

class _State extends State<PremiumLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobile  = TextEditingController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: AppTheme.black,
    ));
    _mobile.addListener(() => setState(() {}));
  }

  @override
  void dispose() { _mobile.dispose(); super.dispose(); }

  void _submit(UserProvider p) {
    if (_formKey.currentState!.validate()) {
      check().then((ok) async {
        if (ok) {
          FocusManager.instance.primaryFocus?.unfocus();
          await p.loginUser(_mobile.text.trim(), context);
        } else {
          showWarningToast('No network connection');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      barrierDismissible: false,
      dialogStyle: !kIsWeb
          ? (Platform.isIOS ? UpgradeDialogStyle.cupertino : UpgradeDialogStyle.material)
          : UpgradeDialogStyle.material,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppTheme.black,
        body: Consumer<UserProvider>(
          builder: (ctx, provider, _) => Column(
            children: [
              // ── Top: brand — fills all space above the sheet ──────────
              Expanded(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/logo.png',
                            width: 90, height: 90, fit: BoxFit.contain),
                        const SizedBox(height: 16),
                        const Text('Colour Master',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.white,
                                letterSpacing: -0.3)),
                        const SizedBox(height: 4),
                        Text('Rewards & Loyalty',
                            style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.white.withOpacity(0.3),
                                fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Bottom: form sheet ────────────────────────────────────
              Container(
                decoration: const BoxDecoration(
                  color: AppTheme.black2,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  border: Border(top: BorderSide(color: AppTheme.black5, width: 1)),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Drag handle
                          Center(
                            child: Container(
                              width: 32, height: 3,
                              decoration: BoxDecoration(
                                  color: AppTheme.black5,
                                  borderRadius: BorderRadius.circular(2)),
                            ),
                          ),
                          const SizedBox(height: 20),

                          const Text('Sign in',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.white)),
                          const SizedBox(height: 20),

                          // Phone field
                          TextFormField(
                            controller: _mobile,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(provider),
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            style: const TextStyle(
                                fontSize: 16,
                                color: AppTheme.white,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.5),
                            decoration: InputDecoration(
                              counterText: '',
                              hintText: 'Mobile number',
                              hintStyle: TextStyle(
                                  fontSize: 15,
                                  color: AppTheme.white.withOpacity(0.2),
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.w400),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 14),
                                child: Text('+91',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.orange)),
                              ),
                              prefixIconConstraints: const BoxConstraints(),
                              suffixIcon: _mobile.text.isNotEmpty
                                  ? GestureDetector(
                                      onTap: () => _mobile.clear(),
                                      child: const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Icon(Icons.close_rounded, size: 16, color: Color(0x4DFFFFFF)),
                                      ),
                                    )
                                  : null,
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              if (v.length < 10) return 'Enter a valid 10-digit number';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          PremiumButton(
                            text: 'Continue',
                            isLoading: provider.isLoading,
                            width: double.infinity,
                            height: 56,
                            onPressed: () => _submit(provider),
                          ),
                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("New here?  ",
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.white.withOpacity(0.35))),
                              GestureDetector(
                                onTap: () => Navigator.push(ctx,
                                    MaterialPageRoute(
                                        builder: (_) => const PremiumRegisterScreen())),
                                child: const Text('Create account',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.orange,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

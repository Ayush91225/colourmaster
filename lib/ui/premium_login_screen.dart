import 'dart:io';
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
      statusBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Color(0xFFF5F5F0),
    ));
    _mobile.addListener(_onChanged);
  }

  void _onChanged() { if (mounted) setState(() {}); }

  @override
  void dispose() {
    _mobile.removeListener(_onChanged);
    _mobile.dispose();
    super.dispose();
  }

  void _submit(UserProvider p) {
    if (_formKey.currentState!.validate()) {
      check().then((ok) async {
        if (!mounted) return;
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
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final s  = (sw / 390).clamp(0.8, 1.3);

    return UpgradeAlert(
      barrierDismissible: false,
      dialogStyle: !kIsWeb
          ? (Platform.isIOS ? UpgradeDialogStyle.cupertino : UpgradeDialogStyle.material)
          : UpgradeDialogStyle.material,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppTheme.black,
        body: Consumer<UserProvider>(
          builder: (ctx, provider, _) => SafeArea(
            child: SingleChildScrollView(
              reverse: true, // scrolls up when keyboard opens
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: sh - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Column(children: [

                    // ── Brand area ────────────────────────────────────
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20 * s),
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Container(
                              width: 80 * s, height: 80 * s,
                              decoration: BoxDecoration(
                                color: AppTheme.black2,
                                borderRadius: BorderRadius.circular(22 * s),
                                border: Border.all(color: AppTheme.black5),
                              ),
                              padding: EdgeInsets.all(16 * s),
                              child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                            ),
                            SizedBox(height: 14 * s),
                            Text('Colour Master',
                                style: TextStyle(fontSize: 22 * s,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.white,
                                    letterSpacing: -0.3)),
                            SizedBox(height: 4 * s),
                            Text('Rewards & Loyalty',
                                style: TextStyle(fontSize: 13 * s,
                                    color: AppTheme.white30,
                                    fontWeight: FontWeight.w400)),
                          ]),
                        ),
                      ),
                    ),

                    // ── Form sheet ────────────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.black2,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(28 * s)),
                        border: const Border(top: BorderSide(color: AppTheme.black5)),
                      ),
                      padding: EdgeInsets.fromLTRB(24 * s, 24 * s, 24 * s,
                          MediaQuery.of(context).viewInsets.bottom + 28 * s),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Center(child: Container(
                              width: 36 * s, height: 4 * s,
                              decoration: BoxDecoration(
                                  color: AppTheme.black5,
                                  borderRadius: BorderRadius.circular(2)),
                            )),
                            SizedBox(height: 22 * s),

                            Text('Sign in',
                                style: TextStyle(fontSize: 22 * s,
                                    fontWeight: FontWeight.w700, color: AppTheme.white)),
                            SizedBox(height: 6 * s),
                            Text('Enter your mobile number to continue',
                                style: TextStyle(fontSize: 13 * s, color: AppTheme.white30)),
                            SizedBox(height: 22 * s),

                            // Phone field
                            Container(
                              decoration: BoxDecoration(
                                color: AppTheme.black3,
                                borderRadius: BorderRadius.circular(16 * s),
                                border: Border.all(color: AppTheme.black5),
                              ),
                              child: Row(children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16 * s),
                                  child: Text('+91',
                                      style: TextStyle(fontSize: 15 * s,
                                          fontWeight: FontWeight.w700, color: AppTheme.orange)),
                                ),
                                Container(width: 1, height: 24 * s, color: AppTheme.black5),
                                Expanded(
                                  child: TextFormField(
                                    controller: _mobile,
                                    keyboardType: TextInputType.phone,
                                    maxLength: 10,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _submit(provider),
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    style: TextStyle(fontSize: 16 * s,
                                        color: AppTheme.white, fontWeight: FontWeight.w500,
                                        letterSpacing: 1.5),
                                    decoration: InputDecoration(
                                      counterText: '',
                                      hintText: 'Mobile number',
                                      hintStyle: TextStyle(fontSize: 15 * s,
                                          color: AppTheme.white30, letterSpacing: 0,
                                          fontWeight: FontWeight.w400),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 14 * s, vertical: 16 * s),
                                      suffixIcon: _mobile.text.isNotEmpty
                                          ? GestureDetector(
                                              onTap: () => _mobile.clear(),
                                              child: Icon(Icons.close_rounded,
                                                  size: 16 * s, color: AppTheme.white30),
                                            )
                                          : null,
                                    ),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return 'Required';
                                      if (v.length < 10) return 'Enter a valid 10-digit number';
                                      return null;
                                    },
                                  ),
                                ),
                              ]),
                            ),
                            SizedBox(height: 16 * s),

                            // Continue button
                            GestureDetector(
                              onTap: provider.isLoading ? null : () => _submit(provider),
                              child: Container(
                                width: double.infinity,
                                height: 54 * s,
                                decoration: BoxDecoration(
                                  color: AppTheme.orange,
                                  borderRadius: BorderRadius.circular(16 * s),
                                ),
                                alignment: Alignment.center,
                                child: provider.isLoading
                                    ? SizedBox(width: 20 * s, height: 20 * s,
                                        child: const CircularProgressIndicator(
                                            strokeWidth: 2, color: Colors.white))
                                    : Text('Continue',
                                        style: TextStyle(fontSize: 15 * s,
                                            fontWeight: FontWeight.w700, color: Colors.white)),
                              ),
                            ),
                            SizedBox(height: 20 * s),

                            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Text('New here?  ',
                                  style: TextStyle(fontSize: 13 * s, color: AppTheme.white30)),
                              GestureDetector(
                                onTap: () => Navigator.push(ctx,
                                    MaterialPageRoute(builder: (_) => const PremiumRegisterScreen())),
                                child: Text('Create account',
                                    style: TextStyle(fontSize: 13 * s,
                                        color: AppTheme.orange, fontWeight: FontWeight.w600)),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

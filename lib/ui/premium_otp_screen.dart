import 'dart:async';
import 'package:colourmaster/ui/widget/premium_buttons.dart' as btn;
import 'package:colourmaster/utils/premium_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  State<PremiumOTPScreen> createState() => _State();
}

class _State extends State<PremiumOTPScreen> {
  final _pin     = TextEditingController();
  final _focus   = FocusNode();
  final _formKey = GlobalKey<FormState>();
  bool _canResend = false;
  int  _seconds   = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: AppTheme.black,
    ));
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_seconds > 0) {
        setState(() => _seconds--);
      } else {
        setState(() => _canResend = true);
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pin.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Pin box themes
    final base = PinTheme(
      width: 64, height: 64,
      textStyle: const TextStyle(
          fontSize: 26, fontWeight: FontWeight.w700, color: AppTheme.white),
      decoration: BoxDecoration(
        color: AppTheme.black4,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.black5, width: 1.5),
      ),
    );
    final focused = base.copyWith(
      decoration: base.decoration?.copyWith(
        border: Border.all(color: AppTheme.orange, width: 1.5),
        boxShadow: [BoxShadow(
            color: AppTheme.orange.withOpacity(0.2), blurRadius: 12)],
      ),
    );
    final submitted = base.copyWith(
      decoration: base.decoration?.copyWith(
        color: AppTheme.orange.withOpacity(0.08),
        border: Border.all(color: AppTheme.orange.withOpacity(0.4)),
      ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppTheme.black,
      body: Consumer<UserProvider>(
        builder: (_, provider, __) => Column(
          children: [
            // ── Brand / info top ─────────────────────────────────────
            Expanded(
              child: SafeArea(
                bottom: false,
                child: Stack(
                  children: [
                    // Back button — always top-left
                    Positioned(
                      top: 16, left: 24,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.black3,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.black5),
                          ),
                          child: const Icon(Icons.arrow_back_ios_rounded,
                              color: AppTheme.white, size: 16),
                        ),
                      ),
                    ),

                    // Icon + title — centered in the full top area
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Verify Mobile',
                                style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.white)),
                            const SizedBox(height: 6),
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.white.withOpacity(0.4)),
                                children: [
                                  const TextSpan(text: 'Code sent to '),
                                  TextSpan(
                                    text: '+91 ${widget.userMobile}',
                                    style: const TextStyle(
                                        color: AppTheme.orange,
                                        fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Form sheet — keyboard pushes this up ───────────────────
            Container(
              decoration: const BoxDecoration(
                color: AppTheme.black2,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(top: BorderSide(color: AppTheme.black5)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Handle
                        Container(
                          width: 32, height: 3,
                          decoration: BoxDecoration(
                              color: AppTheme.black5,
                              borderRadius: BorderRadius.circular(2)),
                        ),
                        const SizedBox(height: 28),

                        // PIN boxes
                        Pinput(
                          length: 4,
                          controller: _pin,
                          focusNode: _focus,
                          autofocus: true,
                          defaultPinTheme: base,
                          focusedPinTheme: focused,
                          submittedPinTheme: submitted,
                          hapticFeedbackType: HapticFeedbackType.lightImpact,
                          separatorBuilder: (_) => const SizedBox(width: 12),
                          onCompleted: (_) => _verify(provider),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 10),
                        Text('Enter the 4-digit code',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.white.withOpacity(0.3))),
                        const SizedBox(height: 28),

                        // Verify button
                        btn.PremiumButton(
                          text: 'Verify',
                          isLoading: provider.isLoading,
                          width: double.infinity,
                          height: 56,
                          onPressed: _pin.text.length == 4
                              ? () => _verify(provider)
                              : null,
                        ),
                        const SizedBox(height: 20),

                        // Resend timer
                        GestureDetector(
                          onTap: _canResend ? _resend : null,
                          child: _canResend
                              ? const Text('Resend Code',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.orange,
                                      fontWeight: FontWeight.w600))
                              : RichText(
                                  text: TextSpan(children: [
                                    TextSpan(
                                        text: 'Resend code in ',
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: AppTheme.white
                                                .withOpacity(0.3))),
                                    TextSpan(
                                        text: '${_seconds}s',
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: AppTheme.orange,
                                            fontWeight: FontWeight.w600)),
                                  ]),
                                ),
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
    );
  }

  void _verify(UserProvider provider) async {
    if (!await check()) { showWarningToast('No network connection'); return; }
    FocusManager.instance.primaryFocus?.unfocus();
    await provider.userOTPVerify(widget.userMobile, _pin.text.trim(), context);
    _pin.clear();
    _focus.requestFocus();
  }

  void _resend() async {
    if (!await check()) { showWarningToast('No network connection'); return; }
    final provider = Provider.of<UserProvider>(context, listen: false);
    provider.isLoading = true;
    _pin.clear();
    final res = await ApiService().resendOTP(widget.userMobile);
    provider.isLoading = false;
    if (!mounted) return;
    if (res?.status == 1) {
      setState(() { _seconds = 30; _canResend = false; });
      _startTimer();
      showSuccessToast(context, res!.message!);
    } else {
      showFailedToast(context, res?.message ?? 'Failed');
    }
  }
}

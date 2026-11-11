import 'dart:async';
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
  final _pin   = TextEditingController();
  final _focus = FocusNode();
  bool _canResend = false;
  int  _seconds   = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Color(0xFFF5F5F0),
    ));
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() { _seconds = 30; _canResend = false; });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) { _timer?.cancel(); return; }
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
    final sw = MediaQuery.of(context).size.width;
    final s  = (sw / 390).clamp(0.8, 1.3);

    final base = PinTheme(
      width: 64 * s, height: 64 * s,
      textStyle: TextStyle(fontSize: 24 * s, fontWeight: FontWeight.w700, color: AppTheme.white),
      decoration: BoxDecoration(
        color: AppTheme.black2,
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: AppTheme.black5, width: 1.5),
      ),
    );
    final focused = base.copyWith(
      decoration: base.decoration?.copyWith(
        border: Border.all(color: AppTheme.orange, width: 2),
      ),
    );
    final submitted = base.copyWith(
      decoration: base.decoration?.copyWith(
        color: AppTheme.orange.withOpacity(0.08),
        border: Border.all(color: AppTheme.orange.withOpacity(0.5), width: 1.5),
      ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppTheme.black,
      body: Consumer<UserProvider>(
        builder: (_, provider, __) => SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16 * s),

                // Back button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40 * s, height: 40 * s,
                    decoration: BoxDecoration(
                      color: AppTheme.black2,
                      borderRadius: BorderRadius.circular(12 * s),
                      border: Border.all(color: AppTheme.black5),
                    ),
                    child: Icon(Icons.arrow_back_ios_rounded,
                        color: AppTheme.white, size: 16 * s),
                  ),
                ),
                SizedBox(height: 32 * s),

                Text('Verify Mobile',
                    style: TextStyle(fontSize: 26 * s,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.white,
                        letterSpacing: -0.3)),
                SizedBox(height: 6 * s),
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 14 * s, color: AppTheme.white30),
                    children: [
                      const TextSpan(text: 'Code sent to '),
                      TextSpan(
                        text: '+91 ${widget.userMobile}',
                        style: TextStyle(color: AppTheme.orange,
                            fontWeight: FontWeight.w600, fontSize: 14 * s)),
                    ],
                  ),
                ),
                SizedBox(height: 40 * s),

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
                  separatorBuilder: (_) => SizedBox(width: 12 * s),
                  onCompleted: (_) => _verify(provider),
                  onChanged: (_) => setState(() {}),
                ),
                SizedBox(height: 8 * s),
                Text('Enter the 4-digit OTP',
                    style: TextStyle(fontSize: 12 * s, color: AppTheme.white30)),
                SizedBox(height: 32 * s),

                // Verify button
                GestureDetector(
                  onTap: (provider.isLoading || _pin.text.length != 4)
                      ? null
                      : () => _verify(provider),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    height: 54 * s,
                    decoration: BoxDecoration(
                      color: _pin.text.length == 4 ? AppTheme.orange : AppTheme.black4,
                      borderRadius: BorderRadius.circular(16 * s),
                    ),
                    alignment: Alignment.center,
                    child: provider.isLoading
                        ? SizedBox(width: 20 * s, height: 20 * s,
                            child: const CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text('Verify OTP',
                            style: TextStyle(
                                fontSize: 15 * s,
                                fontWeight: FontWeight.w700,
                                color: _pin.text.length == 4
                                    ? Colors.white
                                    : AppTheme.white30)),
                  ),
                ),
                SizedBox(height: 20 * s),

                // Resend
                Center(
                  child: GestureDetector(
                    onTap: _canResend ? _resend : null,
                    child: _canResend
                        ? Text('Resend OTP',
                            style: TextStyle(fontSize: 14 * s,
                                color: AppTheme.orange, fontWeight: FontWeight.w600))
                        : RichText(
                            text: TextSpan(children: [
                              TextSpan(text: 'Resend code in ',
                                  style: TextStyle(fontSize: 13 * s, color: AppTheme.white30)),
                              TextSpan(text: '${_seconds}s',
                                  style: TextStyle(fontSize: 13 * s,
                                      color: AppTheme.orange, fontWeight: FontWeight.w600)),
                            ]),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _verify(UserProvider provider) async {
    if (!mounted) return;
    if (!await check()) { showWarningToast('No network connection'); return; }
    FocusManager.instance.primaryFocus?.unfocus();
    await provider.userOTPVerify(widget.userMobile, _pin.text.trim(), context);
    if (!mounted) return;
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
      _startTimer();
      showSuccessToast(context, res!.message!);
    } else {
      showFailedToast(context, res?.message ?? 'Failed');
    }
  }
}

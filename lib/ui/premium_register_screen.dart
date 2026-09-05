import 'dart:io';

import 'package:colourmaster/ui/widget/premium_buttons.dart';
import 'package:colourmaster/utils/premium_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';

import '../provider/user_provider.dart';
import '../utils/constants.dart';
import '../utils/image_compression.dart';
import '../utils/utilsMethods.dart';
import 'premium_login_screen.dart';

class PremiumRegisterScreen extends StatefulWidget {
  const PremiumRegisterScreen({super.key});
  @override
  State<PremiumRegisterScreen> createState() => _State();
}

class _State extends State<PremiumRegisterScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _name       = TextEditingController();
  final _mobile     = TextEditingController();
  final _email      = TextEditingController();
  final _address    = TextEditingController();
  final _dob        = TextEditingController();
  final _scroll     = ScrollController();
  bool _agreeTerms  = false;
  File? _imageFile;
  String _dobDate   = '';
  DateTime _lastDate = DateTime.now().subtract(const Duration(days: 1));

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: AppTheme.black,
    ));
  }

  @override
  void dispose() {
    _name.dispose(); _mobile.dispose(); _email.dispose();
    _address.dispose(); _dob.dispose(); _scroll.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
    if (picked != null) _cropImage(picked);
  }

  Future<void> _cropImage(XFile file) async {
    final cropped = await ImageCropper().cropImage(
      compressQuality: 50,
      compressFormat: ImageCompressFormat.png,
      sourcePath: file.path,
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Crop',
            cropGridColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(title: 'Crop'),
      ],
    );
    if (cropped != null) {
      setState(() {
        _imageFile = ImageCompression().compressAndResizeImage(File(cropped.path));
      });
    }
  }

  void _submit(UserProvider p) async {
    if (!_agreeTerms) {
      showWarningToast('Please accept the terms & conditions');
      return;
    }
    if (_formKey.currentState!.validate()) {
      check().then((ok) async {
        if (ok) {
          FocusManager.instance.primaryFocus?.unfocus();
          await p.registerUser(
            _name.text.trim(), _mobile.text.trim(),
            _email.text.trim(), _dobDate,
            _address.text.trim(), _imageFile, context,
          );
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
              // ── Brand top ─────────────────────────────────────────────
              Expanded(
                flex: 2,
                child: SafeArea(
                  bottom: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
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
                                  color: AppTheme.white.withOpacity(0.3))),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Scrollable form sheet ─────────────────────────────────
              Expanded(
                flex: 5,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.black2,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    border: Border(top: BorderSide(color: AppTheme.black5)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: SingleChildScrollView(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Handle
                            Center(
                              child: Container(
                                width: 32, height: 3,
                                decoration: BoxDecoration(
                                    color: AppTheme.black5,
                                    borderRadius: BorderRadius.circular(2)),
                              ),
                            ),
                            const SizedBox(height: 20),

                            const Text('Create account',
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.white)),
                            const SizedBox(height: 20),

                            _field('Full Name', 'Your full name', _name,
                                TextInputType.text,
                                validator: (v) => v!.isEmpty ? 'Required' : null),
                            const SizedBox(height: 14),

                            _field('Mobile Number', '10-digit number', _mobile,
                                TextInputType.phone,
                                maxLength: 10,
                                formatters: [FilteringTextInputFormatter.digitsOnly],
                                validator: (v) {
                                  if (v!.isEmpty) return 'Required';
                                  if (v.length < 10) return 'Enter valid 10-digit number';
                                  return null;
                                }),
                            const SizedBox(height: 14),

                            _field('Email Address', 'your@email.com', _email,
                                TextInputType.emailAddress,
                                validator: validateEmail),
                            const SizedBox(height: 14),

                            _field('Address', 'Your address', _address,
                                TextInputType.text,
                                validator: (v) => v!.isEmpty ? 'Required' : null),
                            const SizedBox(height: 14),

                            _dateField(),
                            const SizedBox(height: 20),

                            _termsRow(),
                            const SizedBox(height: 24),

                            PremiumButton(
                              text: 'Create Account',
                              isLoading: provider.isLoading,
                              width: double.infinity,
                              height: 56,
                              onPressed: () => _submit(provider),
                            ),
                            const SizedBox(height: 20),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Already have an account?  ',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.white.withOpacity(0.35))),
                                GestureDetector(
                                  onTap: () => Navigator.pushReplacement(ctx,
                                      MaterialPageRoute(
                                          builder: (_) => const PremiumLoginScreen())),
                                  child: const Text('Sign In',
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Field label + input ────────────────────────────────────────────────────
  Widget _field(
    String label,
    String hint,
    TextEditingController ctrl,
    TextInputType type, {
    String? Function(String?)? validator,
    int? maxLength,
    List<TextInputFormatter>? formatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppTheme.white.withOpacity(0.4),
                letterSpacing: 0.8)),
        const SizedBox(height: 7),
        TextFormField(
          controller: ctrl,
          keyboardType: type,
          maxLength: maxLength,
          inputFormatters: formatters,
          style: const TextStyle(
              fontSize: 15, color: AppTheme.white, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
          ),
          validator: validator,
        ),
      ],
    );
  }

  // ── Date field ─────────────────────────────────────────────────────────────
  Widget _dateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('DATE OF BIRTH',
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppTheme.white.withOpacity(0.4),
                letterSpacing: 0.8)),
        const SizedBox(height: 7),
        TextFormField(
          controller: _dob,
          readOnly: true,
          style: const TextStyle(
              fontSize: 15, color: AppTheme.white, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: 'DD / MM / YYYY',
            suffixIcon: Icon(Icons.calendar_today_outlined,
                size: 16, color: AppTheme.white.withOpacity(0.3)),
          ),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _lastDate,
              firstDate: DateTime(1900),
              lastDate: DateTime.now().subtract(const Duration(days: 1)),
            );
            if (picked != null) {
              _lastDate = picked;
              _dobDate = DateFormat('yyyy/MM/dd').format(picked);
              _dob.text = DateFormat('dd/MM/yyyy').format(picked);
            }
          },
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Select date of birth' : null,
        ),
      ],
    );
  }

  // ── Terms checkbox ─────────────────────────────────────────────────────────
  Widget _termsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20, height: 20,
          child: Checkbox(
            value: _agreeTerms,
            onChanged: (v) => setState(() => _agreeTerms = v ?? false),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(children: [
              TextSpan(
                  text: 'I agree to the ',
                  style: TextStyle(
                      fontSize: 13, color: AppTheme.white.withOpacity(0.4))),
              TextSpan(
                  text: 'Terms & Conditions',
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.orange,
                      fontWeight: FontWeight.w600),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => redirectToBrowser(termConditionURL)),
            ]),
          ),
        ),
      ],
    );
  }
}

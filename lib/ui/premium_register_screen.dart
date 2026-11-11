import 'dart:io';

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
  final _formKey   = GlobalKey<FormState>();
  final _name      = TextEditingController();
  final _mobile    = TextEditingController();
  final _email     = TextEditingController();
  final _address   = TextEditingController();
  final _dob       = TextEditingController();
  final _scroll    = ScrollController();
  bool  _agreeTerms = false;
  File? _imageFile;
  String _dobDate  = '';
  DateTime _lastDate = DateTime.now().subtract(const Duration(days: 1));

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Color(0xFFF5F5F0),
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
        AndroidUiSettings(toolbarTitle: 'Crop', cropGridColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.original, lockAspectRatio: false),
        IOSUiSettings(title: 'Crop'),
      ],
    );
    if (cropped != null && mounted) {
      setState(() => _imageFile = ImageCompression().compressAndResizeImage(File(cropped.path)));
    }
  }

  void _submit(UserProvider p) async {
    if (!_agreeTerms) { showWarningToast('Please accept the terms & conditions'); return; }
    if (_formKey.currentState!.validate()) {
      check().then((ok) async {
        if (!mounted) return;
        if (ok) {
          FocusManager.instance.primaryFocus?.unfocus();
          await p.registerUser(_name.text.trim(), _mobile.text.trim(),
              _email.text.trim(), _dobDate, _address.text.trim(), _imageFile, context);
        } else {
          showWarningToast('No network connection');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final s  = (sw / 390).clamp(0.8, 1.3);

    return UpgradeAlert(
      barrierDismissible: false,
      dialogStyle: !kIsWeb
          ? (Platform.isIOS ? UpgradeDialogStyle.cupertino : UpgradeDialogStyle.material)
          : UpgradeDialogStyle.material,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppTheme.black,
        body: Consumer<UserProvider>(
          builder: (ctx, provider, _) => SafeArea(
            child: Column(children: [

              // ── Brand top ─────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(24 * s, 20 * s, 24 * s, 20 * s),
                child: Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40 * s, height: 40 * s,
                      decoration: BoxDecoration(
                        color: AppTheme.black3,
                        borderRadius: BorderRadius.circular(12 * s),
                        border: Border.all(color: AppTheme.black5),
                      ),
                      child: Icon(Icons.arrow_back_ios_rounded,
                          color: AppTheme.white, size: 16 * s),
                    ),
                  ),
                  SizedBox(width: 14 * s),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Create account',
                        style: TextStyle(fontSize: 20 * s,
                            fontWeight: FontWeight.w700, color: AppTheme.white)),
                    Text('Join Colour Master rewards',
                        style: TextStyle(fontSize: 12 * s, color: AppTheme.white30)),
                  ]),
                ]),
              ),

              // ── Scrollable form ───────────────────────────────────
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.black2,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28 * s)),
                    border: const Border(top: BorderSide(color: AppTheme.black5)),
                  ),
                  child: SingleChildScrollView(
                    controller: _scroll,
                    padding: EdgeInsets.fromLTRB(24 * s, 20 * s, 24 * s, 32 * s),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(child: Container(
                            width: 36 * s, height: 4 * s,
                            decoration: BoxDecoration(
                                color: AppTheme.black5,
                                borderRadius: BorderRadius.circular(2)),
                          )),
                          SizedBox(height: 24 * s),

                          // Avatar picker
                          Center(child: _avatarPicker(s)),
                          SizedBox(height: 24 * s),

                          _field('Full Name', 'Your full name', _name, TextInputType.text, s,
                              validator: (v) => v!.isEmpty ? 'Required' : null),
                          _field('Mobile Number', '10-digit number', _mobile, TextInputType.phone, s,
                              maxLength: 10,
                              formatters: [FilteringTextInputFormatter.digitsOnly],
                              validator: (v) {
                                if (v!.isEmpty) return 'Required';
                                if (v.length < 10) return 'Enter valid 10-digit number';
                                return null;
                              }),
                          _field('Email Address', 'your@email.com', _email,
                              TextInputType.emailAddress, s, validator: validateEmail),
                          _field('Address', 'Your address', _address, TextInputType.text, s,
                              validator: (v) => v!.isEmpty ? 'Required' : null),
                          _dateField(s),
                          SizedBox(height: 20 * s),

                          _termsRow(s),
                          SizedBox(height: 24 * s),

                          // Submit button
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
                                  : Text('Create Account',
                                      style: TextStyle(fontSize: 15 * s,
                                          fontWeight: FontWeight.w700, color: Colors.white)),
                            ),
                          ),
                          SizedBox(height: 20 * s),

                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text('Already have an account?  ',
                                style: TextStyle(fontSize: 13 * s, color: AppTheme.white30)),
                            GestureDetector(
                              onTap: () => Navigator.pushReplacement(ctx,
                                  MaterialPageRoute(builder: (_) => const PremiumLoginScreen())),
                              child: Text('Sign In',
                                  style: TextStyle(fontSize: 13 * s,
                                      color: AppTheme.orange, fontWeight: FontWeight.w600)),
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _avatarPicker(double s) {
    return GestureDetector(
      onTap: () => _showImagePicker(s),
      child: Stack(children: [
        Container(
          width: 80 * s, height: 80 * s,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.black4,
            border: Border.all(
                color: _imageFile != null
                    ? AppTheme.orange.withOpacity(0.4)
                    : AppTheme.black5,
                width: 2),
          ),
          child: ClipOval(
            child: _imageFile != null
                ? Image.file(_imageFile!, fit: BoxFit.cover)
                : Icon(Icons.person_rounded, color: AppTheme.white30, size: 36 * s),
          ),
        ),
        Positioned(
          bottom: 0, right: 0,
          child: Container(
            width: 26 * s, height: 26 * s,
            decoration: BoxDecoration(
              color: AppTheme.orange,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.black2, width: 2),
            ),
            child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 12 * s),
          ),
        ),
      ]),
    );
  }

  void _showImagePicker(double s) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.black2,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24 * s))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20 * s),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 36 * s, height: 4 * s,
                margin: EdgeInsets.only(bottom: 20 * s),
                decoration: BoxDecoration(color: AppTheme.black5,
                    borderRadius: BorderRadius.circular(2))),
            Text('Profile Photo',
                style: TextStyle(fontSize: 15 * s,
                    fontWeight: FontWeight.w700, color: AppTheme.white)),
            SizedBox(height: 20 * s),
            Row(children: [
              Expanded(child: _pickerOption(Icons.camera_alt_rounded, 'Camera', s,
                  () { Navigator.pop(context); _pickImage(ImageSource.camera); })),
              SizedBox(width: 12 * s),
              Expanded(child: _pickerOption(Icons.photo_library_rounded, 'Gallery', s,
                  () { Navigator.pop(context); _pickImage(ImageSource.gallery); })),
            ]),
            SizedBox(height: 8 * s),
          ]),
        ),
      ),
    );
  }

  Widget _pickerOption(IconData icon, String label, double s, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 18 * s),
        decoration: BoxDecoration(
          color: AppTheme.black4,
          borderRadius: BorderRadius.circular(14 * s),
          border: Border.all(color: AppTheme.black5),
        ),
        child: Column(children: [
          Icon(icon, color: AppTheme.orange, size: 26 * s),
          SizedBox(height: 8 * s),
          Text(label, style: TextStyle(fontSize: 13 * s,
              fontWeight: FontWeight.w500, color: AppTheme.white)),
        ]),
      ),
    );
  }

  Widget _field(String label, String hint, TextEditingController ctrl,
      TextInputType type, double s, {
    String? Function(String?)? validator,
    int? maxLength,
    List<TextInputFormatter>? formatters,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14 * s),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: TextStyle(fontSize: 11 * s, fontWeight: FontWeight.w600,
                color: AppTheme.white30, letterSpacing: 0.3)),
        SizedBox(height: 6 * s),
        TextFormField(
          controller: ctrl,
          keyboardType: type,
          maxLength: maxLength,
          inputFormatters: formatters,
          style: TextStyle(fontSize: 15 * s, color: AppTheme.white, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
            filled: true,
            fillColor: AppTheme.black3,
            hintStyle: TextStyle(fontSize: 14 * s, color: AppTheme.white30),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14 * s),
                borderSide: BorderSide(color: AppTheme.black5)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14 * s),
                borderSide: BorderSide(color: AppTheme.black5)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14 * s),
                borderSide: BorderSide(color: AppTheme.orange, width: 1.5)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14 * s),
                borderSide: BorderSide(color: AppTheme.red)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14 * s),
                borderSide: BorderSide(color: AppTheme.red, width: 1.5)),
            contentPadding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 14 * s),
          ),
          validator: validator,
        ),
      ]),
    );
  }

  Widget _dateField(double s) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14 * s),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Date of Birth',
            style: TextStyle(fontSize: 11 * s, fontWeight: FontWeight.w600,
                color: AppTheme.white30, letterSpacing: 0.3)),
        SizedBox(height: 6 * s),
        TextFormField(
          controller: _dob,
          readOnly: true,
          style: TextStyle(fontSize: 15 * s, color: AppTheme.white, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: 'DD / MM / YYYY',
            filled: true,
            fillColor: AppTheme.black3,
            hintStyle: TextStyle(fontSize: 14 * s, color: AppTheme.white30),
            suffixIcon: Icon(Icons.calendar_today_outlined,
                size: 16 * s, color: AppTheme.white30),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14 * s),
                borderSide: BorderSide(color: AppTheme.black5)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14 * s),
                borderSide: BorderSide(color: AppTheme.black5)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14 * s),
                borderSide: BorderSide(color: AppTheme.orange, width: 1.5)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14 * s),
                borderSide: BorderSide(color: AppTheme.red)),
            contentPadding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 14 * s),
          ),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _lastDate,
              firstDate: DateTime(1900),
              lastDate: DateTime.now().subtract(const Duration(days: 1)),
            );
            if (!mounted || picked == null) return;
            _lastDate = picked;
            _dobDate  = DateFormat('yyyy/MM/dd').format(picked);
            _dob.text = DateFormat('dd/MM/yyyy').format(picked);
          },
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Select date of birth' : null,
        ),
      ]),
    );
  }

  Widget _termsRow(double s) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GestureDetector(
        onTap: () => setState(() => _agreeTerms = !_agreeTerms),
        child: Container(
          width: 22 * s, height: 22 * s,
          decoration: BoxDecoration(
            color: _agreeTerms ? AppTheme.orange : AppTheme.black3,
            borderRadius: BorderRadius.circular(6 * s),
            border: Border.all(
                color: _agreeTerms ? AppTheme.orange : AppTheme.black5, width: 1.5),
          ),
          child: _agreeTerms
              ? Icon(Icons.check_rounded, color: Colors.white, size: 14 * s)
              : null,
        ),
      ),
      SizedBox(width: 10 * s),
      Expanded(
        child: RichText(
          text: TextSpan(children: [
            TextSpan(text: 'I agree to the ',
                style: TextStyle(fontSize: 13 * s, color: AppTheme.white30)),
            TextSpan(
                text: 'Terms & Conditions',
                style: TextStyle(fontSize: 13 * s,
                    color: AppTheme.orange, fontWeight: FontWeight.w600),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => redirectToBrowser(termConditionURL)),
          ]),
        ),
      ),
    ]);
  }
}

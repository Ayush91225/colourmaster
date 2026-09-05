// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/userModel/UserProfile.dart';
import '../provider/user_provider.dart';
import '../utils/image_compression.dart';
import '../utils/sharedPreferenceKey.dart';
import '../utils/premium_theme.dart';
import '../utils/utilsMethods.dart';
import 'widget/app_header.dart';
import 'widget/premium_shimmer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _nameCtrl     = TextEditingController();
  final _cityCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _addressCtrl  = TextEditingController();
  final _dobCtrl      = TextEditingController();
  final _mobileCtrl   = TextEditingController();

  File?   _profilePhoto;
  String  _token   = '';
  String  _dobDate = '';
  DateTime _lastPickedDate = DateTime.now().subtract(const Duration(days: 1));

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(TOKEN) ?? '';
    final p = Provider.of<UserProvider>(context, listen: false);
    if (await check()) {
      p.userProfileData = UserProfileData();
      p.isLoading = true;
      await p.fetchUserDetails(context, _token);
      _populate(p);
    } else {
      showWarningToast('No network connection');
    }
  }

  void _populate(UserProvider p) async {
    _nameCtrl.text    = p.userProfileData?.name ?? '';
    _emailCtrl.text   = p.userProfileData?.email ?? '';
    _mobileCtrl.text  = p.userProfileData?.mobileNumber ?? '';
    _addressCtrl.text = p.userProfileData?.address ?? '';
    if (p.userProfileData?.dob != null) {
      _dobCtrl.text = getFormattedDate(p.userProfileData!.dob);
      _dobDate      = getFormattedDate1(p.userProfileData!.dob);
    }
    if (p.userProfileData?.profileImage != null &&
        p.userProfileData!.profileImage.toString().isNotEmpty) {
      _profilePhoto =
          await fileFromImageUrl(p.userProfileData!.profileImage);
    }
    if (mounted) setState(() {});
    p.isLoading = false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _cityCtrl.dispose(); _emailCtrl.dispose();
    _addressCtrl.dispose(); _dobCtrl.dispose(); _mobileCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final s  = (sw / 390).clamp(0.8, 1.3);

    return Consumer<UserProvider>(
      builder: (_, p, __) => LoadingOverlay(
        isLoading: p.isLoading,
        color: Colors.black.withOpacity(0.6),
        progressIndicator: const CircularProgressIndicator(
            color: AppTheme.orange, strokeWidth: 2.5),
        child: Scaffold(
          backgroundColor: AppTheme.black,
          body: CustomScrollView(
            slivers: [
              appHeader(context: context, title: 'Profile'),

              if (p.isLoading)
                _shimmer(s)
              else ...[
                SliverToBoxAdapter(child: _avatarSection(s)),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                      16 * s, 0, 16 * s, 60 * s),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Form(
                        key: _formKey,
                        child: Column(children: [
                          _field('Full Name', _nameCtrl, s,
                              hint: 'Enter your name',
                              validator: (v) =>
                                  v!.isEmpty ? 'Name required' : null),
                          _field('Mobile Number', _mobileCtrl, s,
                              hint: 'Mobile number',
                              readOnly: true,
                              type: TextInputType.phone,
                              validator: (v) {
                                if (v!.isEmpty) return 'Required';
                                if (v.length < 10) return 'Enter valid number';
                                return null;
                              }),
                          _field('Email', _emailCtrl, s,
                              hint: 'Enter email address',
                              type: TextInputType.emailAddress,
                              validator: validateEmail),
                          _field('Address', _addressCtrl, s,
                              hint: 'Enter your address',
                              validator: (v) =>
                                  v!.isEmpty ? 'Address required' : null),
                          _dobField(s),
                          SizedBox(height: 28 * s),
                          _submitBtn(p, s),
                        ]),
                      ),
                    ]),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Avatar section ────────────────────────────────────────────────────────────
  Widget _avatarSection(double s) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 28 * s),
      child: Column(children: [
        Stack(children: [
          Container(
            width: 88 * s, height: 88 * s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.black3,
              border: Border.all(
                  color: AppTheme.orange.withOpacity(0.4), width: 2.5),
            ),
            child: ClipOval(
              child: _profilePhoto != null
                  ? Image.file(_profilePhoto!, fit: BoxFit.cover)
                  : Icon(Icons.person_rounded,
                      color: AppTheme.white.withOpacity(0.3),
                      size: 40 * s),
            ),
          ),
          Positioned(
            bottom: 0, right: 0,
            child: GestureDetector(
              onTap: () => _showPicker(),
              child: Container(
                width: 28 * s, height: 28 * s,
                decoration: BoxDecoration(
                  color: AppTheme.orange,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.black, width: 2),
                ),
                child: Icon(Icons.camera_alt_rounded,
                    color: AppTheme.black, size: 13 * s),
              ),
            ),
          ),
        ]),
        SizedBox(height: 12 * s),
        Text(_nameCtrl.text.isNotEmpty ? _nameCtrl.text : 'Your Name',
            style: TextStyle(
                fontSize: 17 * s,
                fontWeight: FontWeight.w700,
                color: AppTheme.white)),
        SizedBox(height: 3 * s),
        Text(_mobileCtrl.text.isNotEmpty
                ? '+91 ${_mobileCtrl.text}'
                : 'Colour Master Member',
            style: TextStyle(
                fontSize: 13 * s,
                color: AppTheme.white.withOpacity(0.35))),
        SizedBox(height: 20 * s),
        Container(height: 1,
            color: AppTheme.black5.withOpacity(0.5)),
      ]),
    );
  }

  // ── Form field ────────────────────────────────────────────────────────────────
  Widget _field(
    String label,
    TextEditingController ctrl,
    double s, {
    String hint = '',
    bool readOnly = false,
    TextInputType type = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12 * s),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: TextStyle(
                fontSize: 11 * s,
                fontWeight: FontWeight.w600,
                color: AppTheme.white.withOpacity(0.4),
                letterSpacing: 0.4)),
        SizedBox(height: 6 * s),
        TextFormField(
          controller: ctrl,
          readOnly: readOnly,
          keyboardType: type,
          validator: validator,
          style: TextStyle(fontSize: 14 * s, color: AppTheme.white),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: readOnly ? AppTheme.black3 : AppTheme.black2,
            hintStyle: TextStyle(
                fontSize: 13 * s,
                color: AppTheme.white.withOpacity(0.2)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10 * s),
              borderSide: BorderSide(color: AppTheme.black5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10 * s),
              borderSide: BorderSide(color: AppTheme.black5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10 * s),
              borderSide:
                  BorderSide(color: AppTheme.orange, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10 * s),
              borderSide: BorderSide(color: AppTheme.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10 * s),
              borderSide:
                  BorderSide(color: AppTheme.red, width: 1.5),
            ),
            contentPadding: EdgeInsets.symmetric(
                horizontal: 14 * s, vertical: 14 * s),
          ),
        ),
      ]),
    );
  }

  // ── DOB field ─────────────────────────────────────────────────────────────────
  Widget _dobField(double s) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12 * s),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Date of Birth',
            style: TextStyle(
                fontSize: 11 * s,
                fontWeight: FontWeight.w600,
                color: AppTheme.white.withOpacity(0.4),
                letterSpacing: 0.4)),
        SizedBox(height: 6 * s),
        TextFormField(
          controller: _dobCtrl,
          readOnly: true,
          onTap: _pickDate,
          validator: (v) =>
              (v == null || v.isEmpty) ? 'Date of birth required' : null,
          style: TextStyle(fontSize: 14 * s, color: AppTheme.white),
          decoration: InputDecoration(
            hintText: 'DD / MM / YYYY',
            filled: true,
            fillColor: AppTheme.black2,
            hintStyle: TextStyle(
                fontSize: 13 * s,
                color: AppTheme.white.withOpacity(0.2)),
            suffixIcon: Icon(Icons.calendar_today_outlined,
                color: AppTheme.white.withOpacity(0.3),
                size: 16 * s),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10 * s),
              borderSide: BorderSide(color: AppTheme.black5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10 * s),
              borderSide: BorderSide(color: AppTheme.black5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10 * s),
              borderSide:
                  BorderSide(color: AppTheme.orange, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10 * s),
              borderSide: BorderSide(color: AppTheme.red),
            ),
            contentPadding: EdgeInsets.symmetric(
                horizontal: 14 * s, vertical: 14 * s),
          ),
        ),
      ]),
    );
  }

  // ── Submit button ─────────────────────────────────────────────────────────────
  Widget _submitBtn(UserProvider p, double s) {
    return GestureDetector(
      onTap: () => _submit(p),
      child: Container(
        width: double.infinity,
        height: 52 * s,
        decoration: BoxDecoration(
          color: AppTheme.orange,
          borderRadius: BorderRadius.circular(12 * s),
        ),
        alignment: Alignment.center,
        child: Text('Update Profile',
            style: TextStyle(
                fontSize: 15 * s,
                fontWeight: FontWeight.w700,
                color: AppTheme.black)),
      ),
    );
  }

  // ── Shimmer ───────────────────────────────────────────────────────────────────
  SliverPadding _shimmer(double s) {
    return SliverPadding(
      padding: EdgeInsets.all(16 * s),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          Center(
            child: Container(
              width: 88 * s, height: 88 * s,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: AppTheme.black3),
            ),
          ),
          SizedBox(height: 24 * s),
          ...List.generate(5, (_) => Padding(
            padding: EdgeInsets.only(bottom: 12 * s),
            child: PremiumShimmer.card(height: 56 * s),
          )),
          PremiumShimmer.card(height: 52 * s),
        ]),
      ),
    );
  }

  // ── Image picker ──────────────────────────────────────────────────────────────
  void _showPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.black2,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                  color: AppTheme.black5,
                  borderRadius: BorderRadius.circular(2)),
            ),
            Text('Update Photo',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.white)),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: _pickerOption(
                  Icons.camera_alt_rounded, 'Camera',
                  () { Navigator.pop(context);
                       _pickImage(ImageSource.camera); })),
              const SizedBox(width: 12),
              Expanded(child: _pickerOption(
                  Icons.photo_library_rounded, 'Gallery',
                  () { Navigator.pop(context);
                       _pickImage(ImageSource.gallery); })),
            ]),
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );
  }

  Widget _pickerOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AppTheme.black3,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.black5),
        ),
        child: Column(children: [
          Icon(icon, color: AppTheme.orange, size: 28),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.white)),
        ]),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
    if (picked == null) return;
    final cropped = await ImageCropper().cropImage(
      compressQuality: 50,
      compressFormat: ImageCompressFormat.png,
      sourcePath: picked.path,
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
        _profilePhoto =
            ImageCompression().compressAndResizeImage(File(cropped.path));
      });
    }
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _lastPickedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 1)),
    );
    if (d != null) {
      _lastPickedDate = d;
      _dobCtrl.text   = DateFormat('dd/MM/yyyy').format(d);
      _dobDate        = DateFormat('yyyy/MM/dd').format(d);
      setState(() {});
    }
  }

  Future<void> _submit(UserProvider p) async {
    if (!_formKey.currentState!.validate()) return;
    if (!await check()) { showWarningToast('No network connection'); return; }
    FocusManager.instance.primaryFocus?.unfocus();
    await p.updateUserProfile(
      _token,
      _nameCtrl.text.trim(),
      _mobileCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _dobDate,
      _addressCtrl.text.trim(),
      null,
      _profilePhoto,
      context,
    );
  }
}

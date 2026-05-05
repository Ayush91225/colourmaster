import 'dart:io';

import 'package:colourmaster/ui/widget/premium_buttons.dart';
import 'package:colourmaster/utils/premium_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
  State<PremiumRegisterScreen> createState() => _PremiumRegisterScreenState();
}

class _PremiumRegisterScreenState extends State<PremiumRegisterScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool agreeTerms = false;
  File? _imageFile;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  ScrollController scrollController = ScrollController();
  DateTime lastPickedDate = DateTime.now().subtract(const Duration(days: 1));
  String dobDate = "";

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
    ));
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      cropImage(pickedImage);
    }
  }

  Future cropImage(XFile imageFile) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      compressQuality: 50,
      compressFormat: ImageCompressFormat.png,
      sourcePath: imageFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop',
          cropGridColor: Colors.black,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: 'Crop')
      ],
    );
    if (croppedFile != null) {
      File pickedFile = File(croppedFile.path);
      _imageFile = ImageCompression().compressAndResizeImage(pickedFile);
      setState(() {});
    }
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
              return Column(
                children: [
                  // Header section
                  Container(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Image.asset(
                          'assets/images/logo.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
                        ).animate().scale(delay: 200.ms),
                        const SizedBox(height: 24),
                        Text(
                          'Join Color Master',
                          style: PremiumTheme.textTheme.headlineLarge?.copyWith(
                            color: PremiumTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ).animate().fadeIn(delay: 400.ms),
                        const SizedBox(height: 8),
                        Text(
                          'Create your rewards account',
                          style: PremiumTheme.textTheme.bodyLarge?.copyWith(
                            color: PremiumTheme.textSecondary,
                          ),
                        ).animate().fadeIn(delay: 600.ms),
                      ],
                    ),
                  ),
                  
                  // Form section (dock style)
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
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(32),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sign Up',
                                style: PremiumTheme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ).animate().slideX(delay: 800.ms),
                              const SizedBox(height: 32),
                              
                              _buildTextField(
                                'Full Name',
                                'Enter your full name',
                                nameController,
                                TextInputType.text,
                                validator: (value) => value!.isEmpty ? 'Name Required' : null,
                              ).animate().slideY(delay: 1000.ms),
                              
                              const SizedBox(height: 20),
                              
                              _buildTextField(
                                'Mobile Number',
                                'Enter your mobile number',
                                mobileNumberController,
                                TextInputType.phone,
                                maxLength: 10,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                validator: (value) {
                                  if (value!.isEmpty) return 'Mobile Number Required';
                                  if (value.length < 10) return 'Please enter a valid 10 digit mobile number';
                                  return null;
                                },
                              ).animate().slideY(delay: 1100.ms),
                              
                              const SizedBox(height: 20),
                              
                              _buildTextField(
                                'Email Address',
                                'Enter your email address',
                                emailController,
                                TextInputType.emailAddress,
                                validator: validateEmail,
                              ).animate().slideY(delay: 1200.ms),
                              
                              const SizedBox(height: 20),
                              
                              _buildTextField(
                                'Address',
                                'Enter your address',
                                addressController,
                                TextInputType.text,
                                validator: (value) => value!.isEmpty ? 'Address Required' : null,
                              ).animate().slideY(delay: 1300.ms),
                              
                              const SizedBox(height: 20),
                              
                              _buildDateField().animate().slideY(delay: 1400.ms),
                              
                              const SizedBox(height: 24),
                              
                              _buildTermsCheckbox().animate().fadeIn(delay: 1500.ms),
                              
                              const SizedBox(height: 32),
                              
                              PremiumButton(
                                text: 'Create Account',
                                isLoading: userProvider.isLoading,
                                width: double.infinity,
                                onPressed: () => _handleSignUp(userProvider),
                              ).animate().slideY(delay: 1600.ms),
                              
                              const SizedBox(height: 24),
                              
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Already have an account? ',
                                    style: PremiumTheme.textTheme.bodyMedium?.copyWith(
                                      color: PremiumTheme.textSecondary,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const PremiumLoginScreen(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Sign In',
                                      style: PremiumTheme.textTheme.bodyMedium?.copyWith(
                                        color: PremiumTheme.primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ).animate().fadeIn(delay: 1800.ms),
                              
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ).animate().slideY(begin: 0.3, delay: 800.ms),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller,
    TextInputType inputType, {
    String? Function(String?)? validator,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: PremiumTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          keyboardType: inputType,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date of Birth',
          style: PremiumTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: dobController,
          readOnly: true,
          decoration: const InputDecoration(
            hintText: 'DD/MM/YYYY',
            suffixIcon: Icon(Icons.calendar_today_rounded),
          ),
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: lastPickedDate,
              firstDate: DateTime(1900),
              lastDate: DateTime.now().subtract(const Duration(days: 1)),
            );
            if (pickedDate != null) {
              lastPickedDate = pickedDate;
              String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
              dobDate = DateFormat('yyyy/MM/dd').format(pickedDate);
              dobController.text = formattedDate;
            }
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Select your Date of Birth';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: agreeTerms,
            onChanged: (value) {
              setState(() {
                agreeTerms = value ?? false;
              });
            },
            activeColor: PremiumTheme.primaryColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'I agree to the ',
                    style: PremiumTheme.textTheme.bodyMedium?.copyWith(
                      color: PremiumTheme.textSecondary,
                    ),
                  ),
                  TextSpan(
                    text: 'Terms and Conditions',
                    style: PremiumTheme.textTheme.bodyMedium?.copyWith(
                      color: PremiumTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        redirectToBrowser(termConditionURL);
                      },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleSignUp(UserProvider userProvider) async {
    if (!agreeTerms) {
      showWarningToast('Please accept the terms & conditions');
      return;
    }
    
    if (formKey.currentState!.validate()) {
      check().then((internet) async {
        if (internet) {
          FocusManager.instance.primaryFocus?.unfocus();
          await userProvider.registerUser(
            nameController.text.toString().trim(),
            mobileNumberController.text.toString().trim(),
            emailController.text.toString().trim(),
            dobDate,
            addressController.text.toString().trim(),
            _imageFile,
            context,
          );
        } else {
          showWarningToast("No network connection");
        }
      });
    }
  }
}
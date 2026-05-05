// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:colourmaster/ui/home_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/userModel/UserProfile.dart';
import '../provider/user_provider.dart';
import '../utils/image_compression.dart';
import '../utils/sharedPreferenceKey.dart';
import '../utils/premium_theme.dart';
import '../utils/utilsMethods.dart';
import 'widget/premium_cards.dart';
import 'widget/premium_buttons.dart' as premium;
import 'widget/premium_shimmer.dart';
import 'widget/side_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String agreeError = "";
  bool agreeTerms = false;
  bool isChanged = false;
  File? _imageFile;
  File? _profilePhoto;

  TextEditingController nameController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController aadharController = TextEditingController();
  ScrollController scrollController = ScrollController();
  DateTime lastPickedDate = DateTime.now().subtract(const Duration(days: 1));
  bool selectedValue = false;
  int isCheckBoxSelected = -1;
  String dobDate = "";
  SharedPreferences? sharedPreferences;
  var userToken = "";
  
  @override
  void initState() {
    super.initState();
    initializePreference().whenComplete(() {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      check().then((internet) async {
        if (internet) {
          FocusManager.instance.primaryFocus?.unfocus();
          userProvider.userProfileData = UserProfileData();
          userProvider.isLoading = true;
          await userProvider.fetchUserDetails(context, userToken);
          setUserData();
        } else {
          showWarningToast("No network connection");
        }
      });
    });
  }

  setUserData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    nameController.text = userProvider.userProfileData!.name ?? "";
    emailController.text = userProvider.userProfileData!.email ?? "";
    mobileNumberController.text = userProvider.userProfileData!.mobileNumber ?? "";
    addressController.text = userProvider.userProfileData!.address ?? "";
    if (userProvider.userProfileData!.dob != null) {
      dobController.text = getFormattedDate(userProvider.userProfileData!.dob);
      dobDate = getFormattedDate1(userProvider.userProfileData!.dob);
    }
    if (userProvider.userProfileData!.profileImage != null &&
        userProvider.userProfileData!.profileImage.toString().isNotEmpty) {
      _profilePhoto = await fileFromImageUrl(userProvider.userProfileData!.profileImage);
    }
    setState(() {});
    userProvider.isLoading = false;
  }

  Future<void> initializePreference() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      userToken = sharedPreferences!.getString(TOKEN)!;
    });
  }

  Future<void> _pickImage(ImageSource source, var isProfilePhoto) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      cropImage(pickedImage, isProfilePhoto);
    }
  }

  Future cropImage(XFile imageFile, bool isProfilePhoto) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
        compressQuality: 50,
        compressFormat: ImageCompressFormat.png,
        sourcePath: imageFile.path,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Crop',
              cropGridColor: Colors.black,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(title: 'Crop')
        ]);
    if (croppedFile != null) {
      File pickedFile = File(croppedFile.path);
      if (isProfilePhoto) {
        _profilePhoto = ImageCompression().compressAndResizeImage(pickedFile);
      } else {
        _imageFile = ImageCompression().compressAndResizeImage(pickedFile);
      }
      setState(() {
        if (_imageFile != null) {
          aadharController.text = _imageFile!.path;
        }
        _profilePhoto;
        _imageFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PremiumTheme.backgroundColor,
      drawer: sideBar(context),
      body: SafeArea(
        child: Consumer<UserProvider>(
          builder: (context, UserProvider userProvider, child) {
            return userProvider.isLoading
                ? CustomScrollView(
                    slivers: [
                      // App Bar
                      SliverAppBar(
                        expandedHeight: 60,
                        floating: false,
                        pinned: true,
                        backgroundColor: Colors.white,
                        elevation: 0,
                        leading: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_back_ios_rounded,
                            color: PremiumTheme.textPrimary,
                            size: 20,
                          ),
                        ),
                        flexibleSpace: FlexibleSpaceBar(
                          centerTitle: true,
                          title: Text(
                            'Profile',
                            style: PremiumTheme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: PremiumTheme.textPrimary,
                            ),
                          ).animate().fadeIn(delay: 200.ms),
                        ),
                      ),
                      
                      // Shimmer Content
                      SliverPadding(
                        padding: const EdgeInsets.all(24),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            PremiumShimmer.profileHeader(),
                            const SizedBox(height: 32),
                            PremiumShimmer.card(height: 80),
                            const SizedBox(height: 20),
                            PremiumShimmer.card(height: 80),
                            const SizedBox(height: 20),
                            PremiumShimmer.card(height: 80),
                            const SizedBox(height: 20),
                            PremiumShimmer.card(height: 80),
                            const SizedBox(height: 20),
                            PremiumShimmer.card(height: 80),
                            const SizedBox(height: 40),
                            PremiumShimmer.card(height: 50),
                          ]),
                        ),
                      ),
                    ],
                  )
                : CustomScrollView(
                slivers: [
                  // App Bar
                  SliverAppBar(
                    expandedHeight: 60,
                    floating: false,
                    pinned: true,
                    backgroundColor: Colors.white,
                    elevation: 0,
                    leading: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: PremiumTheme.textPrimary,
                        size: 20,
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: Text(
                        'Profile',
                        style: PremiumTheme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: PremiumTheme.textPrimary,
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                    ),
                  ),
                  
                  // Content
                  SliverPadding(
                    padding: const EdgeInsets.all(24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Profile Photo Section
                        _buildProfilePhotoSection(),
                        const SizedBox(height: 32),
                        
                        // Form
                        Form(
                          key: formKey,
                          child: Column(
                            children: [
                              _buildInputField('Name', nameController, 'Enter your name', validator: (value) {
                                if (value!.isEmpty) return 'Name Required';
                                return null;
                              }),
                              const SizedBox(height: 20),
                              
                              _buildInputField('Mobile Number', mobileNumberController, 'Enter mobile number', 
                                readOnly: true, inputType: TextInputType.number, validator: (value) {
                                if (value!.isEmpty) return 'Mobile Number Required';
                                if (value.length < 10) return 'Please enter a valid 10 digit mobile number';
                                return null;
                              }),
                              const SizedBox(height: 20),
                              
                              _buildInputField('Email ID', emailController, 'Enter email address', 
                                inputType: TextInputType.emailAddress, validator: validateEmail),
                              const SizedBox(height: 20),
                              
                              _buildInputField('Address', addressController, 'Enter your address', validator: (value) {
                                if (value!.isEmpty) return 'Address Required';
                                return null;
                              }),
                              const SizedBox(height: 20),
                              
                              _buildDateField(),
                              const SizedBox(height: 40),
                              
                              // Submit Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => _submitForm(userProvider),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: PremiumTheme.primaryColor,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Update Profile',
                                    style: PremiumTheme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ).animate().fadeIn(delay: 600.ms),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              );
          },
        ),
      ),
    );
  }

  Widget _buildProfilePhotoSection() {
    return PremiumCard(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: PremiumTheme.primaryColor.withOpacity(0.1),
                ),
                child: ClipOval(
                  child: _profilePhoto == null
                      ? Icon(
                          Icons.person_rounded,
                          color: PremiumTheme.primaryColor,
                          size: 50,
                        )
                      : Image.file(
                          File(_profilePhoto!.path),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _showImagePicker(true),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: PremiumTheme.primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Profile Photo',
            style: PremiumTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap the camera icon to update',
            style: PremiumTheme.textTheme.bodySmall?.copyWith(
              color: PremiumTheme.textSecondary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    String hint, {
    bool readOnly = false,
    TextInputType inputType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: PremiumTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: PremiumTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: inputType,
            validator: validator,
            style: PremiumTheme.textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: PremiumTheme.textTheme.bodyMedium?.copyWith(
                color: PremiumTheme.textTertiary,
              ),
              filled: true,
              fillColor: readOnly ? PremiumTheme.backgroundColor : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: PremiumTheme.primaryColor,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: PremiumTheme.errorColor,
                  width: 1,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildDateField() {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Date of Birth',
            style: PremiumTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: PremiumTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: dobController,
            readOnly: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Select your Date of Birth';
              }
              return null;
            },
            style: PremiumTheme.textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: 'DD / MM / YYYY',
              hintStyle: PremiumTheme.textTheme.bodyMedium?.copyWith(
                color: PremiumTheme.textTertiary,
              ),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: Icon(
                Icons.calendar_today_rounded,
                color: PremiumTheme.primaryColor,
                size: 20,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: PremiumTheme.primaryColor,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: PremiumTheme.errorColor,
                  width: 1,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            onTap: () => _selectDate(),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms);
  }

  void _showImagePicker(bool isProfilePhoto) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Select Photo',
                  style: PremiumTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildImageOption(
                        icon: Icons.camera_alt_rounded,
                        label: 'Camera',
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.camera, isProfilePhoto);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildImageOption(
                        icon: Icons.photo_library_rounded,
                        label: 'Gallery',
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.gallery, isProfilePhoto);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: PremiumTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: PremiumTheme.primaryColor.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: PremiumTheme.primaryColor,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: PremiumTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: PremiumTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: lastPickedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: PremiumTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: PremiumTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate != null) {
      lastPickedDate = pickedDate;
      String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
      dobDate = DateFormat('yyyy/MM/dd').format(pickedDate);
      dobController.text = formattedDate;
    }
  }

  Future<void> _submitForm(UserProvider userProvider) async {
    if (formKey.currentState!.validate()) {
      check().then((internet) async {
        if (internet) {
          FocusManager.instance.primaryFocus?.unfocus();
          await userProvider.updateUserProfile(
            userToken,
            nameController.text.toString().trim(),
            mobileNumberController.text.toString().trim(),
            emailController.text.toString().trim(),
            dobDate,
            addressController.text.toString().trim(),
            _imageFile,
            _profilePhoto,
            context,
          );
        } else {
          showWarningToast("No network connection");
        }
      });
    }
  }
}
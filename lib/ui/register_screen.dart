// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:colourmaster/ui/home_screen.dart';
import 'package:colourmaster/ui/premium_login_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

import '../provider/user_provider.dart';
import '../utils/constants.dart';
import '../utils/image_compression.dart';
import '../utils/style/color_constants.dart';
import '../utils/style/text_view_style.dart';
import '../utils/utilsMethods.dart';
import 'component/primaryButton.dart';
import 'component/textField.dart';
import 'component/textView.dart';
import 'widget/loader.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<StatefulWidget> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String agreeError = "";
  bool agreeTerms = false;
  bool isChanged = false;
  File? _imageFile;

  TextEditingController nameController = TextEditingController();
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

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      cropImage(pickedImage, true);
    }
  }

  Future cropImage(XFile imageFile, bool front) async {
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
      _imageFile = ImageCompression().compressAndResizeImage(pickedFile);

      setState(() {
        if (_imageFile != null) {
          aadharController.text = _imageFile!.path;
        }
        _imageFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: ColorConstants.bodyBackgroundColor,
        body: Consumer<UserProvider>(
            builder: (context, UserProvider userProvider, child) {
          return LoadingOverlay(
            isLoading: userProvider.isLoading,
            color: ColorConstants.loadingBackgroundColor
                .withValues(alpha: 0.7), // 50% opacity
            progressIndicator: loadingIndicator(),
            child: SafeArea(
                child: Stack(
              children: [
                SingleChildScrollView(
                    controller: scrollController,
                    scrollDirection: Axis.vertical,
                    child: Padding(
                        padding: const EdgeInsets.only(
                            left: 0.0, right: 0.0, top: 0, bottom: 0),
                        child: Column(children: [
                          Form(
                            key: formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20.0,
                                      right: 20.0,
                                      top: 0,
                                      bottom: 0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Align(
                                          alignment: Alignment.center,
                                          child: Image.asset(
                                              height: 200,
                                              width: 200,
                                              'assets/images/logo.png')),
                                      TextView(
                                        data: "SIGN UP",
                                        fontSize: textLabelFontSize_26,
                                        fontWeight: FontWeight.w700,
                                        textColor: ColorConstants.blackColor,
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      TextView(
                                        data: "Name",
                                        fontSize: textLabelFontSize_16,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Poppins',
                                        textColor: ColorConstants
                                            .grayTextViewLabelColor,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      CustomTextField(
                                        autofillHints: const [
                                          AutofillHints.givenName
                                        ],
                                        hintColor: ColorConstants.hintTextColor,
                                        borderColor:
                                            ColorConstants.editTextBorderColor,
                                        errorColor:
                                            ColorConstants.errorTextColor,
                                        controller: nameController,
                                        hint: "Insert Your Name",
                                        obscureText: false,
                                        textCapitalization:
                                            TextCapitalization.none,
                                        readOnly: false,
                                        inputType: TextInputType.text,
                                        validator: (String? value) {
                                          if (value!.isEmpty) {
                                            return 'Name Required';
                                          } else {
                                            return null;
                                          }
                                        },
                                        onChanged: () {},
                                        onTap: () {},
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      TextView(
                                        data: "Mobile Number",
                                        fontSize: textLabelFontSize_16,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Poppins',
                                        textColor: ColorConstants
                                            .grayTextViewLabelColor,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      CustomTextField(
                                        autofillHints: const [
                                          AutofillHints.telephoneNumber
                                        ],
                                        hintColor: ColorConstants.hintTextColor,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        borderColor:
                                            ColorConstants.editTextBorderColor,
                                        errorColor:
                                            ColorConstants.errorTextColor,
                                        controller: mobileNumberController,
                                        hint: "Insert Your Mobile Number",
                                        obscureText: false,
                                        maxLength: 10,
                                        textCapitalization:
                                            TextCapitalization.none,
                                        readOnly: false,
                                        inputType: TextInputType.number,
                                        validator: (String? value) {
                                          if (value!.isEmpty) {
                                            return 'Mobile Number Required';
                                          } else if (value.length < 10) {
                                            return 'Please enter a valid 10 digit mobile number';
                                          } else {
                                            return null;
                                          }
                                        },
                                        onChanged: () {},
                                        onTap: () {},
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      TextView(
                                        data: "Email ID",
                                        fontSize: textLabelFontSize_16,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Poppins',
                                        textColor: ColorConstants
                                            .grayTextViewLabelColor,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      CustomTextField(
                                        autofillHints: const [
                                          AutofillHints.email
                                        ],
                                        hintColor: ColorConstants.hintTextColor,
                                        borderColor:
                                            ColorConstants.editTextBorderColor,
                                        errorColor:
                                            ColorConstants.errorTextColor,
                                        controller: emailController,
                                        hint: "Insert Your Email ID",
                                        obscureText: false,
                                        textCapitalization:
                                            TextCapitalization.none,
                                        readOnly: false,
                                        inputType: TextInputType.text,
                                        validator: validateEmail,
                                        onChanged: () {},
                                        onTap: () {},
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      TextView(
                                        data: "Address",
                                        fontSize: textLabelFontSize_16,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Poppins',
                                        textColor: ColorConstants
                                            .grayTextViewLabelColor,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      CustomTextField(
                                        autofillHints: const [
                                          AutofillHints.fullStreetAddress
                                        ],
                                        hintColor: ColorConstants.hintTextColor,
                                        borderColor:
                                            ColorConstants.editTextBorderColor,
                                        errorColor:
                                            ColorConstants.errorTextColor,
                                        controller: addressController,
                                        hint: "Insert Your Address",
                                        obscureText: false,
                                        textCapitalization:
                                            TextCapitalization.none,
                                        readOnly: false,
                                        inputType: TextInputType.text,
                                        validator: (String? value) {
                                          if (value!.isEmpty) {
                                            return 'Address Required';
                                          } else {
                                            return null;
                                          }
                                        },
                                        onChanged: () {},
                                        onTap: () {},
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      TextView(
                                        data: "Date Of Birth",
                                        fontSize: textLabelFontSize_16,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Poppins',
                                        textColor: ColorConstants
                                            .grayTextViewLabelColor,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      CustomTextField(
                                        autofillHints: const [
                                          AutofillHints.fullStreetAddress
                                        ],
                                        hintColor: ColorConstants.hintTextColor,
                                        borderColor:
                                            ColorConstants.editTextBorderColor,
                                        errorColor:
                                            ColorConstants.errorTextColor,
                                        controller: dobController,
                                        hint: "DD / MM / YYYY",
                                        obscureText: false,
                                        textCapitalization:
                                            TextCapitalization.none,
                                        readOnly: true,
                                        isDatePicker: true,
                                        onTap: () async {
                                          DateTime? pickedDate =
                                              await showDatePicker(
                                                  builder:
                                                      (BuildContext context,
                                                          Widget? child) {
                                                    return Theme(
                                                      data: ThemeData.light()
                                                          .copyWith(
                                                        datePickerTheme: const DatePickerThemeData(
                                                            backgroundColor:
                                                                Color(
                                                                    0xffA7F1E7),
                                                            inputDecorationTheme:
                                                                InputDecorationTheme(
                                                                    filled:
                                                                        true,
                                                                    fillColor:
                                                                        Colors
                                                                            .black,
                                                                    hintStyle:
                                                                        TextStyle(
                                                                            color:
                                                                                Colors.black))),
                                                        colorScheme:
                                                            const ColorScheme
                                                                .dark(
                                                          // primary: Color(0xff1db09c), //button color
                                                          primary: Colors.black,
                                                          onPrimary:
                                                              Colors.white,
                                                          surface:
                                                              Color(0xffA7F1E7),
                                                          onSurface:
                                                              Colors.black,
                                                        ),
                                                        dialogBackgroundColor:
                                                            Colors.blue[900],
                                                      ),
                                                      child: child!,
                                                    );
                                                  },
                                                  context: context,
                                                  initialDate: lastPickedDate,
                                                  fieldHintText: 'dd/mm/yyyy',
                                                  //get today's date
                                                  firstDate: DateTime(1900),
                                                  //DateTime.now() - not to allow to choose before today.
                                                  lastDate: DateTime.now()
                                                      .subtract(const Duration(
                                                          days: 1)));
                                          if (pickedDate != null) {
                                            lastPickedDate = pickedDate;
                                            String formattedDate =
                                                DateFormat('dd/MM/yyyy').format(
                                                    pickedDate); // format date in required form here we use yyyy-MM-dd that means time is removed
                                            dobDate = DateFormat('yyyy/MM/dd')
                                                .format(
                                                    pickedDate); // format date in required form here we use yyyy-MM-dd that means time is removed
                                            dobController.text = formattedDate;
                                          }
                                        },
                                        showSuffixIcon: false,
                                        inputType: TextInputType.none,
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Select your Date of Birth';
                                          }
                                          return null;
                                        },
                                        onChanged: () {},
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      /* TextView(
                                        data: "Aadhar KYC",
                                        fontSize: textLabelFontSize_16,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Poppins',
                                        textColor: ColorConstants
                                            .grayTextViewLabelColor,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      CustomTextField(
                                        autofillHints: const [
                                          AutofillHints.fullStreetAddress
                                        ],
                                        hintColor: ColorConstants.hintTextColor,
                                        borderColor:
                                            ColorConstants.editTextBorderColor,
                                        errorColor:
                                            ColorConstants.errorTextColor,
                                        controller: aadharController,
                                        hint: "Upload Your Aadhar KYC",
                                        obscureText: false,
                                        textCapitalization:
                                            TextCapitalization.none,
                                        isFilePicker: true,
                                        readOnly: true,
                                        onTap: () async {
                                          filePicker();
                                        },
                                        showSuffixIcon: false,
                                        inputType: TextInputType.none,
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Select Aadhar Card Image';
                                          }
                                          return null;
                                        },
                                        onChanged: () {},
                                      ),
                                      SizedBox(
                                          height: _imageFile != null ? 10 : 0),
                                      _imageFile != null
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Center(
                                                    child: Image.file(
                                                  height: 100,
                                                  width: 100,
                                                  File(_imageFile!.path),
                                                  fit: BoxFit.cover,
                                                )),
                                                TextButton(
                                                    onPressed: () {
                                                      filePicker();
                                                    },
                                                    child: TextView(
                                                      textColor: ColorConstants
                                                          .blackColor,
                                                      data:
                                                          "Change Aadhar Photo",
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      decoration: TextDecoration
                                                          .underline,
                                                    ))
                                              ],
                                            )
                                          : const SizedBox(),*/
                                      CheckboxListTile(
                                        activeColor:
                                            ColorConstants.primaryButtonColor,
                                        contentPadding: EdgeInsets.zero,
                                        title: RichText(
                                            text:
                                                TextSpan(children: <InlineSpan>[
                                          TextSpan(
                                              text: 'Read and accept ',
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                color:
                                                    ColorConstants.blackColor,
                                                fontWeight: FontWeight.w400,
                                              )),
                                          TextSpan(
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () {
                                                  redirectToBrowser(Uri.parse(
                                                      termConditionURL));
                                                },
                                              text: 'Terms and Condition.',
                                              style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  color:
                                                      ColorConstants.blackColor,
                                                  fontWeight: FontWeight.w500,
                                                  decoration:
                                                      TextDecoration.underline,
                                                  decorationColor: Colors.black,
                                                  decorationThickness: 2,
                                                  decorationStyle:
                                                      TextDecorationStyle
                                                          .solid)),
                                        ])),
                                        value: selectedValue,
                                        onChanged: (newValue) {
                                          if (newValue == true) {
                                            isCheckBoxSelected = 1;
                                          } else if (newValue == false) {
                                            isCheckBoxSelected = 0;
                                          }
                                          setState(() {
                                            isCheckBoxSelected;
                                            selectedValue = newValue!;
                                          });
                                        },
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                      ),
                                      isCheckBoxSelected == 0
                                          ? TextView(
                                              data:
                                                  "Please accept the terms & conditions",
                                              textColor:
                                                  ColorConstants.errorTextColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400)
                                          : const SizedBox(),
                                      const SizedBox(
                                        height: 40,
                                      ),
                                      PrimaryButton(
                                        text: 'Sign Up',
                                        onPressed: () async {
                                          if (selectedValue == false) {
                                            setState(() {
                                              isCheckBoxSelected = 0;
                                            });
                                          }
                                          if (formKey.currentState!
                                              .validate()) {
                                            if (selectedValue) {
                                              check().then((internet) async {
                                                if (internet) {
                                                  // Internet Present Case
                                                  FocusManager
                                                      .instance.primaryFocus
                                                      ?.unfocus();
                                                  await userProvider
                                                      .registerUser(
                                                          nameController.text
                                                              .toString()
                                                              .trim(),
                                                          mobileNumberController
                                                              .text
                                                              .toString()
                                                              .trim(),
                                                          emailController.text
                                                              .toString()
                                                              .trim(),
                                                          dobDate,
                                                          addressController.text
                                                              .toString()
                                                              .trim(),
                                                          _imageFile,
                                                          context);
                                                } else {
                                                  // No-Internet Case
                                                  showWarningToast(
                                                      "No network connection");
                                                }
                                              });
                                            }
                                          } else {
                                            if (kDebugMode) {
                                              print("Not Validated");
                                            }
                                          }
                                        },
                                      ),
                                      const SizedBox(
                                        height: 40,
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    TextView(
                                        data: "Already have an account?",
                                        textColor: ColorConstants.blackColor,
                                        fontSize: textLabelFontSize_14,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w500),
                                    TextButton(
                                      child: TextView(
                                          data: "SIGN IN",
                                          textColor: ColorConstants.blackColor,
                                          fontSize: textLabelFontSize_14,
                                          fontWeight: FontWeight.w800),
                                      onPressed: () {
                                        //signup screen
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                              const PremiumLoginScreen()),
                                        );
                                      },
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ]))),
              ],
            )),
          );
        }));
  }

  filePicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: TextView(
                  data: "Take Picture",
                  fontSize: textLabelFontSize_16,
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w400,
                  textColor: ColorConstants.blackColor,
                  textAlign: TextAlign.left,
                ),
                onTap: () {
                  _pickImage(
                    ImageSource.camera,
                  );
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: TextView(
                  data: "Select Picture",
                  fontSize: textLabelFontSize_16,
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w400,
                  textColor: ColorConstants.blackColor,
                  textAlign: TextAlign.left,
                ),
                onTap: () {
                  _pickImage(
                    ImageSource.gallery,
                  );
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  redirectToHomeScreen() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (BuildContext context) => const HomeScreen()),
        (Route<dynamic> route) => false);
  }
}

// ignore_for_file: depend_on_referenced_packages
import 'dart:io';

import 'package:colourmaster/ui/home_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';

import '../provider/user_provider.dart';
import '../utils/style/color_constants.dart';
import '../utils/style/text_view_style.dart';
import '../utils/utilsMethods.dart';
import 'component/primaryButton.dart';
import 'component/textField.dart';
import 'component/textView.dart';
import 'register_screen.dart';
import 'widget/loader.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController mobileController = TextEditingController();
  ScrollController scrollController = ScrollController();
  SharedPreferences? sharedPreferences;
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: ColorConstants.statusBarColor));

    mobileController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  redirectToHomeScreen() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (BuildContext context) => const HomeScreen()),
        (Route<dynamic> route) => false);
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
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    /*Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Expanded( flex: 1,child:IconButton(
                                              icon: Image.asset('assets/images/backarrow.png',
                                                height: 30,width: 30,
                                              ),
                                              onPressed:(){onBackPressed();},
                                            ),),
                                            Expanded(flex:5,child: Align(
                                                alignment: Alignment.center,
                                                child:TextView(data:"Buzzworks",fontSize:textLabelFontSize_24,
                                                  fontWeight:FontWeight.w400, textColor: ColorConstants.blackColor,fontFamily: "SuisseWorks",)
                                            ),),
                                            const SizedBox(
                                              width: 45, // width of the icon
                                            ),
                                          ],
                                        ),*/
                                    const SizedBox(
                                      height: 25,
                                    ),
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
                                          const SizedBox(
                                            height: 0,
                                          ),
                                          TextView(
                                            data: "Welcome Back!",
                                            fontSize: textLabelFontSize_26,
                                            fontWeight: FontWeight.w700,
                                            textColor:
                                                ColorConstants.blackColor,
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
                                            hintColor:
                                                ColorConstants.hintTextColor,
                                            borderColor: ColorConstants
                                                .editTextBorderColor,
                                            errorColor:
                                                ColorConstants.errorTextColor,
                                            controller: mobileController,
                                            hint: "Insert Your Mobile Number",
                                            obscureText: false,
                                            textCapitalization:
                                                TextCapitalization.none,
                                            readOnly: false,
                                            maxLength: 10,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly
                                            ],
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
                                          PrimaryButton(
                                            text: 'Sign In',
                                            onPressed: () async {
                                              if (formKey.currentState!
                                                  .validate()) {
                                                check().then((internet) async {
                                                  if (internet) {
                                                    // Internet Present Case
                                                    FocusManager
                                                        .instance.primaryFocus
                                                        ?.unfocus();
                                                    await userProvider
                                                        .loginUser(
                                                            mobileController
                                                                .text
                                                                .toString()
                                                                .trim(),
                                                            context);
                                                  } else {
                                                    // No-Internet Case
                                                    showWarningToast(
                                                        "No network connection");
                                                  }
                                                });
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
                                  ],
                                ),
                              ),
                            ]))),
                    Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            TextView(
                                data: "Don’t have an account?",
                                textColor: ColorConstants.blackColor,
                                fontSize: textLabelFontSize_14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500),
                            TextButton(
                              child: TextView(
                                  data: "SIGN UP",
                                  textColor: ColorConstants.blackColor,
                                  fontSize: textLabelFontSize_14,
                                  fontWeight: FontWeight.w800),
                              onPressed: () {
                                //signup screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterScreen()),
                                );
                              },
                            )
                          ],
                        ))
                  ],
                )),
              );
            })));
  }

  onBackPressed() {
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    } else {
      SystemNavigator.pop();
    }
  }
}

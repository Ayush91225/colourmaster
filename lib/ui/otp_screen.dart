// ignore_for_file: depend_on_referenced_packages
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import '../models/loginModel/Login.dart';
import '../networkCall/ApiService.dart';
import '../provider/user_provider.dart';
import '../utils/style/color_constants.dart';
import '../utils/style/text_view_style.dart';
import '../utils/utilsMethods.dart';
import 'component/primaryButton.dart';
import 'component/textView.dart';
import 'home_screen.dart';
import 'widget/loader.dart';

class OTPScreen extends StatefulWidget {
  final String userMobile;
  OTPScreen(this.userMobile, {super.key});
  @override
  State<StatefulWidget> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  ScrollController scrollController = ScrollController();
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  bool enableResend = false;
  int timerMaxSeconds = 30;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    setState(() {
      pinController.setText("1111");
    });
    check().then((internet) async {
      if (internet) {
        FocusManager.instance.primaryFocus?.unfocus();
        Future.delayed(const Duration(seconds: 2), () async {
          final userProvider =
              Provider.of<UserProvider>(context, listen: false);
          await userProvider.userOTPVerify(
              widget.userMobile, pinController.text.toString().trim(), context);
          pinController.clear();
          FocusScope.of(context).requestFocus(focusNode);
        });
      } else {
        // No-Internet Case
        showWarningToast("No network connection");
      }
    });
    startTimer();
  }

  void _resendCode() {
    setState(() {
      timerMaxSeconds = 30;
      enableResend = false;
    });
  }

  startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (timerMaxSeconds != 0) {
        setState(() {
          timerMaxSeconds--;
        });
      } else {
        setState(() {
          enableResend = true;
        });
      }
    });
  }

  @override
  void dispose() {
    timer!.cancel();
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 50,
      textStyle: const TextStyle(
          fontSize: 22, fontWeight: FontWeight.w500, fontFamily: 'Poppins'),
      decoration: BoxDecoration(
        border: Border.all(color: ColorConstants.editTextBorderColor),
        color: ColorConstants.whiteColor,
        borderRadius: BorderRadius.circular(5),
      ),
    );
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
                child: Stack(children: [
              SingleChildScrollView(
                child: Center(
                  child: Padding(
                      padding: const EdgeInsets.only(
                          left: 10.0, right: 10.0, top: 0, bottom: 0),
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            const SizedBox(
                              height: 20,
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: IconButton(
                                icon: Image.asset(
                                  'assets/images/backarrow.png',
                                  color: ColorConstants.primaryButtonColor,
                                  height: 30,
                                  width: 30,
                                ),
                                onPressed: () {
                                  if (Navigator.canPop(context)) {
                                    //Navigator.pop(context);
                                    Navigator.of(context).pop();
                                  } else {
                                    SystemNavigator.pop();
                                  }
                                },
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(
                                    left: 20.0, right: 20.0, top: 0, bottom: 0),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Align(
                                          alignment: Alignment.center,
                                          child: TextView(
                                            data:
                                                "We need to verify\nyour mobile number",
                                            textAlign: TextAlign.center,
                                            fontSize: textLabelFontSize_20,
                                            fontWeight: FontWeight.w400,
                                            textColor:
                                                ColorConstants.blackButtonColor,
                                            fontFamily: 'Poppins',
                                          )),
                                      TextButton(
                                          onPressed: () {
                                            check().then((internet) {
                                              if (internet) {
                                                if (enableResend) {
                                                  userProvider.isLoading = true;
                                                  pinController.clear();
                                                  resendPin();
                                                }
                                              } else {
                                                // No-Internet Case
                                                showWarningToast(
                                                    "No network connection");
                                              }
                                            });
                                          },
                                          child: enableResend
                                              ? Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    TextView(
                                                      data: widget.userMobile,
                                                      textColor: ColorConstants
                                                          .textViewLabeledColor,
                                                      fontSize:
                                                          textLabelFontSize_14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontFamily: 'Poppins',
                                                    ),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    TextView(
                                                      data: "Resend",
                                                      textColor: ColorConstants
                                                          .textViewLabeledColor,
                                                      fontSize:
                                                          textLabelFontSize_14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontFamily: 'Poppins',
                                                    ),
                                                  ],
                                                )
                                              : Center(
                                                  child: Text(
                                                    'Resend code after $timerMaxSeconds seconds',
                                                    style: const TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 14,
                                                        fontFamily: "Poppins",
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                )),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Directionality(
                                            // Specify direction if desired
                                            textDirection: TextDirection.ltr,
                                            child: Pinput(
                                                length: 4,
                                                // Text will be displayed under the Pinput
                                                controller: pinController,
                                                focusNode: focusNode,
                                                autofocus: true,
                                                defaultPinTheme:
                                                    defaultPinTheme,
                                                pinputAutovalidateMode:
                                                    PinputAutovalidateMode
                                                        .onSubmit,
                                                hapticFeedbackType:
                                                    HapticFeedbackType
                                                        .lightImpact,
                                                onCompleted: (pin) {
                                                  check()
                                                      .then((internet) async {
                                                    if (internet) {
                                                      FocusManager
                                                          .instance.primaryFocus
                                                          ?.unfocus();
                                                      await userProvider
                                                          .userOTPVerify(
                                                              widget.userMobile,
                                                              pinController.text
                                                                  .toString()
                                                                  .trim(),
                                                              context);
                                                      pinController.clear();
                                                      FocusScope.of(context)
                                                          .requestFocus(
                                                              focusNode);
                                                    } else {
                                                      // No-Internet Case
                                                      showWarningToast(
                                                          "No network connection");
                                                    }
                                                  });
                                                },
                                                onChanged: (value) {
                                                  if (kDebugMode) {
                                                    print('onChanged: $value');
                                                  }
                                                },
                                                cursor: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              bottom: 9),
                                                      width: 22,
                                                      height: 1,
                                                      color: ColorConstants
                                                          .blackColor,
                                                    ),
                                                  ],
                                                ),
                                                focusedPinTheme:
                                                    defaultPinTheme,
                                                submittedPinTheme:
                                                    defaultPinTheme,
                                                errorPinTheme: defaultPinTheme),
                                          ),
                                          const SizedBox(
                                            height: 15,
                                          ),
                                          TextView(
                                            data:
                                                "Please enter the 4 digit one time code you received to your mobile number",
                                            textColor: ColorConstants
                                                .textViewLabeledColor,
                                            fontSize: textLabelFontSize_12,
                                            fontWeight: FontWeight.w400,
                                            fontFamily: 'Poppins',
                                          ),
                                          const SizedBox(
                                            height: 40,
                                          ),
                                          PrimaryButton(
                                            text: 'Verify',
                                            onPressed: () async {
                                              if (pinController.text.length !=
                                                  4) {
                                                FocusScope.of(context)
                                                    .requestFocus(focusNode);
                                                FocusScopeNode currentFocus =
                                                    FocusScope.of(context);
                                                if (!currentFocus
                                                    .hasPrimaryFocus) {
                                                  currentFocus.unfocus();
                                                }
                                                showToastMessage("Enter Pin");
                                              } else {
                                                check().then((internet) async {
                                                  if (internet) {
                                                    FocusManager
                                                        .instance.primaryFocus
                                                        ?.unfocus();
                                                    await userProvider
                                                        .userOTPVerify(
                                                            widget.userMobile,
                                                            pinController.text
                                                                .toString()
                                                                .trim(),
                                                            context);
                                                    pinController.clear();
                                                    FocusScope.of(context)
                                                        .requestFocus(
                                                            focusNode);
                                                  } else {
                                                    // No-Internet Case
                                                    showWarningToast(
                                                        "No network connection");
                                                  }
                                                });
                                              }
                                            },
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                        ],
                                      ),
                                    ])),
                          ],
                        ),
                      )),
                ),
              ),
            ])),
          );
        }));
  }

  void resendPin() async {
    Login? verifyOTPRes = await ApiService().resendOTP(widget.userMobile);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.isLoading = false;
    if (verifyOTPRes!.status == 1) {
      _resendCode();
      if (!context.mounted) return;
      showSuccessToast(context, verifyOTPRes.message!.toString());
    } else {
      setState(() {
        pinController.clear();
      });
      if (!context.mounted) return;
      showFailedToast(context, verifyOTPRes.message!.toString());
    }
  }

  redirectToHomeScreen() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (BuildContext context) => const HomeScreen()),
        (Route<dynamic> route) => false);
  }
}

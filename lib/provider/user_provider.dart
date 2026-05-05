// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:colourmaster/main_screen.dart';
import 'package:colourmaster/models/QRRedeem.dart';
import 'package:colourmaster/models/Transaction.dart';
import 'package:colourmaster/ui/premium_login_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/utilsMethods.dart';
import '../models/Dashboard.dart';
import '../models/GiftData.dart';
import '../models/Product.dart';
import '../models/userModel/UserProfile.dart';
import '../networkCall/ApiService.dart';
import '../ui/premium_otp_screen.dart';
import '../utils/global_key.dart';
import '../utils/sharedPreferenceKey.dart';

class UserProvider extends ChangeNotifier {
  final _service = ApiService();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  UserProfileData? get userProfileData => _userProfileData;
  UserProfileData? _userProfileData;

  List<TransactionData> _transactionDataArr = [];
  List<TransactionData> get transactionDataArr => _transactionDataArr;

  List<ProductData> _productArr = [];
  List<ProductData> get productArr => _productArr;

  GiftData? get giftData => _giftData;
  GiftData? _giftData;

  Dashboard? get dashboardData => _dashboardData;
  Dashboard? _dashboardData;

  String _appVersion = "";
  String get appVersion => _appVersion;

  set productArr(List<ProductData> value) {
    _productArr = value;
    notifyListeners();
  }

  set transactionDataArr(List<TransactionData> value) {
    _transactionDataArr = value;
    notifyListeners();
  }

  set dashboardData(Dashboard? value) {
    _dashboardData = value!;
    notifyListeners();
  }

  set giftData(GiftData? value) {
    _giftData = value!;
    notifyListeners();
  }

  set appVersion(String value) {
    _appVersion = value;
    notifyListeners();
  }

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  set userProfileData(UserProfileData? value) {
    _userProfileData = value!;
    notifyListeners();
  }

  Future<void> loginUser(var mobile, BuildContext context) async {
    isLoading = true;
    final loginRes = await _service.fetchLogin(mobile);
    isLoading = false;
    if (loginRes!.status == 1) {
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PremiumOTPScreen(mobile)),
      );
    } else {
      showAlertDialog2(context, loginRes.message!.toString());
    }
    notifyListeners();
  }

  Future<void> registerUser(var fullName, var mobile, var email, var dob,
      var address, File? adharImg, BuildContext context) async {
    isLoading = true;
    final registerRes = await _service.registerUser(
      fullName,
      mobile,
      email,
      dob,
      address,
      adharImg,
    );
    debugPrint("registerRes:${registerRes}");
    isLoading = false;
    if (registerRes!.status == 1) {
      showSuccessToast(context, registerRes.message!);
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PremiumOTPScreen("$mobile")),
      );
    } else {
      if (registerRes.data != null) {
        final responsedData = registerRes.data!.toJson();
        showFailedToast(context, responsedData.toString());
      } else {
        showFailedToast(context, registerRes.message!.toString());
      }
    }
    notifyListeners();
  }

  Future<void> userOTPVerify(var mobile, var otp, BuildContext context) async {
    isLoading = true;
    final loginRes = await _service.verifyMobileOTP(otp, mobile);
    isLoading = false;
    if (loginRes!.status == 1) {
      showSuccessToast(context, loginRes.message!.toString());
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.setBool(LOGIN_STATUS, true);
      sharedPreferences.setInt(USERID, loginRes.data!.user!.id);
      sharedPreferences.setString(USEREMAIL, loginRes.data!.user!.email ?? "");
      sharedPreferences.setString(TOKEN, "Bearer ${loginRes.data!.token!}");
      sharedPreferences.setString(FULLNAME, "${loginRes.data!.user!.name}");
      sharedPreferences.setString(
          USERMOBILE, "${loginRes.data!.user!.mobileNumber}");
      sharedPreferences.setString(
          USERBALANCE, "${loginRes.data!.user!.balance}");
      sharedPreferences.setString(
          USERPHOTO, "${loginRes.data!.user!.profileImage ?? ""}");
      loginStatus = sharedPreferences.getBool(LOGIN_STATUS)!;
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (BuildContext context) => const MainScreen(0, "")),
          (Route<dynamic> route) => false);
    } else {
      showAlertDialog2(context, loginRes.message!.toString());
    }
    notifyListeners();
  }

  Future<void> fetchUserDetails(BuildContext context, var token) async {
    final loginRes = await _service.apiFetchUserDetails(context, token);
    if (loginRes!.status == 1) {
      _userProfileData = loginRes.data!;
    } else {
      showFailedToast(context, loginRes.message!.toString());
    }
    notifyListeners();
  }

  Future<void> fetchGiftList(BuildContext context, var token) async {
    isLoading = true;
    final loginRes = await _service.apiFetchGiftList(token);
    isLoading = false;
    if (loginRes!.status == 1) {
      _giftData = loginRes;
    } else {
      showFailedToast(context, loginRes.message!.toString());
    }
    notifyListeners();
  }

  Future<void> fetchDashboard(BuildContext context, var token) async {
    isLoading = true;
    final Response = await _service.apiFetchDashboard(context, token);
    isLoading = false;
    if (Response!.status == 1) {
      _dashboardData = Response;
    } else {
      showFailedToast(context, Response.message!.toString());
    }
    notifyListeners();
  }

  Future<void> updateUserProfile(
      var token,
      var fullName,
      var mobile,
      var email,
      var dob,
      var address,
      File? adharImg,
      File? userPhoto,
      BuildContext context) async {
    isLoading = true;
    final userRes = await _service.updateUserProfile(
        token,
        fullName,
        mobile,
        email,
        dob,
        address,
        adharImg,
        userPhoto);
    debugPrint("registerRes:${userRes}");
    isLoading = false;
    if (userRes!.status == 1) {
      showSuccessToast(context, userRes.message!.toString());
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.setString(USEREMAIL, userRes.data!.email ?? "");
      sharedPreferences.setString(FULLNAME, "${userRes.data!.name}");
      sharedPreferences.setString(
          USERPHOTO, "${userRes.data!.profileImage ?? ""}");
    } else {
      if (userRes.data != null) {
        final responsedData = userRes.data!.toJson();
        showFailedToast(context, responsedData.toString());
      } else {
        showFailedToast(context, userRes.message!.toString());
      }
    }
    notifyListeners();
  }

  Future<void> redeemQRCode(BuildContext context, var token, var qrID) async {
    isLoading = true;
    final Response = await _service.apiRedeemQRCode(token, qrID);
    isLoading = false;
    if (Response!.status == 1) {
      if (Response.alreadyUseQrUserData != null) {
        showFailedToast(context, Response.message!.toString());
        showAlertDialog(
            context, Response.message, Response.alreadyUseQrUserData!);
      } else {
        var productName = "";
        var loyaltyText =
            "Current loyalty points is ${Response.balance.toString()}";
        if (Response.scannedQRData!.qrType == "product") {
          loyaltyText = "";
          productName = Response.productName ?? "";
        }

        var message = "$productName\nQR CODE SCANNED SUCCESSFULLY!!!\n"
            "${Response.scannedQRData!.points.toString()} points have been added to your account."
            "$loyaltyText";
        showSuccessQRAlertDialog(context, message);
        /* Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
            builder: (BuildContext context) =>  const MainScreen(0,"")),
                (Route<dynamic> route) => false);*/
      }
    } else {
      showFailedToast(context, Response.message!.toString());
    }
    notifyListeners();
  }

  Future<void> redemptionRequest(BuildContext context, var redemptionType,
      var token, var points, var giftID) async {
    isLoading = true;
    final Response =
        await _service.redemptionRequest(token, redemptionType, points, giftID);
    isLoading = false;
    if (Response!.status == 1) {
      showSuccessToast(context, Response.message!.toString());
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (BuildContext context) => const MainScreen(0, "")),
          (Route<dynamic> route) => false);
    } else {
      showFailedToast(context, Response.message!.toString());
    }
    notifyListeners();
  }

  Future<void> userLogout(var token, BuildContext context) async {
    isLoading = true;
    final Response = await _service.userLogOut(
      token,
    );
    isLoading = false;
    if (Response!.status == 1) {
      showSuccessToast(context, Response.message!.toString());
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.setString(TOKEN, "");
      sharedPreferences.setString(USERBALANCE, "");
      sharedPreferences.setBool(LOGIN_STATUS, false);
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => const PremiumLoginScreen()),
          (Route<dynamic> route) => false);
    } else {
      showFailedToast(context, Response.message!.toString());
    }
    notifyListeners();
  }

  Future<void> fetchTransactionList(
      BuildContext context, var token, var startDate, var endDate) async {
    isLoading = true;
    final res =
        await _service.apiFetchTransactionList(token, startDate, endDate);
    isLoading = false;
    if (res!.status == 1) {
      _transactionDataArr = res.data!;
    } else {
      showFailedToast(context, res.message!.toString());
    }
    notifyListeners();
  }

  showAlertDialog(BuildContext context, var message,
      AlreadyUseQrUserData alreadyUserQRData) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      content: Text("${message} by ${alreadyUserQRData.name}"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showSuccessQRAlertDialog(BuildContext context, var message) {
    Widget okButton = TextButton(
      child: const Text("Yes"),
      onPressed: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen(2, "")),
        );
      },
    );
    // set up the button
    Widget noButton = TextButton(
      child: const Text("No"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Confirmation"),
      content: Text("$message\nDo you want to continue scan QR Code?"),
      actions: [okButton, noButton],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showAlertDialog2(BuildContext context, var message) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => const PremiumLoginScreen()),
            (Route<dynamic> route) => false);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      content: Text("${message}"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> fetchCashTransactionList(
      BuildContext context, var token, var startDate, var endDate) async {
    isLoading = true;
    final res =
        await _service.apiFetchCashTransactionList(token, startDate, endDate);
    isLoading = false;
    if (res!.status == 1) {
      _transactionDataArr = res.data!;
    } else {
      showFailedToast(context, res.message!.toString());
    }
    notifyListeners();
  }

  Future<void> fetchProductTransactionList(
      BuildContext context, var token, var startDate, var endDate) async {
    isLoading = true;
    final res = await _service.apiFetchProductTransactionList(
        token, startDate, endDate);
    isLoading = false;
    if (res!.status == 1) {
      _transactionDataArr = res.data!;
    } else {
      showFailedToast(context, res.message!.toString());
    }
    notifyListeners();
  }

  Future<void> fetchProductList(
      BuildContext context, var token, var startDate, var endDate) async {
    isLoading = true;
    final res = await _service.apiFetchProductList(token, startDate, endDate);
    isLoading = false;
    if (res!.status == "success") {
      _productArr = res.productDataArr!;
    } else {
      showFailedToast(context, res.message!.toString());
    }
    notifyListeners();
  }

  Future<void> checkLogin(BuildContext context, var token) async {
    isLoading = true;
    final loginRes = await _service.apiFetchUserDetails(context, token);
    isLoading = false;
    if (loginRes!.status == 1) {
      if (loginRes.data?.status == "active") {
        if (!context.mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (BuildContext context) => const MainScreen(0, "")),
            (Route<dynamic> route) => false);
      } else {
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        sharedPreferences.clear();
        if (!context.mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => const PremiumLoginScreen()),
            (Route<dynamic> route) => false);
      }
    } else {
      if (!context.mounted) return;
      showFailedToast(context, loginRes.message!.toString());
    }
    notifyListeners();
  }
}

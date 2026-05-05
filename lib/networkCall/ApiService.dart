// ignore_for_file: depend_on_referenced_packages
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:colourmaster/models/Product.dart';
import 'package:colourmaster/models/QRRedeem.dart';
import 'package:colourmaster/models/Transaction.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:retry/retry.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/Dashboard.dart';
import '../models/GiftData.dart';
import '../models/loginModel/Login.dart';
import '../models/registerModel/Register.dart';
import '../models/userModel/UserProfile.dart';
import '../ui/premium_login_screen.dart';
import '../utils/constants.dart';
import '../utils/sharedPreferenceKey.dart';
import '../utils/utilsMethods.dart';
import '../utils/app_config.dart';
import 'config.dart';

class ApiService {
  var apiRetry = const RetryOptions(maxAttempts: 3);
  Future<Register?> registerUser(
    var fullName,
    var mobile,
    var email,
    var dob,
    var address,
    File? adharImg,
  ) async {
    try {
      var request =
          http.MultipartRequest('POST', Uri.parse(AppConfig.baseURL + apiRegister));
      request.fields.addAll({
        'name': fullName,
        'email': email,
        'mobile_number': mobile,
        'dob': dob,
        'address': address,
      });
      //debugPrint("addharImg ${adharImg.path}");
      if (adharImg != null) {
        request.files.add(
            await http.MultipartFile.fromPath('aadhaar_image', adharImg.path));
      }

      var response =
          await request.send().timeout(Duration(seconds: apiTimeOutSeconds));
      var responsed = await http.Response.fromStream(response);
      debugPrint("statusCode:${response.statusCode}");
      if (!AppConfig.isProduction && kDebugMode) {
        print(AppConfig.baseURL + apiRegister);
        // Remove sensitive data logging in production
      }
      return Register.fromJson(jsonDecode(responsed.body));
    } catch (e) {
      log(e.toString());
      showErrorToast(e.toString());
    }
    return null;
  }

  Future<Login?> fetchLogin(var mobile) async {
    try {
      Map data = {
        'mobile_number': mobile,
      };
      var response = await apiRetry.retry(
        () => http
            .post(
              Uri.parse(AppConfig.baseURL + apiLogin),
              body: data,
            )
            .timeout(Duration(seconds: apiTimeOutSeconds)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );

      if (kDebugMode) {
        print(AppConfig.baseURL + apiLogin);
        print(data);
        final prettyString = const JsonEncoder.withIndent('  ')
            .convert(json.decode(response.body));
        log(prettyString);
      }
      debugPrint("statusCode=>${response.statusCode}");
      return Login.fromJson(jsonDecode(response.body));
    } catch (e) {
      log(e.toString());
      showErrorToast(e.toString());
    }
    return null;
  }

  Future<UserProfile?> apiFetchUserDetails(
      BuildContext context, var token) async {
    try {
      var response = await apiRetry.retry(
        () => http.get(
          Uri.parse(AppConfig.baseURL + apiUserDetails),
          headers: {'Accept': 'application/json', "Authorization": token},
        ).timeout(Duration(seconds: apiTimeOutSeconds)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );

      if (kDebugMode) {
        print(AppConfig.baseURL + apiUserDetails);
        final prettyString = const JsonEncoder.withIndent('  ')
            .convert(json.decode(response.body));
        log(prettyString);
      }
      debugPrint("statusCode=>${response.statusCode}");
      if (response.statusCode == 401) {
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        sharedPreferences.clear();
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => const PremiumLoginScreen()),
            (Route<dynamic> route) => false);
      }
      return UserProfile.fromJson(jsonDecode(response.body));
    } catch (e) {
      log(e.toString());
      showErrorToast(e.toString());
    }
    return null;
  }

  Future<GiftData?> apiFetchGiftList(var token) async {
    try {
      var response = await apiRetry.retry(
        () => http.get(
          Uri.parse(AppConfig.baseURL + apiGift),
          headers: {'Accept': 'application/json', "Authorization": token},
        ).timeout(Duration(seconds: apiTimeOutSeconds)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );

      if (kDebugMode) {
        print(AppConfig.baseURL + apiGift);
        final prettyString = const JsonEncoder.withIndent('  ')
            .convert(json.decode(response.body));
        log(prettyString);
      }
      debugPrint("statusCode=>${response.statusCode}");
      return GiftData.fromJson(jsonDecode(response.body));
    } catch (e) {
      log(e.toString());
      showErrorToast(e.toString());
    }
    return null;
  }

  Future<Dashboard?> apiFetchDashboard(BuildContext context, var token) async {
    try {
      var response = await apiRetry.retry(
        () => http.get(
          Uri.parse(AppConfig.baseURL + apiDashboard),
          headers: {'Accept': 'application/json', "Authorization": token},
        ).timeout(Duration(seconds: apiTimeOutSeconds)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );

      if (kDebugMode) {
        print(AppConfig.baseURL + apiDashboard);
        final prettyString = const JsonEncoder.withIndent('  ')
            .convert(json.decode(response.body));
        log(prettyString);
      }
      debugPrint("statusCode=>${response.statusCode}");
      if (response.statusCode == 401) {
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        sharedPreferences.setString(TOKEN, "");
        sharedPreferences.setString(USERBALANCE, "");
        sharedPreferences.setBool(LOGIN_STATUS, false);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => const PremiumLoginScreen()),
            (Route<dynamic> route) => false);
      } else {
        return Dashboard.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      log(e.toString());
      showErrorToast(e.toString());
    }
    return null;
  }

  Future<QRRedeem?> apiRedeemQRCode(var token, var qrID) async {
    try {
      Map data = {
        'qr_id': qrID,
      };
      var response = await apiRetry.retry(
        () => http
            .post(Uri.parse(AppConfig.baseURL + qrRedeem),
                headers: {'Accept': 'application/json', "Authorization": token},
                body: data)
            .timeout(Duration(seconds: apiTimeOutSeconds)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );

      debugPrint(AppConfig.baseURL + qrRedeem);
      final prettyString = const JsonEncoder.withIndent('  ')
          .convert(json.decode(response.body));
      log(prettyString);
      debugPrint("statusCode=>${response.statusCode}");
      return QRRedeem.fromJson(jsonDecode(response.body));
    } catch (e) {
      log(e.toString());
      showErrorToast(e.toString());
    }
    return null;
  }

  Future<Login?> verifyMobileOTP(var otp, var mobile) async {
    try {
      Map data = {
        'otp': otp,
        'mobile_number': mobile,
      };
      var response = await apiRetry.retry(
        () => http
            .post(Uri.parse(AppConfig.baseURL + apiVerifyOTP), body: data)
            .timeout(Duration(seconds: apiTimeOutSeconds)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );

      if (kDebugMode) {
        print(AppConfig.baseURL + apiVerifyOTP);
        print(data);
        final prettyString = const JsonEncoder.withIndent('  ')
            .convert(json.decode(response.body));
        log(prettyString);
      }
      debugPrint("statusCode=>${response.statusCode}");
      return Login.fromJson(jsonDecode(response.body));
    } catch (e) {
      log(e.toString());
      showErrorToast(e.toString());
    }
    return null;
  }

  Future<Login?> resendOTP(var userMobile) async {
    try {
      Map data = {
        'mobile_number': userMobile,
      };
      var response = await apiRetry.retry(
        () => http
            .post(Uri.parse(AppConfig.baseURL + apiResentOTP), body: data)
            .timeout(Duration(seconds: apiTimeOutSeconds)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );

      if (kDebugMode) {
        print(AppConfig.baseURL + apiResentOTP);
        print(data);
        final prettyString = const JsonEncoder.withIndent('  ')
            .convert(json.decode(response.body));
        log(prettyString);
      }
      debugPrint("statusCode=>${response.statusCode}");
      return Login.fromJson(jsonDecode(response.body));
    } catch (e) {
      log(e.toString());
      showErrorToast(e.toString());
      return null;
    }
  }

  Future<QRRedeem?> redemptionRequest(
      var token, var redemptionType, var points, var giftID) async {
    var id = redemptionType == "product" ? "product_id" : "gift_id";
    try {
      debugPrint("token:$token");
      debugPrint(json.encode({
        'redemption_type': redemptionType.toString().toLowerCase(),
        'points': points,
        id: giftID,
      }));

      var response = await apiRetry.retry(
        () => http
            .post(Uri.parse(AppConfig.baseURL + apiRedemptionRequest),
                headers: {
                  'Accept': 'application/json',
                  'Content-Type': 'application/json',
                  "Authorization": token
                },
                body: json.encode({
                  'redemption_type': redemptionType.toString().toLowerCase(),
                  'points': points,
                  id: giftID,
                }))
            .timeout(Duration(seconds: apiTimeOutSeconds)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );

      if (kDebugMode) {
        print(AppConfig.baseURL + apiRedemptionRequest);
        print(response.body.toString());
        final prettyString = const JsonEncoder.withIndent('  ')
            .convert(json.decode(response.body));
        log(prettyString);
      }
      debugPrint("statusCode=>${response.statusCode}");
      return QRRedeem.fromJson(jsonDecode(response.body));
    } catch (e) {
      log(e.toString());
      showErrorToast(e.toString());
    }
    return null;
  }

  Future<UserProfile?> updateUserProfile(
      var token,
      var fullName,
      var mobile,
      var email,
      var dob,
      var address,
      File? adharImg,
      File? userPhoto) async {
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse(AppConfig.baseURL + apiUpdateUserProfile));
      request.fields.addAll({
        'name': fullName,
        'email': email,
        'address': address,
        'dob': dob,
      });

      request.headers.addAll({"Authorization": token});
      debugPrint("addharImg ${adharImg?.path}");
      debugPrint("userPhoto ${userPhoto?.path}");
      debugPrint("request ${request.fields.toString()}");
      debugPrint("header ${request.headers.toString()}");
      if (adharImg != null) {
        request.files.add(
            await http.MultipartFile.fromPath('aadhaar_image', adharImg.path));
      }

      if (userPhoto != null) {
        request.files.add(
            await http.MultipartFile.fromPath('profile_image', userPhoto.path));
      }

      var response =
          await request.send().timeout(Duration(seconds: apiTimeOutSeconds));
      var responsed = await http.Response.fromStream(response);
      debugPrint("statusCode:${response.statusCode}");
      if (kDebugMode) {
        print(AppConfig.baseURL + apiUpdateUserProfile);
        final prettyString = const JsonEncoder.withIndent('  ')
            .convert(json.decode(responsed.body));
        log(prettyString);
      }
      return UserProfile.fromJson(jsonDecode(responsed.body));
    } catch (e) {
      log(e.toString());
      showErrorToast(e.toString());
    }
    return null;
  }

  Future<Login?> userLogOut(var token) async {
    try {
      var response = await apiRetry.retry(
        () => http.post(
          Uri.parse(AppConfig.baseURL + apiLogout),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            "Authorization": token
          },
        ).timeout(Duration(seconds: apiTimeOutSeconds)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );

      if (kDebugMode) {
        print(AppConfig.baseURL + apiLogout);
        final prettyString = const JsonEncoder.withIndent('  ')
            .convert(json.decode(response.body));
        log(prettyString);
      }
      debugPrint("statusCode=>${response.statusCode}");
      return Login.fromJson(jsonDecode(response.body));
    } catch (e) {
      log(e.toString());
      showErrorToast(e.toString());
      return null;
    }
  }

  Future<Transaction?> apiFetchTransactionList(
      var token, var startDate, var endDate) async {
    try {
      Map data = {'start_date': startDate, 'end_date': endDate};

      var response = await apiRetry.retry(
        () => http.post(
          Uri.parse(AppConfig.baseURL + apiGiftTransactions),
          body: data,
          headers: {'Accept': 'application/json', "Authorization": token},
        ).timeout(Duration(seconds: apiTimeOutSeconds)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );

      debugPrint("startDate$startDate");
      debugPrint("endDate$endDate");
      debugPrint("token$token");
      debugPrint(response.request.toString());
      final prettyString = const JsonEncoder.withIndent('  ')
          .convert(json.decode(response.body));
      log(prettyString);
      debugPrint("statusCode=>${response.statusCode}");
      return Transaction.fromJson(jsonDecode(response.body));
    } catch (e) {
      log(e.toString());
      showErrorToast(e.toString());
    }
    return null;
  }

  Future<Transaction?> apiFetchCashTransactionList(
      var token, var startDate, var endDate) async {
    try {
      Map data = {'start_date': startDate, 'end_date': endDate};
      var response = await apiRetry.retry(
        () => http.post(
          Uri.parse(AppConfig.baseURL + apiCashTransactions),
          body: data,
          headers: {'Accept': 'application/json', "Authorization": token},
        ).timeout(Duration(seconds: apiTimeOutSeconds)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );

      debugPrint("startDate$startDate");
      debugPrint("endDate$endDate");
      debugPrint("token$token");
      debugPrint(response.request.toString());
      final prettyString = const JsonEncoder.withIndent('  ')
          .convert(json.decode(response.body));
      log(prettyString);
      debugPrint("statusCode=>${response.statusCode}");
      return Transaction.fromJson(jsonDecode(response.body));
    } catch (e) {
      log(e.toString());
      showErrorToast(e.toString());
    }
    return null;
  }

  Future<Transaction?> apiFetchProductTransactionList(
      var token, var startDate, var endDate) async {
    try {
      Map data = {'start_date': startDate, 'end_date': endDate};
      var response = await apiRetry.retry(
        () => http.post(
          Uri.parse(AppConfig.baseURL + apiProductTransactions),
          body: data,
          headers: {'Accept': 'application/json', "Authorization": token},
        ).timeout(Duration(seconds: apiTimeOutSeconds)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );

      debugPrint("startDate$startDate");
      debugPrint("endDate$endDate");
      debugPrint("token$token");
      debugPrint(response.request.toString());
      final prettyString = const JsonEncoder.withIndent('  ')
          .convert(json.decode(response.body));
      log(prettyString);
      debugPrint("statusCode=>${response.statusCode}");
      return Transaction.fromJson(jsonDecode(response.body));
    } catch (e) {
      log(e.toString());
      showErrorToast(e.toString());
    }
    return null;
  }

  Future<Product?> apiFetchProductList(
      var token, var startDate, var endDate) async {
    try {
      Map data = {'start_date': startDate, 'end_date': endDate};
      var response = await apiRetry.retry(
        () => http.post(
          Uri.parse(AppConfig.baseURL + apiProducts),
          body: data,
          headers: {'Accept': 'application/json', "Authorization": token},
        ).timeout(Duration(seconds: apiTimeOutSeconds)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );

      debugPrint("startDate$startDate");
      debugPrint("endDate$endDate");
      debugPrint("token$token");
      debugPrint(response.request.toString());
      final prettyString = const JsonEncoder.withIndent('  ')
          .convert(json.decode(response.body));
      log(prettyString);
      debugPrint("statusCode=>${response.statusCode}");
      return Product.fromJson(jsonDecode(response.body));
    } catch (e) {
      log(e.toString());
      showErrorToast(e.toString());
    }
    return null;
  }
}

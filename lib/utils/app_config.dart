class AppConfig {
  static const String _baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://admin.maajasolpaints.com/api/',
  );
  
  static String get baseURL => _baseUrl;
  
  // API Endpoints
  static const String apiRegister = "register";
  static const String apiLogin = "login";
  static const String apiVerifyOTP = "verify-otp";
  static const String apiUserDetails = "profile";
  static const String apiResentOTP = "resend-otp";
  static const String apiUpdateUserProfile = "profile-update";
  static const String apiDashboard = "dashboard";
  static const String qrRedeem = "qr/redeem";
  static const String apiGift = "gifts";
  static const String apiRedemptionRequest = "redemption-request";
  static const String apiLogout = "logout";
  static const String apiTransactions = "transactions";
  static const String apiCashTransactions = "cash/transactions";
  static const String apiGiftTransactions = "gift/transactions";
  static const String apiProductTransactions = "product/transactions";
  static const String apiProducts = "products";
  
  // Security
  static const bool isProduction = bool.fromEnvironment('PRODUCTION', defaultValue: false);
  static const String appVersion = String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0');
}
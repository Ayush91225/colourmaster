
import 'package:flutter/material.dart';

Color hexToColor(String hex) {
  assert(RegExp(r'^#([0-9a-fA-F]{6})|([0-9a-fA-F]{8})$').hasMatch(hex),
  'hex color must be #rrggbb or #rrggbbaa');

  return Color(
    int.parse(hex.substring(1), radix: 16) +
        (hex.length == 7 ? 0xff000000 : 0x00000000),
  );
}

class ColorConstants {
  static Color bodyBackgroundColor = const Color(0xFFfcd79f);
  static Color blackColor = const Color(0xFF000000);
  static Color whiteColor = const Color(0xFFffffff);
  static Color errorTextColor = const Color(0xFFf64336);
  static Color hintTextColor = const Color(0xFF737373);
  static Color editTextBgColor = const Color(0XFFe9e9f2);
  static Color editTextBgWhiteColor = const Color(0xFFffffff);
  static Color editTextBorderColor = const Color(0xFFCCCCCC);
  static Color colorGreen = const Color(0xFF41B044);
  static Color dividerColor = const Color(0xFF808080);
  static Color textFieldBorderColor = const Color(0xFF9e9e9e);
  static Color textViewLabeledColor = const Color(0xFF212121);
  static Color  segmentedControlBGColor= const Color(0xFFE0E0E0);
  static Color  onBoardingTitleColor= const Color(0xFF444444);
  static Color  grayButtonBgColor= const Color(0xFF9E9E9E);
  static Color  loadingBackgroundColor= const Color(0xFF9E9E9E);
  static Color  lightGrayColor= const Color(0xFF9e9e9e);
  static Color  warningColor= const Color(0xfff8e043);
  static Color  bookingButtonColor= const Color(0xff212121);
  static Color  lightWhiteColor= const Color(0xffF5F5F5);
  static Color  lightPinkColor= const Color(0xffF7BBC5);
  static Color  grayBoxColor= const Color(0xffE0E0E0);
  static Color  blackButtonColor= const Color(0xff212121);
  static Color  viewButtonBackgroundColor= const Color(0xffE0E0E0);
  static Color  secondaryBGColor= const Color(0xffF2F2F4);
  static Color  pointLabelColor= const Color(0xff333333);
  static Color  disabledBGColor= const Color(0xd7a19e9e);
  static Color selectedTabLabeledColor = const Color(0XFF34B6E1);
  static Color inActiveColor = const Color(0XFFD3D3D3);
  static Color bookIconColor = const Color(0XFF434343);
  static Color giftCardBGColor = const Color(0XFF96E9DA);
  static Color tagLabeledTextColor = const Color(0XFFBDBDBD);
  static Color statusBarColor = const Color(0xFFfcd79f);
  static Color grayTextViewLabelColor = const Color(0XFF808080);
  static Color primaryButtonColor = const Color(0XFFF23384);
  static Color headerBgColor = const Color(0XFFFCE4A7);
  static Color headerDividerColor = const Color(0XFFFF9C55);
  static Color headerEmailColor = const Color(0XFF6C6C6C);
  static Color sideMenuTitleColor = const Color(0XFF252525);
  static Color sideMenuDividerColor = const Color(0XFCE4A7B5);
  static Color bottomBarItemUnSelectedColor = const Color(0XFC555555);
  static Color transactionDateColor = const Color(0XFF808080);
  static Color transactionAmountColor = const Color(0XFF252525);

  static const MaterialColor primaryColor = MaterialColor(
    0XFFF23384,
    <int, Color>{
      50:  Color(0XFFF23384),
      100: Color(0XFFF23384),
      200: Color(0XFFF23384),
      300: Color(0XFFF23384),
      400: Color(0XFFF23384),
      500: Color(0XFFF23384),
      600: Color(0XFFF23384),
      700: Color(0XFFF23384),
      800: Color(0XFFF23384),
      900: Color(0XFFF23384),
    },
  );
}

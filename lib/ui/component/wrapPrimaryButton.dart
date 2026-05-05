import 'package:flutter/material.dart';

import '../../utils/style/color_constants.dart';

class WrapPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? fontSize;
  final double? buttonHeight;
  final bool? usePadding;
  const WrapPrimaryButton(
      {super.key,
      this.fontSize,
      this.buttonHeight,
      required this.text,
      required this.onPressed,
      this.usePadding});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: buttonHeight ?? 30,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ButtonStyle(
              padding: WidgetStateProperty.all(
                EdgeInsets.only(
                    left: usePadding != null ? 50 : 10,
                    right: usePadding != null ? 50 : 10),
              ),
              elevation: WidgetStateProperty.all(0),
              backgroundColor: WidgetStateProperty.all(
                ColorConstants.primaryColor,
              ),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ))),
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize ?? 16.0,
              fontWeight: FontWeight.w600,
              fontFamily: 'Raleway',
              color: ColorConstants.whiteColor,
            ),
          ),
        ));
  }
}

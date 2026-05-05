import 'package:flutter/material.dart';

import '../../utils/style/color_constants.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? fontSize;
  final double? buttonHeight;
  const PrimaryButton(
      {super.key,
      this.fontSize,
      required this.text,
      required this.onPressed,
      this.buttonHeight});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: buttonHeight ?? 40,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ButtonStyle(
              elevation: MaterialStateProperty.all(0),
              backgroundColor: MaterialStateProperty.all(
                ColorConstants.primaryButtonColor,
              ),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ))),
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize ?? 18.0,
              fontWeight: FontWeight.w600,
              fontFamily: 'Raleway',
              color: ColorConstants.whiteColor,
            ),
          ),
        ));
  }
}

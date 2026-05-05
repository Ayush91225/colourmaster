
import 'package:flutter/material.dart';
import '../../utils/style/color_constants.dart';

class GrayButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const GrayButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 40,
        width: double.infinity,
        child:ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
          backgroundColor:
          MaterialStateProperty.all(
            ColorConstants.grayButtonBgColor,
          ),
          shape: MaterialStateProperty.all<
              RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(10),
              ))),
      child:Text(
        text,
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w500,
          fontFamily: 'Poppins',
          color: ColorConstants.whiteColor,
        ),
      ),
    ));
  }

}
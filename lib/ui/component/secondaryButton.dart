
import 'package:flutter/material.dart';
import '../../utils/style/color_constants.dart';

class SecondaryButton extends StatelessWidget {
  final String text;
  final double? fontSize;
  final VoidCallback onPressed;
  const SecondaryButton({super.key,this.fontSize,required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 40,
        width: double.infinity,
        child:ElevatedButton(
          onPressed: onPressed,
          style: ButtonStyle(
            elevation:MaterialStateProperty.all(0),
              backgroundColor:
              MaterialStateProperty.all(
                ColorConstants.secondaryBGColor,
              ),
              shape: MaterialStateProperty.all<
                  RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(5),
                  ))),
          child:Text(
            text,
            style: TextStyle(
              fontSize:fontSize?? 16.0,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
              color: ColorConstants.bookingButtonColor,
            ),
          ),
        ));
  }

}
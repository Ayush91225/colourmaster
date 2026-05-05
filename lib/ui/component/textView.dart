import 'package:flutter/material.dart';

class TextView extends StatelessWidget {
  final String data;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final TextDecoration? decoration;
  final TextAlign? textAlign;
  final String? fontFamily;
  const TextView({super.key, required this.data, required this.textColor, required this.fontSize,required this.fontWeight,this.decoration,this.textAlign,this.fontFamily});

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      textAlign:textAlign,
      style:TextStyle(color:textColor,fontWeight:fontWeight,fontSize:fontSize,fontFamily: "Poppins",decoration:decoration,
        decorationColor: textColor,
        decorationThickness: 2,),
    );
  }
}
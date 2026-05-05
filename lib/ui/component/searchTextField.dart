import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/CardNumberFormatter.dart';
import '../../utils/style/color_constants.dart';

class CustomSearchTextField extends StatefulWidget {
  final String hint;
  final TextEditingController controller;
  final Color hintColor;
  final Color borderColor;
  final Color errorColor;
  final TextInputType? inputType;
  final bool obscureText;
  final bool showSuffixIcon;
  final Function? validator;
  final Function onChanged;
  final Function? onTap;
  final Function? submitted;
  final Function? searchIconSubmitted;
  final Widget? prefixIcon;
  final readOnly;
  final maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final bool showBorder;
  final Iterable<String>? autofillHints;
  const CustomSearchTextField({
        super.key,
        required this.hint,
        required this.controller,
        required this.onChanged,
        required this.hintColor,
        required this.borderColor,
        required this.errorColor,
        this.inputType,
        this.obscureText = false,
         this.validator,
         this.onTap,
        this.prefixIcon,
        this.readOnly,
        this.maxLength,
        this.inputFormatters,
        this.showSuffixIcon= true,
        this.autofocus= false,
        this.focusNode,
        required this.textCapitalization,
        this.showBorder=true,
        this.autofillHints,
        this.submitted,
        this.searchIconSubmitted
      });

  @override
  _CustomSearchTextFieldState createState() => _CustomSearchTextFieldState();
}

class _CustomSearchTextFieldState extends State<CustomSearchTextField> {
   Color? currentColor;
   bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    currentColor = widget.borderColor;
  }

   // Toggles the password show status
   void _toggleVisibility() {
     setState(() {
       _showPassword = !_showPassword;
     });
   }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofillHints:widget.autofillHints,
      textCapitalization:widget.textCapitalization,
      focusNode:widget.focusNode,
      autovalidateMode:AutovalidateMode.onUserInteraction,
      obscureText:widget.obscureText?!_showPassword:widget.obscureText,
      keyboardType:widget.inputType,
      autocorrect: true,
      onFieldSubmitted: (value) {
        return widget.submitted!(value);
      },
      inputFormatters:widget.inputFormatters,
      autofocus:widget.autofocus,
      onTap:(){
        return widget.onTap!();
      },
      readOnly:widget.readOnly,
      maxLength:widget.maxLength,
      style: TextStyle(
          fontSize: 16,
          color:ColorConstants.blackColor,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400),
      controller: widget.controller,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        suffixIcon: IconButton(
          onPressed: () {
            return widget.searchIconSubmitted!();
          },
          icon: const Icon(Icons.search),
        ),
        counterText: "",
        errorMaxLines: 4,
        hintStyle:TextStyle(
          fontSize: 16,
          color: widget.hintColor,
          fontFamily: "Poppins",
          fontWeight: FontWeight.w400,
        ),
        errorBorder: null,
        focusedBorder:OutlineInputBorder(
          borderRadius:BorderRadius.circular(10),
          borderSide:BorderSide(
            width:2,
            strokeAlign:1.2 ,
            color: widget.showBorder? ColorConstants.primaryColor:Colors.transparent,
            style: BorderStyle.solid,
          ),
        ),
        enabledBorder:null ,
        errorStyle:TextStyle(color:ColorConstants.errorTextColor,
          fontSize: 12,
          fontFamily: "Poppins",
          fontWeight: FontWeight.w400,),
        border:widget.showBorder?OutlineInputBorder(
          borderRadius:BorderRadius.circular(10),
          borderSide:BorderSide(
            width:0.7,
            strokeAlign:1.2 ,
            color: ColorConstants.colorGreen,
            style: BorderStyle.solid,
          ),
        ):InputBorder.none,
        filled: true,
        contentPadding:const EdgeInsets.all(12),
        fillColor:ColorConstants.editTextBgWhiteColor,
        hintText: widget.hint,
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../utils/CardNumberFormatter.dart';
import '../../utils/style/color_constants.dart';

class CustomTextField extends StatefulWidget {
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
  final Function? onFieldSubmitted;
  final Widget? prefixIcon;
  final readOnly;
  final maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final bool showBorder;
  final Iterable<String>? autofillHints;
  final bool canEdit;
  final Function? onFieldEdit;
  final bool lookDisableField;
  final bool isDatePicker;
  final bool isFilePicker;
  final Color? fillColor;
  const CustomTextField({
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
        this.onFieldSubmitted,
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
        this.canEdit=false,
        this.onFieldEdit,
        this.lookDisableField=false,
        this.isDatePicker=false,
        this.isFilePicker=false,
        this.fillColor
      });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
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
      enableInteractiveSelection: !widget.lookDisableField,
      onFieldSubmitted:(value){
        return widget.onFieldSubmitted!(value);
      },
      autofillHints:widget.autofillHints,
      textCapitalization:widget.textCapitalization,
      focusNode:widget.focusNode,
      autovalidateMode:AutovalidateMode.onUserInteraction,
      obscureText:widget.obscureText?!_showPassword:widget.obscureText,
      keyboardType:widget.inputType,
      autocorrect: true,
      validator: (value) {
        return widget.validator!=null?widget.validator!(value):null;
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
          color:widget.lookDisableField?ColorConstants.hintTextColor:ColorConstants.blackColor,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400),
      controller: widget.controller,
      decoration: InputDecoration(
        counterText: "",
        errorMaxLines: 4,
        suffixIcon:widget.obscureText?GestureDetector(
          onTap: () {
            _toggleVisibility();
          },
          child: Icon(
            _showPassword
                ? Icons.visibility
                : Icons.visibility_off,
            color: ColorConstants.blackColor,
          ),
        ):widget.showSuffixIcon?widget.controller.text.isNotEmpty
            ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              widget.controller.clear();
            })
            : null:widget.canEdit? IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              return widget.onFieldEdit!();
            })
            :widget.isDatePicker?Padding(padding:EdgeInsets.all(10),child:SvgPicture.asset(height:20,width:20,'assets/svg/calender_icon.svg'))
            :widget.isFilePicker?Padding(padding:EdgeInsets.all(10),child:SvgPicture.asset(height:20,width:20,'assets/svg/file_upload_icon.svg')):null,
        hintStyle:TextStyle(
          fontSize: 16,
          color: widget.hintColor,
          fontFamily: "Poppins",
          fontWeight: FontWeight.w400,
        ),
        errorBorder: null,
        focusedBorder:OutlineInputBorder(
          borderRadius:BorderRadius.circular(5),
          borderSide:BorderSide(
            width:2,
            strokeAlign:1.2 ,
            color:ColorConstants.editTextBorderColor,
            style: BorderStyle.solid,
          ),
        ),
        enabledBorder:widget.showBorder?OutlineInputBorder(
          borderRadius:BorderRadius.circular(5),
          borderSide:BorderSide(
            width:0.7,
            strokeAlign:1.2 ,
            color: widget.lookDisableField?const Color(0xffe4e7ea):ColorConstants.editTextBorderColor,
            style: BorderStyle.solid,
          ),
        ):InputBorder.none,
        errorStyle:TextStyle(color:ColorConstants.errorTextColor,
          fontSize: 12,
          fontFamily: "Poppins",
          fontWeight: FontWeight.w400,),
        border:widget.showBorder?OutlineInputBorder(
          borderRadius:BorderRadius.circular(5),
          borderSide:BorderSide(
            width:0.7,
            strokeAlign:1.2 ,
            color: ColorConstants.colorGreen,
            style: BorderStyle.solid,
          ),
        ):InputBorder.none,
        filled: true,
        contentPadding:const EdgeInsets.all(12),
        fillColor:widget.lookDisableField?const Color(0xffe4e7ea):ColorConstants.editTextBgWhiteColor,
        hintText: widget.hint,
      ),
    );
  }
}
import 'package:flutter/material.dart';

class CheckBoxFormFieldWithErrorMessage extends FormField<bool> {

  final String labelText;
  final bool isChecked;
  String error;
  final void Function(bool?) onChanged;

  CheckBoxFormFieldWithErrorMessage({
    Key? key,
    required this.labelText,
    required this.isChecked,
    required this.onChanged,
    required FormFieldValidator<bool>? validator,
    required this.error,
  }) : super(
    key: key,
    initialValue: isChecked,
    validator: validator,
    builder: (FormFieldState<bool> state) {
      return Column(
        children: [

        ],
      );
    },
  );
}
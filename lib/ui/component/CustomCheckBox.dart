import 'package:colourmaster/ui/component/textView.dart';
import 'package:flutter/material.dart';

import '../../utils/style/color_constants.dart';
import '../../utils/style/text_view_style.dart';

class CustomCheckBox extends StatefulWidget {
  final int value;
  final void Function(int) onChanged;
  final double? checkBoxSize;
  final String? labelText;
  const CustomCheckBox(
      {super.key,
      required this.value,
      required this.onChanged,
      this.checkBoxSize,
      this.labelText});

  @override
  _CustomCheckBoxState createState() => _CustomCheckBoxState();
}

class _CustomCheckBoxState extends State<CustomCheckBox> {
  @override
  Widget build(BuildContext context) {
    bool selected = widget.value == 1 ? true : false;
    return InkWell(
        onTap: () => widget.onChanged(widget.value),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? ColorConstants.primaryColor : Colors.black),
              child: Icon(
                selected ? Icons.check : Icons.circle,
                size: widget.checkBoxSize,
                color: selected ? ColorConstants.whiteColor : Colors.white,
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            Flexible(
              child: TextView(
                  data: '${widget.labelText}',
                  textColor: ColorConstants.textViewLabeledColor,
                  fontSize: textLabelFontSize_12,
                  fontWeight: FontWeight.w400),
            )
          ],
        ));
  }
}

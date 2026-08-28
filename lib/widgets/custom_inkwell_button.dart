import 'package:flutter/material.dart';

import '../constants.dart';
import '../widgets/custom_font.dart';

class CustomInkwellButton extends StatelessWidget {
  final VoidCallback onTap;
  final double height;
  final double width;
  final double fontSize;
  final String buttonName;
  final Icon icon;
  final FontWeight fontWeight;
  final Color bgColor;
  final Color fontColor;

  CustomInkwellButton({
    super.key,
    required this.onTap,
    required this.height,
    required this.width,
    this.buttonName = "",
    this.bgColor = FB_DARK_PRIMARY,
    this.fontColor = Colors.white,
    this.fontSize = 14,
    this.icon = const Icon(null),
    this.fontWeight = FontWeight.normal,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      elevation: 5,
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        splashColor: FB_SECONDARY,

        child: Container(
          height: height,
          width: width,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),

          child: Center(
            child: buttonName.isEmpty
                ? icon
                : CustomFont(
                    text: buttonName,
                    fontSize: fontSize,
                    color: fontColor,
                  ),
          ),
        ),
      ),
    );
  }
}

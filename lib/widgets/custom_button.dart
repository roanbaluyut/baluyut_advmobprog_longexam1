import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/custom_font.dart';
import '../constants.dart';

class CustomButton extends StatelessWidget {
  final String buttonType;
  final String buttonName;
  final Color fontColor;
  final Color outlineColor;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    this.buttonType = 'elevated',
    required this.buttonName,
    this.fontColor = FB_TEXT_COLOR_WHITE,
    required this.onPressed,
    this.outlineColor = FB_DARK_PRIMARY,
  });

  @override
  Widget build(BuildContext context) {
    final type = buttonType.toLowerCase();

    if (type == 'outlined') {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil().setWidth(30),
            vertical: ScreenUtil().setHeight(10),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          side: BorderSide(color: outlineColor),
        ),
        child: CustomFont(
          text: buttonName,
          fontSize: ScreenUtil().setSp(12),
          color: fontColor,
        ),
      );
    } else if (type == 'text') {
      return TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil().setWidth(30),
            vertical: ScreenUtil().setHeight(10),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: CustomFont(
          text: buttonName,
          fontSize: ScreenUtil().setSp(12),
          color: fontColor,
        ),
      );
    } else {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: FB_PRIMARY,
          padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil().setWidth(30),
            vertical: ScreenUtil().setHeight(10),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: CustomFont(
          text: buttonName,
          fontSize: ScreenUtil().setSp(12),
          color: fontColor,
        ),
      );
    }
  }
}

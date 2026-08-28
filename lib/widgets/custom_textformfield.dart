// custom_text_form_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants.dart';

class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.validator,
    this.onSaved,
    this.hintText = "",
    this.isObscure = false,
    this.fontSize = 14,
    this.fontColor = Colors.black,
    this.hintTextSize = 12,
    this.fillColor = Colors.black12,
    this.height = 12,
    this.width = 12,
    this.keyboardType = TextInputType.text,
    this.maxLength = 200,
  });

  final TextEditingController controller;
  final String? Function(String?) validator;
  final void Function(String?)? onSaved;
  final String hintText;
  final bool isObscure;
  final double fontSize;
  final Color fontColor;
  final double hintTextSize;
  final Color fillColor;
  final double height;
  final double width;
  final TextInputType keyboardType;
  final int maxLength;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isObscure;
  }

  void _toggleObscure() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      onSaved: widget.onSaved,
      obscureText: _obscureText,
      keyboardType: widget.keyboardType,
      inputFormatters: [LengthLimitingTextInputFormatter(widget.maxLength)],
      style: TextStyle(fontSize: widget.fontSize.sp, color: widget.fontColor),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(
          widget.width.w,
          widget.height.h,
          widget.width.w,
          widget.height.h,
        ),
        hintText: widget.hintText,
        hintStyle: TextStyle(
          fontSize: widget.hintTextSize.sp,
          color: Colors.black38,
        ),
        filled: true,
        fillColor: widget.fillColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.sp),
          borderSide: const BorderSide(color: FB_DARK_PRIMARY, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.sp),
          borderSide: const BorderSide(color: FB_LIGHT_PRIMARY, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.sp),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.sp),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        errorStyle: TextStyle(fontSize: 11.sp, fontFamily: 'Frutiger'),
        suffixIcon: widget.isObscure
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.black54,
                ),
                onPressed: _toggleObscure,
              )
            : null,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../constants.dart';

class CustomDialogs {
  static void showSuccessDialog(
    BuildContext context,
    String content, {
    VoidCallback? onPressed,
  }) {
    AlertDialog alertDialog = AlertDialog(
      title: const Text('Success'),
      content: Text(content),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          onPressed: onPressed ?? () => Navigator.of(context).pop(),
          child: const Text("Okay"),
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) => alertDialog,
    );
  }

  static void showErrorDialog(
    BuildContext context,
    String content, {
    VoidCallback? onPressed,
  }) {
    AlertDialog alertDialog = AlertDialog(
      title: const Text('Error'),
      content: Text(content),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: FB_DARK_PRIMARY,
            foregroundColor: Colors.white,
          ),
          onPressed: onPressed ?? () => Navigator.of(context).pop(),
          child: const Text("Okay"),
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) => alertDialog,
    );
  }
}

import 'package:flutter/material.dart';

class DialogUtils {
  static Future<dynamic> buildShowDialog(
      BuildContext context, {
        required String title,
        required String content,
        required Color titleColor,
      }) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(color: titleColor),
          ),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
import 'package:flutter/material.dart';

class AlertTools {
  static void errorSnackbar(BuildContext context, String message) async =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text.rich(TextSpan(children: [
            const TextSpan(
                text: 'An error has ocurred\n',
                style: TextStyle(color: Colors.red)),
            TextSpan(text: message)
          ]))));

  static void infoSnackbar(BuildContext context, String message) async =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text.rich(TextSpan(children: [
            const TextSpan(
                text: 'Information\n', style: TextStyle(color: Colors.blue)),
            TextSpan(text: message)
          ]))));
}

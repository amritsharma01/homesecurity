import 'package:flutter/material.dart';

// ignore: must_be_immutable
class AlertDialogBox extends StatelessWidget {
  List<Widget>? actions;
  final String alertText;
  AlertDialogBox({super.key, required this.alertText, this.actions});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      content: Text(
        alertText,
        style: TextStyle(
            color: Colors.grey[800], fontSize: 15, fontWeight: FontWeight.w500),
      ),
      actions: actions,
    );
  }
}

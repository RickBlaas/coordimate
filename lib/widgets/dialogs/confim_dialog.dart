import 'package:flutter/material.dart';

class ConfirmAlertDialog extends StatelessWidget {
  final String title;
  final String contentText;
  final String cancelText;
  final String confirmTextBtn;
  final Color confirmColorBtn;

  const ConfirmAlertDialog({
    super.key,
    required this.title,
    required this.contentText,
    required this.confirmTextBtn,
    required this.confirmColorBtn,    
    this.cancelText = 'Cancel',
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(contentText),
      actions: [
        // Cancel button
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelText),
        ),
        // Confirm button
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            confirmTextBtn, 
            style: TextStyle(color: confirmColorBtn)
          ),
        ),
      ],
    );
  }
}
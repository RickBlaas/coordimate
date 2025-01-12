import 'package:flutter/material.dart';

class InputAlertDialog extends StatefulWidget {
  final TextEditingController controller;
  final String title;
  final String contentText;
  final String cancelText;
  final String confirmTextBtn;
  final Color confirmColorBtn;
  
  const InputAlertDialog({
    super.key,
    required this.controller,
    required this.title,
    required this.contentText,
    required this.confirmTextBtn,
    required this.confirmColorBtn,   
    this.cancelText = 'Cancel',
  });

  @override
  State<InputAlertDialog> createState() => _InputAlertDialogState();
}

class _InputAlertDialogState extends State<InputAlertDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: widget.controller,
        decoration:  InputDecoration(
          labelText: widget.contentText,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
      ),
      actions: [
        // Cancel button
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(widget.cancelText),
        ),
        // Confirm button
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            widget.confirmTextBtn, 
            style: TextStyle(color: widget.confirmColorBtn)
          ),
        ),
      ],
    );
  }
}
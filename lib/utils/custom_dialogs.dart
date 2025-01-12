import 'package:flutter/material.dart';
import '../widgets/dialogs/confim_dialog.dart';  
import '../widgets/dialogs/input_dialog.dart';  

class CustomDialogs {
  // Add member dialog
  static Future<bool?> addMember(BuildContext context, TextEditingController controller) {
    return showDialog<bool>(
      context: context,
      builder: (context) => InputAlertDialog(
        controller: controller, 
        title: 'Add Member', 
        contentText: 'User ID', 
        confirmTextBtn: 'Add', 
        confirmColorBtn: Colors.blue,
      )
    );
  }

  // Remove member dialog
  static Future<bool?> removeMember(BuildContext context, String memberName) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmAlertDialog(
        title: 'Remove Member', 
        contentText: 'Remove $memberName from this team?', 
        confirmTextBtn: 'Remove', 
        confirmColorBtn: Colors.red,
      )
    );
  }

  // Delete team dialog
  static Future<bool?> deleteTeam(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => const ConfirmAlertDialog(
        title: 'Delete Team', 
        contentText: 'Are you sure you want to delete this team?', 
        confirmTextBtn: 'Delete', 
        confirmColorBtn: Colors.red,
      )
    );
  }

  // Leave team dialog
  static Future<bool?> leaveTeam(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => const ConfirmAlertDialog(
        title: 'Leave Team', 
        contentText: 'Are you sure you want to leave this team?', 
        confirmTextBtn: 'Leave', 
        confirmColorBtn: Colors.red,
      )
    );
  }
}
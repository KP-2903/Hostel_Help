import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../student/student_dashboard.dart'; // Corrected import
import '../warden/warden_dashboard.dart'; // Corrected import

class ChangePasswordScreen extends StatefulWidget {
  final User user;

  ChangePasswordScreen({required this.user});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController newPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = false;

  Future<void> changePassword() async {
    setState(() => isLoading = true);
    String newPassword = newPasswordController.text.trim();
    String sapId = widget.user.email!.split('@')[0]; // Extract SAP ID from email

    try {
      await widget.user.updatePassword(newPassword);

      // Update Firestore to mark password as changed
      await _firestore.collection('users').doc(sapId).update({
        "passwordChanged": true,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password changed successfully!")),
      );

      // Redirect based on SAP ID (warden or student)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => sapId == "000000" ? WardenDashboard() : StudentDashboard(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Change Password")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "New Password"),
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: changePassword,
              child: Text("Update Password"),
            ),
          ],
        ),
      ),
    );
  }
}

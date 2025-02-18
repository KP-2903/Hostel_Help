import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'change_password_screen.dart'; // First-time password change screen
import '../student/student_dashboard.dart'; // Corrected import
import '../warden/warden_dashboard.dart'; // Corrected import

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController sapIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = false;

  Future<void> login() async {
    setState(() => isLoading = true);

    String sapId = sapIdController.text.trim();
    String password = passwordController.text.trim();
    String email = "$sapId@sap.edu"; // SAP ID formatted as email

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch user details from Firestore
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(sapId).get();
      bool passwordChanged = userDoc.exists && userDoc['passwordChanged'] == true;
      bool isWarden = sapId == "000000"; // Warden check

      if (!passwordChanged && password == "hostel@123") {
        // First-time login, force password change
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ChangePasswordScreen(user: userCredential.user!)),
        );
      } else {
        // Redirect based on user type
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => isWarden ? WardenDashboard() : StudentDashboard(),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: ${e.toString()}")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: sapIdController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "SAP ID"),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "Password"),
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: login,
              child: Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}

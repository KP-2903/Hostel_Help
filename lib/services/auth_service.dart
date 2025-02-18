import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Login Function
  Future<String?> login(String sapId, String password) async {
    try {
      String email = "$sapId@college.edu"; // Construct email
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      // Check if first-time login
      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(sapId).get();
      bool firstLogin = userDoc.exists ? userDoc['passwordChanged'] == false : false;

      return firstLogin ? "CHANGE_PASSWORD" : "SUCCESS";
    } catch (e) {
      return e.toString();
    }
  }

  // Change Password
  Future<bool> changePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
      String uid = _auth.currentUser!.uid;
      await _firestore.collection('users').doc(uid).update({
        "passwordChanged": true,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}

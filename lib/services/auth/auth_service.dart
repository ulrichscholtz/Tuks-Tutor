import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // Instance of Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Sign In
  Future<UserCredential> signInWithEmailPassword(String email, password) async {
    try {
      // Sign in user
      UserCredential userCredential = 
        await _auth.signInWithEmailAndPassword(
          email: email, 
          password: password
        );
      
      // Save user info in a seperate doc if user does not exist
      _firestore.collection("Users").doc(userCredential.user!.uid).set(
        {
          'uid': userCredential.user!.uid,
          'email': email,
        }
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }
  // Sign Up
  Future<UserCredential> signUpWithEmailPassword(String email, password) async {
    try {
      // Create User
      UserCredential userCredential = 
        await _auth.createUserWithEmailAndPassword(
          email: email, 
          password: password
        );
      
      // Save user info in a seperate doc
      _firestore.collection("Users").doc(userCredential.user!.uid).set(
        {
          'uid': userCredential.user!.uid,
          'email': email,
        }
      );

      // Errors
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
  
}
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //check if username exists
  Future<int> usernameExists(String username) async {
    try {
      final result = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();
      if (result.docs.isEmpty == true) {
        return 0;
      } else {
        return 1;
      }
    } catch (e) {
      return 2;
    }
  }

  //check if email exists
  Future<int> emailExists(String email) async {
    try {
      final result = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      if (result.docs.isEmpty == true) {
        return 0;
      } else {
        return 1;
      }
    } catch (e) {
      return 2;
    }
  }

  Future<bool> isEmailVerified() async {
    User? user = _firebaseAuth.currentUser;
    return user!.emailVerified;
  }

  //check if email is a valid email
  Future<bool> isValidEmail(String email) async {
    const String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    final RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }

  //check if password is a valid password
  Future<bool> isValidPassword(String password) async {
    const String pattern = r'^(?=.*[0-9])(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$';
    final RegExp regex = RegExp(pattern);
    return regex.hasMatch(password);
  }

  Future<void> emailVerification() async {
    try {
      User? user = _firebaseAuth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An Error occurred',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 30),
        backgroundColor: const Color.fromRGBO(255, 63, 23, 1),
        colorText: Colors.white,
      );
    }
  }

  //register with email and password
  Future<Map<String, String>> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      String uid = userCredential.user!.uid;
      return {
        'status': 'success',
        'message': 'User registered successfully',
        'userId': uid
      };
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return {
          'status': 'error',
          'message': 'The password provided is too weak.'
        };
      } else if (e.code == 'email-already-in-use') {
        return {
          'status': 'error',
          'message': 'The account already exists for that email.'
        };
      }
      return {'status': 'error', 'message': 'An error occurred'};
    } catch (e) {
      return {'status': 'error', 'message': 'An error occurred'};
    }
  }

  //save user info
  Future<void> saveUserInfo(
      String uid, String email, String password, String name, String token) async {
    await _firestore.collection('users').doc(email).set({
      'email': email,
      'username': name,
      'motivationalQuoteReminders': false,
      'studyTipReminders': false,
      'academic_details': [],
      'profilePicURL': '',
      'uid': uid,
      'fcmToken': token,
    });
  }

  Future<Map<String, dynamic>?> getUserInfo(String email) async {
    try {
      final result = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      if (result.docs.isNotEmpty) {
        return result.docs.first.data();
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<bool> editUserInfo(
      String email, Map<String, dynamic> updatedData) async {
    try {
      final result = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (result.docs.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(result.docs.first.id)
            .update(updatedData);
        return true; // Update successful
      } else {
        print('User with the given email does not exist.');
        return false; // User not found
      }
    } catch (e) {
      print('Error updating user info: $e');
      return false; // Error occurred
    }
  }

  //sign in with email and password
  Future<Map<String, String>> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      return {
        'status': 'success',
        'message': 'User signed in successfully',
        'userId': user!.uid,
      };
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return {'status': 'error', 'message': 'No user found.'};
      } else if (e.code == 'wrong-password') {
        return {
          'status': 'error',
          'message': 'Wrong password provided for that user.'
        };
      } else {
        return {'status': 'error', 'message': 'An error occurred'};
      }
    } catch (e) {
      return {'status': 'error', 'message': 'An error occurred'};
    }
  }

  //sign out
  Future signOut() async {
    try {
      return await _firebaseAuth.signOut();
    } catch (e) {
      return null;
    }
  }
}

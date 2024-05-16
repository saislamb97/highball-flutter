import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<User?> createUserWithEmailAndPassword(
      String email,
      String password,
      String name, // Add parameter for name
      String bio, // Add parameter for bio
      String dob, // Add parameter for dob
      String country, // Add parameter for country
      ) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create a user profile
      if (cred != null && cred.user != null) {
        await cred.user!.updateDisplayName(name);

        // Store additional user information directly using email as document ID
        await _firestore.collection('user_profiles').doc(email).set({
          'name': name,
          'bio': bio,
          'dob': dob,
          'country': country,
        });

        print("User Profile Created Successfully");
      }
      return cred?.user;
    } catch (e) {
      log("Something went wrong");
    }
    return null;
  }

  Future<User?> loginUserWithEmailAndPassword(
      String email,
      String password,
      ) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } catch (e) {
      log("Something went wrong");
    }
    return null;
  }

  Future<void> signout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      log("Something went wrong");
    }
  }
  Future<void> updateUserProfile({
    required String email,
    required String name,
    required String bio,
    required String dob,
    required String country,
  }) async {
    try {
      // Update user profile data in Firestore
      await _firestore.collection('user_profiles').doc(email).set({
        'name': name,
        'bio': bio,
        'dob': dob,
        'country': country,
      });
    } catch (e) {
      log("Failed to update user profile: $e");
      throw Exception("Failed to update user profile");
    }
  }
}

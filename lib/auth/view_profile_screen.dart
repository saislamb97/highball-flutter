import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewProfileScreen extends StatelessWidget {
  const ViewProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final User? _user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("View Profile"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Name: ${_user?.displayName ?? 'N/A'}",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              "Email: ${_user?.email ?? 'N/A'}",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('user_profiles').doc(_user?.email).get(), // Fetch data from 'user_profiles' collection using email as document ID
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Text('User data not found');
                }
                final userData = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Bio: ${userData['bio'] ?? 'N/A'}",
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      "DoB: ${userData['dob'] ?? 'N/A'}",
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      "Country: ${userData['country'] ?? 'N/A'}",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:highball/auth/auth_service.dart';
import 'package:highball/widgets/button.dart';
import 'package:highball/widgets/textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _auth = AuthService();
  final _name = TextEditingController();
  final _bio = TextEditingController();
  final _dob = TextEditingController();
  final _country = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize text controllers with existing user data
    _name.text = ''; // Initialize with existing name
    _bio.text = ''; // Initialize with existing bio
    _dob.text = ''; // Initialize with existing DoB
    _country.text = ''; // Initialize with existing country
  }

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    _dob.dispose();
    _country.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CustomTextField(
              hint: "Enter Name",
              label: "Name",
              controller: _name,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              hint: "Enter Bio",
              label: "Bio",
              controller: _bio,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              hint: "Enter Date of Birth",
              label: "Date of Birth",
              controller: _dob,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              hint: "Enter Country",
              label: "Country",
              controller: _country,
            ),
            const SizedBox(height: 30),
            _isLoading
                ? const CircularProgressIndicator()
                : CustomButton(
              label: "Save",
              onPressed: _saveProfile,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _saveProfile() async {
    if (_name.text.isEmpty || _bio.text.isEmpty || _dob.text.isEmpty || _country.text.isEmpty) {
      _showError("Please fill all fields");
      return;
    }
    setState(() => _isLoading = true);
    try {
      // Get current user's email
      final currentUser = FirebaseAuth.instance.currentUser;
      final email = currentUser?.email;
      if (email != null) {
        // Call method to update profile in AuthService with email
        await _auth.updateUserProfile(
          email: email,
          name: _name.text,
          bio: _bio.text,
          dob: _dob.text,
          country: _country.text,
        );
        // Navigate back after successful update
        Navigator.pop(context);
      } else {
        throw Exception("Current user not found");
      }
    } catch (e) {
      print(e.toString());
      _showError("An error occurred while saving profile");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

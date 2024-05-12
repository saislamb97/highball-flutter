import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:highball/widgets/button.dart';
import 'package:highball/widgets/textfield.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _user = FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Profile"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextField(
              hint: "Update Name",
              label: "Name",
              controller: _nameController,
            ),
            const SizedBox(height: 10),
            CustomTextField(
              hint: "Update Email",
              label: "Email",
              controller: _emailController,
            ),
            const SizedBox(height: 10),
            CustomTextField(
              hint: "Update Password",
              label: "Password",
              isPassword: true,
              controller: _passwordController,
            ),
            const SizedBox(height: 20),
            CustomButton(
              label: "Update Profile",
              onPressed: _updateProfile,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateProfile() async {
    try {
      if (_nameController.text.isNotEmpty) {
        await _user?.updateDisplayName(_nameController.text);
      }
      if (_emailController.text.isNotEmpty) {
        await _user?.updateEmail(_emailController.text);
      }
      if (_passwordController.text.isNotEmpty) {
        await _user?.updatePassword(_passwordController.text);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Updated Successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating profile: $e")),
      );
    }
  }
}

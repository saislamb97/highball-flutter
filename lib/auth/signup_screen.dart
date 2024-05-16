import 'package:flutter/material.dart';
import 'package:highball/auth/auth_service.dart';
import 'package:highball/auth/login_screen.dart';
import 'package:highball/home_screen.dart';
import 'package:highball/widgets/button.dart';
import 'package:highball/widgets/textfield.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _auth = AuthService();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _bio = TextEditingController(); // Add controller for bio field
  final _dob = TextEditingController(); // Add controller for DoB field
  final _country = TextEditingController(); // Add controller for Country field
  bool _isLoading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _bio.dispose();
    _dob.dispose();
    _country.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const SizedBox(height: 100),
            const Text("Signup", style: TextStyle(fontSize: 40, fontWeight: FontWeight.w500)),
            const SizedBox(height: 50),
            CustomTextField(
              hint: "Enter Name",
              label: "Name",
              controller: _name,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              hint: "Enter Email",
              label: "Email",
              controller: _email,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              hint: "Enter Password",
              label: "Password",
              isPassword: true,
              controller: _password,
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
            _isLoading ? const CircularProgressIndicator() : CustomButton(
              label: "Signup",
              onPressed: _signup,
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account? "),
                InkWell(
                  onTap: () => goToLogin(context),
                  child: const Text("Login", style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  void goToLogin(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const LoginScreen()),
  );

  void goToHome(BuildContext context) => Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const HomeScreen()),
  );

  void _signup() async {
    if (_name.text.isEmpty ||
        _email.text.isEmpty ||
        _password.text.isEmpty ||
        _bio.text.isEmpty ||
        _dob.text.isEmpty ||
        _country.text.isEmpty) {
      _showError("Please fill all fields");
      return;
    }
    setState(() => _isLoading = true);
    try {
      final user = await _auth.createUserWithEmailAndPassword(
        _email.text,
        _password.text,
        _name.text,
        _bio.text,
        _dob.text,
        _country.text,
      );
      if (user != null) {
        print("User Created Successfully");
        goToHome(context);
      } else {
        _showError("Signup failed. Please try again.");
      }
    } catch (e) {
      print(e.toString());
      _showError("An error occurred during signup: ${e.toString()}");
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

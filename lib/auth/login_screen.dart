import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:highball/auth/auth_service.dart';
import 'package:highball/auth/signup_screen.dart';
import 'package:highball/home_screen.dart';
import 'package:highball/widgets/button.dart';
import 'package:highball/widgets/textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
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
            const Text("Login", style: TextStyle(fontSize: 40, fontWeight: FontWeight.w500)),
            const SizedBox(height: 50),
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
            const SizedBox(height: 30),
            _isLoading ? const CircularProgressIndicator() : CustomButton(
              label: "Login",
              onPressed: _login,
            ),
            const SizedBox(height: 5),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text("Don't have an account? "),
              InkWell(
                onTap: () => goToSignup(context),
                child: const Text("Signup", style: TextStyle(color: Colors.red)),
              ),
            ]),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  void goToSignup(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const SignupScreen()),
  );

  void goToHome(BuildContext context) => Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const HomeScreen()),
  );

  void _login() async {
    setState(() => _isLoading = true);
    try {
      final user = await _auth.loginUserWithEmailAndPassword(_email.text, _password.text);
      if (user != null) {
        log("User Logged In");
        goToHome(context);
      } else {
        _showError("Login failed. Please try again.");
      }
    } catch (e) {
      log(e.toString());
      _showError("An error occurred during login.");
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

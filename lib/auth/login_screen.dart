import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:highball/auth/auth_service.dart';
import 'package:highball/auth/signup_screen.dart';
import 'package:highball/home_screen.dart';
import 'package:highball/widgets/button.dart';
import 'package:highball/widgets/textfield.dart';
import 'package:highball/widgets/background_image_wrapper.dart';

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
    return BackgroundImageWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              const SizedBox(height: 300),
              const Text("Login",
                  style: TextStyle(fontSize: 40,
                      fontWeight: FontWeight.w500,
                    color: Colors.white,)),
              const SizedBox(height: 25),
              CustomTextField(
                hint: "Enter Email",
                label: "Email",
                controller: _email,
                textColor: Colors.white,
              ),
              const SizedBox(height: 30),
              CustomTextField(
                hint: "Enter Password",
                label: "Password",
                isPassword: true,
                controller: _password,
                textColor: Colors.white,
              ),
              const SizedBox(height: 30),
              _isLoading ? const CircularProgressIndicator() : CustomButton(
                label: "Login",
                onPressed: _login,
              ),
              const SizedBox(height: 5),
              SizedBox(
                width: 750.92,
                height: 750.92,
                child: ElevatedButton(
                  onPressed: () => goToSignup(context),
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                  ).copyWith(
                    backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFFFF7269)),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 250.0),
                      child: Text(
                        "Create Account",
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
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

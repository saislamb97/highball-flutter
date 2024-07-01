import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField(
      {super.key,
      required this.hint,
      required this.label,
      this.controller,
      this.textColor = Colors.white,
        this.hintColor = Colors.grey,
      this.isPassword = false});

  final String hint;
  final String label;
  final bool isPassword;
  final TextEditingController? controller;
  final Color textColor;
  final Color hintColor;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: isPassword,
      controller: controller,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
          hintText: hint,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          hintStyle: TextStyle(color: Colors.white), // Set hint text color here// Set text color here
          label: Text(label),
          labelStyle: TextStyle(color: Colors.white), // Set text color here
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Colors.grey, width: 1))),
    );
  }
}

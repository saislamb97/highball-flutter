import 'package:flutter/material.dart';

class BackgroundImageWrapper extends StatelessWidget {
  final Widget child;

  const BackgroundImageWrapper({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image
        Image.network(
          'https://firebasestorage.googleapis.com/v0/b/highball-109e9.appspot.com/o/backgrounds%2Fbg%20image.jpg?alt=media&token=808e40e3-7365-4d03-88fa-09a1086644d8', // Corrected URL
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        // Android element
        Positioned(
          left: -230.00,
          top: 250.00,
          child: Container(
            width: 900.00,
            height: 796.92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF272A32),
            ),
          ),
        ),
        // Child widget
        Positioned.fill(
          child: child,
        ),
      ],
    );
  }
}

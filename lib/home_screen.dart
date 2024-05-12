import 'package:flutter/material.dart';
import 'package:highball/auth/auth_service.dart';
import 'package:highball/auth/login_screen.dart';
import 'package:highball/auth/update_profile.dart'; // Make sure this import is correct
import 'package:highball/widgets/button.dart';
import 'package:highball/config/app_assets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService auth = AuthService();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: const Text('Delicious Dishes'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UpdateProfileScreen())),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(16),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildFoodCard(AppAssets.food1),
                  _buildFoodCard(AppAssets.food2),
                  _buildFoodCard(AppAssets.food3),
                  _buildFoodCard(AppAssets.food4),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: CustomButton(
                label: "Sign Out",
                onPressed: () async {
                  await auth.signout();
                  goToLogin(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodCard(String assetName) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Image.asset(
        assetName,
        fit: BoxFit.cover,
      ),
    );
  }

  void goToLogin(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      ModalRoute.withName('/login'),
    );
  }
}

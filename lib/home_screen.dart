import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:highball/auth/login_screen.dart';
import 'package:highball/auth/auth_service.dart';
import 'package:highball/auth/edit_profile_screen.dart';
import 'package:highball/auth/view_profile_screen.dart';
import 'package:highball/widgets/button.dart';
import 'package:highball/config/app_assets.dart';
import 'package:highball/auth/create_cake.dart';
import 'package:highball/auth/edit_cake_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';
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
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ViewProfileScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateCakeScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: CakeList(currentUserEmail: currentUserEmail),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: ElevatedButton(
              onPressed: () async {
                await auth.signout();
                goToLogin(context);
              },
              child: Text("Sign Out"),
            ),
          ),
        ],
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

class CakeList extends StatelessWidget {
  final String currentUserEmail;

  const CakeList({Key? key, required this.currentUserEmail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('cakes').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No cakes available'));
        }

        return GridView.builder(
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.5,
          ),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var cake = snapshot.data!.docs[index];
            return CakeTile(cake: cake, currentUserEmail: currentUserEmail);
          },
        );
      },
    );
  }
}

class CakeTile extends StatelessWidget {
  final QueryDocumentSnapshot cake;
  final String currentUserEmail;

  const CakeTile({Key? key, required this.cake, required this.currentUserEmail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Colors.deepOrange,
      child: Stack(
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CakeDetailsPage(cake: cake, currentUserEmail: currentUserEmail)),
              );
            },
            child: Center(
              child: Text(
                cake['name'],
                style: TextStyle(fontSize: 20, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          if (currentUserEmail == cake['creatorEmail'])
            DeleteCakeButton(cake: cake, currentUserEmail: currentUserEmail),
        ],
      ),
    );
  }
}


class CakeDetailsPage extends StatelessWidget {
  final QueryDocumentSnapshot cake;
  final String currentUserEmail;

  const CakeDetailsPage({Key? key, required this.cake, required this.currentUserEmail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('CurrentUserEmail: $currentUserEmail');
    print('CreatorEmail: ${cake['creatorEmail']}');

    return Scaffold(
      appBar: AppBar(
        title: Text('Cake Details'),
        actions: [
          if (currentUserEmail == cake['creatorEmail'])
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditCakeScreen(cake: cake)),
                );
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Text('Creator: ${cake['creatorEmail']}'),
            Text('Flavor: ${cake['flavor']}'),
            Text('Type: ${cake['type']}'),
            Text('Duration: ${cake['duration']}'),
          ],
        ),
      ),
    );
  }
}
class DeleteCakeButton extends StatelessWidget {
  final QueryDocumentSnapshot cake;
  final String currentUserEmail;

  const DeleteCakeButton({Key? key, required this.cake, required this.currentUserEmail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: CircleBorder(),
            backgroundColor: Colors.white,
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Delete Cake'),
                  content: Text('Are you sure you want to delete this cake?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        // Delete the cake from Firestore
                        try {
                          await cake.reference.delete();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Cake deleted successfully')),
                          );
                        } catch (error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to delete cake: $error')),
                          );
                        }
                        Navigator.pop(context);
                      },
                      child: Text('Delete'),
                    ),
                  ],
                );
              },
            );
          },
          child: Icon(
            Icons.delete,
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}

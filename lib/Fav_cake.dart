import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:highball/auth/login_screen.dart';
import 'package:highball/auth/auth_service.dart';
import 'package:highball/widgets/button.dart';
import 'package:highball/auth/edit_cake_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:highball/BottomNavigation.dart';
import 'package:highball/home_screen.dart';
import 'package:highball/auth/view_profile_screen.dart';
import 'package:highball/widgets/background_image_wrapper.dart'; // import your background image wrapper
import 'package:highball/CommunityPage.dart';

class FavoritesPage extends StatelessWidget {
  final String currentUserEmail;

  const FavoritesPage({Key? key, required this.currentUserEmail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackgroundImageWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: true,
          iconTheme: IconThemeData(
            color: Colors.red, // Change the color of the back button to red
          ),
          actions: [
            PopupMenuButton(
              icon: Icon(Icons.person),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'profile',
                  child: const Text('Profile'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ViewProfileScreen()),
                  ),
                ),
                PopupMenuItem(
                  value: 'logout',
                  child: const Text('Log Out'),
                  onTap: () async {
                    await AuthService().signout();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      ModalRoute.withName('/login'),
                    );
                  },
                ),
              ],
            ),

          ],
        ),
        body: CakeList(currentUserEmail: currentUserEmail),
        bottomNavigationBar: BottomNavigation(
          currentIndex: 1,
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
                break;
              case 1:
                break;
              case 2:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const CommunityPage()),
                );
                break;
            }
          },
        ),
      ),
    );
  }
}

class CakeList extends StatelessWidget {
  final String currentUserEmail;

  const CakeList({Key? key, required this.currentUserEmail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('user_profiles').doc(currentUserEmail).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final List<dynamic> favorites = snapshot.data?['favorites'] ?? [];

        if (favorites.isEmpty) {
          return Center(child: Text('No favorite cakes available'));
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('cakes').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final List<QueryDocumentSnapshot> favoriteCakes = snapshot.data?.docs
                .where((cake) => favorites.contains(cake.id))
                .toList() ?? [];

            if (favoriteCakes.isEmpty) {
              return Center(child: Text('No favorite cakes available'));
            }

            return GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 250), // Adjust padding as needed
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemCount: favoriteCakes.length,
              itemBuilder: (context, index) {
                var cake = favoriteCakes[index];
                return CakeTile(cake: cake, currentUserEmail: currentUserEmail);
              },
            );
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
      color: Colors.white,
      child: Stack(
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CakeDetailsPage(cake: cake, currentUserEmail: currentUserEmail)),
              );
            },
            child: Column(
              children: [
                Expanded(
                  child: cake['imageUrl'] != null
                      ? Image.network(
                    cake['imageUrl'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  )
                      : Center(child: Icon(Icons.cake, size: 50, color: Colors.white)),
                ),
                Container(
                  color: Colors.white.withOpacity(0.8),
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    cake['name'],
                    style: TextStyle(fontSize: 20, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CakeDetailsPage extends StatefulWidget {
  final DocumentSnapshot cake;
  final String currentUserEmail;

  const CakeDetailsPage({
    Key? key,
    required this.cake,
    required this.currentUserEmail,
  }) : super(key: key);

  @override
  _CakeDetailsPageState createState() => _CakeDetailsPageState();
}

class _CakeDetailsPageState extends State<CakeDetailsPage> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    checkFavoriteStatus();
  }

  void checkFavoriteStatus() {
    final userDoc =
    FirebaseFirestore.instance.collection('user_profiles').doc(widget.currentUserEmail);
    userDoc.get().then((doc) {
      if (doc.exists) {
        final List<dynamic>? favorites = doc.data()?['favorites'];
        if (favorites != null && favorites.contains(widget.cake.id)) {
          setState(() {
            isFavorite = true;
          });
        }
      }
    });
  }

  void toggleFavorite(BuildContext context) {
    final userDoc =
    FirebaseFirestore.instance.collection('user_profiles').doc(widget.currentUserEmail);
    userDoc.get().then((doc) {
      if (doc.exists) {
        final List<dynamic>? favorites = doc.data()?['favorites'];
        final List<String> updatedFavorites = favorites != null ? List.from(favorites) : [];
        if (updatedFavorites.contains(widget.cake.id)) {
          updatedFavorites.remove(widget.cake.id);
        } else {
          updatedFavorites.add(widget.cake.id);
        }
        userDoc.update({'favorites': updatedFavorites}).then((_) {
          setState(() {
            isFavorite = !isFavorite;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> ingredients = widget.cake['ingredients'] ?? []; // Retrieve ingredients list

    return BackgroundImageWrapper(
    child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(widget.cake['name']),
    actions: [
    IconButton(
    icon: Icon(
    isFavorite ? Icons.favorite : Icons.favorite_border,
    color: isFavorite ? Colors.red : null,
    ),
    onPressed: () => toggleFavorite(context),
    ),
    if (widget.currentUserEmail == widget.cake['creatorEmail'])
    IconButton(
    icon: Icon(Icons.edit),
    onPressed: () {
    },
    ),
    ],
    ),
    body: SingleChildScrollView(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Padding(
    padding: const EdgeInsets.only(top: 80.0), // Adjust top padding as needed
    child: Container(
    width: double.infinity,
    height: 200, // Adjust height as needed
    decoration: BoxDecoration(
    shape: BoxShape.circle,
    image: DecorationImage(
    image: NetworkImage(widget.cake['imageUrl'] ?? ''),
    fit: BoxFit.cover,
    ),
    ),
    ),
    ),
    SizedBox(height: 20), // Add SizedBox for spacing
    _buildInfoBox("Creator:", widget.cake['creatorEmail']),
    _buildInfoBox("Flavor:", widget.cake['flavor']),
    _buildInfoBox("Type:", widget.cake['type']),
    _buildInfoBox("Duration:", widget.cake['duration']),
    SizedBox(height: 16),
    Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20.0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Center(
    child: Text(
    'INGREDIENTS',
    style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    ),
    ),
    ),
    SizedBox(height: 8),
      Container(
        height: 200, // Set a fixed height for the ingredient list
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Color(0xFF272A32).withOpacity(0.8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListView.builder(
          itemCount: ingredients.length,
          itemBuilder: (context, index) {
            String ingredient = ingredients[index];
            return ListTile(
              title: Text(
                '- $ingredient',
                style: TextStyle(color: Colors.white),
              ),
            );
          },
        ),
      ),
    ],
    ),
    ),
    ],
    ),
    ),
    ),
    );
  }

  Widget _buildInfoBox(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: Color(0xFF272A32),
        borderRadius: BorderRadius.circular(10),
        border: Border(bottom: BorderSide(color: Colors.white24)), // Only bottom border
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:highball/auth/auth_service.dart';
import 'package:highball/auth/create_cake.dart';
import 'package:highball/auth/edit_cake_screen.dart';
import 'package:highball/auth/edit_profile_screen.dart';
import 'package:highball/auth/login_screen.dart';
import 'package:highball/auth/view_profile_screen.dart';
import 'package:highball/BottomNavigation.dart'; // import your BottomNavigation widget
import 'package:highball/Fav_cake.dart'; // import your BottomNavigation widget
import 'package:highball/widgets/background_image_wrapper.dart'; // import your background image wrapper
import 'package:highball/CommunityPage.dart';

class HomeScreen extends StatefulWidget  {
  const HomeScreen({super.key});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchQuery = '';
  String? userName;

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  void fetchUserName() async {
    final String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    final userDoc = FirebaseFirestore.instance.collection('user_profiles').doc(currentUserEmail);
    final docSnapshot = await userDoc.get();
    if (docSnapshot.exists) {
      setState(() {
        userName = docSnapshot.data()?['name'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    final AuthService auth = AuthService();

    return BackgroundImageWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Morning',
                style: TextStyle(
                  color: Color(0xFF686F82),
                  fontFamily: 'Kreon',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              SizedBox(width: 8),
              Text(
                userName ?? '',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          centerTitle: false,
          elevation: 0,
          automaticallyImplyLeading: false,
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
                    await auth.signout();
                    goToLogin(context);
                  },
          ),
        ],
      ),
      ],
    ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
              child: Container(
                height: 41,
                decoration: BoxDecoration(
                  color: Color(0xFF252830),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Find a cake',
                          hintStyle: TextStyle(
                            color: Color(0xFF686F82),
                            fontFamily: 'Kreon',
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.filter_list,
                      color: Colors.red,
                    ),
                    SizedBox(width: 10),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 140),
            Expanded(
              child: CakeList(
                currentUserEmail: currentUserEmail,
                searchQuery: searchQuery, // Pass the searchQuery parameter
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigation(
          currentIndex: 0, // set the current index to 0 or the appropriate index
          onTap: (index) {
            switch (index) {
              case 0:
              // Navigate to HomeScreen
                break;
              case 1:
              // Navigate to FavoritesPage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavoritesPage(currentUserEmail: currentUserEmail)),
                );
                break;
              case 2:
              // Navigate to CommunityPage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CommunityPage()),
                );
                break;
              case 3:
              // Navigate to CreateCakeScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateCakeScreen()),
                );
                break;
            }
          },
        ),
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
  final String searchQuery;

  const CakeList({Key? key, required this.currentUserEmail, required this.searchQuery,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('cakes')
          .where('name', isGreaterThanOrEqualTo: searchQuery.isEmpty ? null : searchQuery)
          .where('name', isLessThan: searchQuery.isEmpty ? null : searchQuery + 'z')
          .snapshots(),
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

        return SingleChildScrollView(
          child: GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.25,
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var cake = snapshot.data!.docs[index];
              return CakeTile(cake: cake, currentUserEmail: currentUserEmail);
            },
          ),
        );
      },
    );
  }
}

class CakeTile extends StatelessWidget {
  final QueryDocumentSnapshot cake;
  final String currentUserEmail;

  const CakeTile({Key? key, required this.cake, required this.currentUserEmail})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CakeDetailsPage(cake: cake, currentUserEmail: currentUserEmail),
          ),
        );
      },
      child: Container(
        width: 157,
        height: 234,
        decoration: BoxDecoration(
          color: Color(0xFF353842),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  cake['imageUrl'] != null
                      ? Image.network(
                    cake['imageUrl'],
                    fit: BoxFit.cover,
                  )
                      : Center(
                    child: Icon(
                      Icons.cake,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                cake['name'],
                style: TextStyle(fontSize: 16, color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.yellow,
                    size: 16,
                  ),
                  Text(
                    '4.8(163)', // Replace with your desired rating text
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  Text(
                    '60 min', // Replace with your desired duration text
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class CakeDetailsPage extends StatefulWidget {
  final QueryDocumentSnapshot cake;
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

    return BackgroundImageWrapper( // Reintroducing the BackgroundImageWrapper
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: true,
          iconTheme: IconThemeData(
            color: Colors.red, // Change the color of the back button to red
          ),
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
                icon: Icon(Icons.edit, color: Colors.red),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EditCakeScreen(cake: widget.cake)),
                  );
                },
              ),
            if (widget.currentUserEmail == widget.cake['creatorEmail'])
              DeleteCakeButton(cake: widget.cake, currentUserEmail: widget.currentUserEmail),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 80.0), // Adjust top padding to move the image down
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
        color: Color(0xFF272A32).withOpacity(0.8),
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

  // Function to format ingredients
  String _formatIngredients(List<dynamic> ingredients) {
    List<String> filteredIngredients = ingredients
        .where((ingredient) => ingredient != null && ingredient.isNotEmpty)
        .map((ingredient) => '- $ingredient')
        .toList();
    return filteredIngredients.join('\n');
  }


class DeleteCakeButton extends StatelessWidget {
  final QueryDocumentSnapshot cake;
  final String currentUserEmail;

const DeleteCakeButton({
  Key? key,
  required this.cake,
  required this.currentUserEmail,
}) : super(key: key);

@override
Widget build(BuildContext context) {
  return Align(
    alignment: Alignment.bottomRight,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
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
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
          ),
          padding: EdgeInsets.all(8),
          child: Icon(
            Icons.delete,
            color: Colors.red,
          ),
        ),
      ),
    ),
  );
}
}

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
import 'package:highball/home_screen.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({Key? key}) : super(key: key);

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  String filter = 'All'; // Default filter
  String searchQuery = ''; // Initialize search query

  @override
  Widget build(BuildContext context) {
    return BackgroundImageWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          centerTitle: true,
          elevation: 0,
          automaticallyImplyLeading: true,
          iconTheme: IconThemeData(
            color: Colors.red, // Change the color of the back button to red
          ),
          actions: [
            PopupMenuButton(
              icon: Icon(Icons.person), // Use the person icon
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'profile',
                  child: Text('Profile'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ViewProfileScreen()),
                  ),
                ),
                PopupMenuItem(
                  value: 'logout',
                  child: Text('Log Out'),
                  onTap: () async {
                    await AuthService().signout();
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                    DropdownButton<String>(
                      value: filter,
                      icon: Icon(Icons.filter_list, color: Colors.red),
                      underline: Container(),
                      items: <String>['All', 'mostLikes', 'mostComments'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value == 'All' ? 'All Cakes' : value == 'mostLikes' ? 'Most Likes' : 'Most Comments',
                            style: TextStyle(color: Colors.black),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          filter = newValue!;
                        });
                      },
                    ),
                    SizedBox(width: 10),
                  ],
                ),
              ),
            ),
            Expanded(
              child: CakeList(
                filter: filter,
                searchQuery: searchQuery,
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigation(
          currentIndex: 2, // Set the current index to 2 for the CommunityPage
          onTap: (index) {
            switch (index) {
              case 0:
              // Navigate to HomeScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
                break;
              case 1:
              // Navigate to FavoritesPage
                break;
              case 2:
              // Navigate to CommunityPage (current page)
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
  final String filter;
  final String searchQuery;

  const CakeList({Key? key, required this.filter, required this.searchQuery}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance.collection('cakes');

    // Conditionally add orderBy clause based on the filter
    if (filter == 'mostLikes' || filter == 'mostComments') {
      query = query.orderBy(filter == 'mostLikes' ? 'likes' : 'commentsCount', descending: true);
    }

    query = query
        .where('name', isGreaterThanOrEqualTo: searchQuery.isEmpty ? null : searchQuery)
        .where('name', isLessThan: searchQuery.isEmpty ? null : searchQuery + 'z');

    return StreamBuilder(
      stream: query.snapshots(),
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
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 180), // Adjust padding as needed
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.25,
          ),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var cake = snapshot.data!.docs[index];
            return CakeTile(cake: cake);
          },
        );
      },
    );
  }
}

class CakeTile extends StatelessWidget {
  final QueryDocumentSnapshot cake;

  const CakeTile({Key? key, required this.cake}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CakePostPage(cake: cake),
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
          borderRadius: BorderRadius.circular(25),
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
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.favorite_border,
                        color: Colors.red,
                        size: 16,
                      ),
                      SizedBox(width: 4), // Adjust the spacing between the heart icon and the likes count
                      Text(
                        '${cake['likes']}',
                        style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Expanded(child: Container()), // Adds a flexible space between likes and comments
                  Row(
                    children: [
                      Icon(
                        Icons.comment,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 4), // Adjust the spacing between the comments icon and the comments count
                      Text(
                        '${cake['commentsCount']}',
                        style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
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

class CakePostPage extends StatefulWidget {
  final QueryDocumentSnapshot cake;

  const CakePostPage({Key? key, required this.cake}) : super(key: key);

  @override
  _CakePostPageState createState() => _CakePostPageState();
}

class _CakePostPageState extends State<CakePostPage> {
  TextEditingController commentController = TextEditingController();
  String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';
  bool isLiked = false;
  int likeCount = 0;
  List<String> likedComments = [];

  @override
  void initState() {
    super.initState();
    fetchLikeStatus();
    fetchLikeCount();
    fetchLikedComments();
  }

  void fetchLikeStatus() async {
    final userDoc = await FirebaseFirestore.instance.collection('user_profiles').doc(currentUserEmail).get();
    if (userDoc.exists) {
      final List<dynamic> likedCakes = userDoc.data()?['likedCakes'] ?? [];
      if (likedCakes.contains(widget.cake.id)) {
        setState(() {
          isLiked = true;
        });
      }
    }
  }

  void fetchLikeCount() async {
    final cakeDoc = await FirebaseFirestore.instance.collection('cakes').doc(widget.cake.id).get();
    if (cakeDoc.exists) {
      setState(() {
        likeCount = cakeDoc.data()?['likes'] ?? 0;
      });
    }
  }

  void fetchLikedComments() async {
    final userDoc = await FirebaseFirestore.instance.collection('user_profiles').doc(currentUserEmail).get();
    if (userDoc.exists) {
      final List<dynamic> likedCommentsIds = userDoc.data()?['likedComments'] ?? [];
      setState(() {
        likedComments = likedCommentsIds.map((id) => id.toString()).toList();
      });
    }
  }

  void toggleLike() async {
    final userDoc = FirebaseFirestore.instance.collection('user_profiles').doc(currentUserEmail);
    final userSnapshot = await userDoc.get();
    final List<dynamic> likedCakes = userSnapshot.data()?['likedCakes'] ?? [];

    if (likedCakes.contains(widget.cake.id)) {
      likedCakes.remove(widget.cake.id);
      setState(() {
        likeCount--;
        isLiked = false;
      });
    } else {
      likedCakes.add(widget.cake.id);
      setState(() {
        likeCount++;
        isLiked = true;
      });
    }

    await userDoc.update({'likedCakes': likedCakes});
    await FirebaseFirestore.instance.collection('cakes').doc(widget.cake.id).update({'likes': likeCount});
  }

  void addComment(String comment) async {
    final currentUserDoc = await FirebaseFirestore.instance.collection('user_profiles').doc(currentUserEmail).get();
    final userName = currentUserDoc.data()?['name'] ?? 'Anonymous';
    final commentData = {
      'text': comment,
      'userName': userName,
      'timestamp': Timestamp.now(),
      'likes': 0, // Initialize likes count for each new comment
      'owner': currentUserEmail, // Identify the owner of the comment
    };

    await FirebaseFirestore.instance.collection('cakes').doc(widget.cake.id).collection('comments').add(commentData);
    await FirebaseFirestore.instance.collection('cakes').doc(widget.cake.id).update({
      'commentsCount': FieldValue.increment(1),
    });

    commentController.clear();
  }

  void deleteComment(String commentId) async {
    await FirebaseFirestore.instance.collection('cakes').doc(widget.cake.id).collection('comments').doc(commentId).delete();
    await FirebaseFirestore.instance.collection('cakes').doc(widget.cake.id).update({
      'commentsCount': FieldValue.increment(-1),
    });
  }

  void likeComment(String commentId, bool isAlreadyLiked) async {
    final commentRef = FirebaseFirestore.instance.collection('cakes').doc(widget.cake.id).collection('comments').doc(commentId);
    final DocumentSnapshot commentSnapshot = await commentRef.get();
    final int likes = (commentSnapshot.data() as Map<String, dynamic>)['likes'] ?? 0;

    if (isAlreadyLiked) {
      await commentRef.update({
        'likes': likes - 1,
      });
      setState(() {
        likedComments.remove(commentId);
      });
    } else {
      await commentRef.update({
        'likes': likes + 1,
      });
      setState(() {
        likedComments.add(commentId);
      });
    }

    final userDoc = FirebaseFirestore.instance.collection('user_profiles').doc(currentUserEmail);
    final List<dynamic> likedCommentsIds = likedComments;
    await userDoc.update({'likedComments': likedCommentsIds});
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundImageWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(widget.cake['name']),
          centerTitle: true,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    height: 400,
                    color: Colors.grey, // Placeholder color for the cake image
                    child: widget.cake['imageUrl'] != null
                        ? Image.network(
                      widget.cake['imageUrl'],
                      fit: BoxFit.cover,
                    )
                        : Icon(
                      Icons.cake,
                      size: 200,
                      color: Colors.white,
                    ),
                  ),
                  Positioned(
                    right: 16,
                    top: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isLiked ? Colors.red : Colors.white,
                          width: 2, // Adjust the width to make the border thicker
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : Colors.white,
                        ),
                        onPressed: toggleLike,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '$likeCount Likes',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ],
                    ),
                    Text(
                      '${widget.cake['commentsCount']} Comments',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: commentController,
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    hintStyle: TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Color(0xFF252830),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.send, color: Colors.white),
                      onPressed: () => addComment(commentController.text),
                    ),
                  ),
                ),
              ),
              StreamBuilder(
                stream: FirebaseFirestore.instance.collection('cakes').doc(widget.cake.id).collection('comments').orderBy('timestamp', descending: true).snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No comments yet.'));
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var comment = snapshot.data!.docs[index];
                      final String commentId = comment.id;
                      final bool isOwner = comment['owner'] == currentUserEmail;
                      final int likesCount = comment['likes'] ?? 0; // Default to 0 if field doesn't exist
                      final bool isCommentLiked = likedComments.contains(commentId);

                      return ListTile(
                        title: Text(
                          comment['text'],
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          comment['userName'],
                          style: TextStyle(color: Colors.white70),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isOwner) ...[
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.white),
                                onPressed: () => deleteComment(commentId),
                              ),
                            ],
                            IconButton(
                              icon: Icon(isCommentLiked ? Icons.favorite : Icons.favorite_border, color: isCommentLiked ? Colors.red : Colors.white),
                              onPressed: () => likeComment(commentId, isCommentLiked),
                            ),
                            Text(
                              '$likesCount',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

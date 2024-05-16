import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditCakeScreen extends StatefulWidget {
  final QueryDocumentSnapshot cake;

  const EditCakeScreen({Key? key, required this.cake}) : super(key: key);

  @override
  _EditCakeScreenState createState() => _EditCakeScreenState();
}

class _EditCakeScreenState extends State<EditCakeScreen> {
  TextEditingController _flavorController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _typeController = TextEditingController();
  TextEditingController _durationController = TextEditingController();

  String? currentUserEmail;

  @override
  void initState() {
    super.initState();
    getCurrentUserEmail();
    _flavorController.text = widget.cake['flavor'];
    _nameController.text = widget.cake['name'];
    _typeController.text = widget.cake['type'];
    _durationController.text = widget.cake['duration'];
  }

  Future<void> getCurrentUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      currentUserEmail = user?.email;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Cake'),
      ),
      body: currentUserEmail != widget.cake['creatorEmail']
          ? Center(
        child: Text('You are not authorized to edit this cake.'),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _flavorController,
              decoration: InputDecoration(labelText: 'Flavor'),
            ),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              controller: _typeController,
              decoration: InputDecoration(labelText: 'Type'),
            ),
            TextFormField(
              controller: _durationController,
              decoration: InputDecoration(labelText: 'Duration to Make'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _updateCake();
              },
              child: Text('Update Cake'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateCake() async {
    if (currentUserEmail != widget.cake['creatorEmail']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You are not authorized to edit this cake.')),
      );
      return;
    }

    String flavor = _flavorController.text;
    String name = _nameController.text;
    String type = _typeController.text;
    String duration = _durationController.text;

    if (flavor.isEmpty || name.isEmpty || type.isEmpty || duration.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    try {
      // Update cake data in Firestore
      await widget.cake.reference.update({
        'flavor': flavor,
        'name': name,
        'type': type,
        'duration': duration,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cake updated successfully')),
      );

      Navigator.pop(context); // Navigate back to CakeDetailsPage
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating cake: $error')),
      );
    }
  }
}

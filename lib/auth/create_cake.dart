import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';

class CreateCakeScreen extends StatefulWidget {
  const CreateCakeScreen({Key? key}) : super(key: key);

  @override
  _CreateCakeScreenState createState() => _CreateCakeScreenState();
}

class _CreateCakeScreenState extends State<CreateCakeScreen> {
  TextEditingController _flavorController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _typeController = TextEditingController();
  TextEditingController _durationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Cake'),
      ),
      body: SingleChildScrollView(
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
                _saveCake();
              },
              child: Text('Create Cake'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveCake() async {
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
      String userEmail = FirebaseAuth.instance.currentUser?.email ?? '';

      // Save cake data to Firestore
      await FirebaseFirestore.instance.collection('cakes').add({
        'flavor': flavor,
        'name': name,
        'type': type,
        'duration': duration,
        'creatorEmail': userEmail,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cake created successfully')),
      );

      _flavorController.clear();
      _nameController.clear();
      _typeController.clear();
      _durationController.clear();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating cake: $error')),
      );
    }
  }
}

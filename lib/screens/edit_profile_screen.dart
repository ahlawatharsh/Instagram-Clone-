
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/resources/firestore_methods.dart';
import 'package:instagram/utils/utils.dart'; // for showSnackBar

class EditProfileScreen extends StatefulWidget {
  final String uid;
  const EditProfileScreen({super.key, required this.uid});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  Uint8List? _image;
  bool _isLoading = false;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .get();

    setState(() {
      userData = snap.data() as Map<String, dynamic>;
      _usernameController.text = userData!['username'];
      _bioController.text = userData!['bio'] ?? '';
    });
  }

  Future<void> selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    setState(() {
      _image = im;
    });
  }

  Future<void> saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    String res = await FirestoreMethods().updateUserProfile(
      uid: FirebaseAuth.instance.currentUser!.uid,
      username: _usernameController.text,
      bio: _bioController.text,
      file: _image,
    );

    setState(() {
      _isLoading = false;
    });

    if (res == "success") {
      if (mounted) showSnackBar("Profile updated!", context);
      Navigator.pop(context);
    } else {
      if (mounted) showSnackBar(res, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        actions: [
          TextButton(
            onPressed: saveProfile,
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Save", style: TextStyle(color: Colors.blue)),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundImage: _image != null
                      ? MemoryImage(_image!)
                      : NetworkImage(userData!['photoUrl']) as ImageProvider,
                ),
                Positioned(
                  bottom: -10,
                  right: -10,
                  child: IconButton(
                    icon: const Icon(Icons.add_a_photo, color: Colors.blue),
                    onPressed: selectImage,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: "Username",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _bioController,
            decoration: const InputDecoration(
              labelText: "Bio",
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}

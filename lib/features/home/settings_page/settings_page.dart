import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:doczz/features/auth/login_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  File? _profileImage;
  String? _profileImageUrl;
  String? _userName;
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _fetchProfileImageUrl();
    _fetchUserName();
  }

  Future<void> _fetchProfileImageUrl() async {
    if (_user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(_user!.uid)
            .get();

        if (userDoc.exists) {
          if (userDoc.data() != null &&
              (userDoc.data() as Map<String, dynamic>)
                  .containsKey('profileImageUrl')) {
            setState(() {
              _profileImageUrl = userDoc['profileImageUrl'];
            });
          } else {
            print('Field "profileImageUrl" does not exist.');
          }
        } else {
          print('User document does not exist.');
        }
      } catch (e) {
        print('Error fetching profile image URL: $e');
      }
    }
  }

  Future<void> _fetchUserName() async {
    if (_user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(_user!.uid)
            .get();

        if (userDoc.exists) {
          if (userDoc.data() != null &&
              (userDoc.data() as Map<String, dynamic>).containsKey('name')) {
            setState(() {
              _userName = userDoc['username'];
            });
          } else {
            print('Field "name" does not exist.');
          }
        } else {
          print('User document does not exist.');
        }
      } catch (e) {
        print('Error fetching user name: $e');
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (mounted) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });

        if (_user != null) {
          try {
            final storageRef = FirebaseStorage.instance
                .ref()
                .child('Users/${_user!.uid}/profile_pic.jpg');
            await storageRef.putFile(_profileImage!);
            String downloadUrl = await storageRef.getDownloadURL();

            DocumentReference userDocRef =
                FirebaseFirestore.instance.collection('Users').doc(_user!.uid);

            await userDocRef
                .set({'profileImageUrl': downloadUrl}, SetOptions(merge: true));

            if (mounted) {
              setState(() {
                _profileImageUrl = downloadUrl;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Profile picture uploaded successfully')),
              );
            }
          } catch (e) {
            if (mounted) {
              print('Error uploading profile image: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Failed to upload profile picture')),
              );
            }
          }
        }
      }
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : _profileImageUrl != null
                                  ? NetworkImage(_profileImageUrl!)
                                  : null,
                          child:
                              _profileImage == null && _profileImageUrl == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.white,
                                    )
                                  : null,
                        ),
                        const Positioned(
                          bottom: 0,
                          right: 0,
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (_userName != null) ...[
                  Center(
                    child: Text(
                      _userName!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 30),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('Help & Support'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.group),
                  title: const Text('Refer a Friend'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.contact_mail),
                  title: const Text('Contact Us'),
                  onTap: () {},
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

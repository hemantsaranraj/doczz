import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DocumentsPage extends StatefulWidget {
  @override
  _DocumentsPageState createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  User? _user;
  bool _isUploading = false;
  String? _selectedImageName;
  // String? _imageToDelete;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
  }

  Future<void> _showImageSelector() async {
    String? selectedImageName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('image_1'),
                onTap: () {
                  Navigator.of(context).pop('image_1');
                },
              ),
              ListTile(
                title: Text('image_2'),
                onTap: () {
                  Navigator.of(context).pop('image_2');
                },
              ),
            ],
          ),
        );
      },
    );

    if (selectedImageName != null) {
      setState(() {
        _selectedImageName = selectedImageName;
      });
      _getImage();
    }
  }

  Future<void> _getImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    _user = FirebaseAuth.instance.currentUser;
    if (_user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User is not authenticated')),
      );
      return;
    }

    if (_selectedImageName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image name')),
      );
      return;
    }

    if (_imageFile != null) {
      setState(() {
        _isUploading = true;
      });

      try {
        String fileName = '${_selectedImageName!}.jpg';
        var storageRef = FirebaseStorage.instance
            .ref()
            .child('users/${_user!.uid}/$fileName');
        var uploadTask = storageRef.putFile(_imageFile!);
        await uploadTask.whenComplete(() => null);
        String downloadURL = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .collection('documents')
            .doc(_selectedImageName!)
            .set({'imageUrl': downloadURL});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image uploaded and URL saved successfully')),
        );

        setState(() {
          _imageFile = null;
          _selectedImageName = null;
        });
      } catch (e) {
        print('Upload Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() {
          _isUploading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image')),
      );
    }
  }

  Future<void> _deleteImage(String imageName) async {
    if (_user == null) return;

    try {
      var docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .collection('documents')
          .doc(imageName);

      DocumentSnapshot doc = await docRef.get();
      if (doc.exists) {
        String? imageUrl = doc['imageUrl'];

        if (imageUrl != null) {
          var storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
          await storageRef.delete();
        }

        await docRef.delete();
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image deleted successfully')),
        );
      }
    } catch (e) {
      print('Delete Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Documents'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ElevatedButton(
              onPressed: _showImageSelector,
              child: Text('Pick Image'),
            ),
            SizedBox(height: 20),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(_user?.uid)
                  .collection('documents')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var documents = snapshot.data!.docs;

                return Column(
                  children: [
                    for (var doc in documents)
                      Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(doc.id),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteImage(doc.id),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                  ],
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadImage,
              child: _isUploading
                  ? CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.upload_file, color: Colors.white),
                        SizedBox(width: 10),
                        Text('Upload Image'),
                      ],
                    ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
            ),
            if (!_isUploading && _imageFile != null)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 40,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

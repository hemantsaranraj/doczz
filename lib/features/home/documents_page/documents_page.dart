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

  TextEditingController _vehicleNumberController = TextEditingController();
  String? _selectedVehicleType;
  bool _isEditingVehicleInfo = false; // Changed to false

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _loadVehicleInfo();
  }

  Future<void> _loadVehicleInfo() async {
    if (_user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(_user!.uid)
          .get();

      if (userDoc.exists) {
        String? vehicleNumber = userDoc.get('vehicleNumber') as String?;
        String? vehicleType = userDoc.get('vehicleType') as String?;

        if (vehicleNumber != null && vehicleType != null) {
          setState(() {
            _vehicleNumberController.text = vehicleNumber;
            _selectedVehicleType = vehicleType;
            _isEditingVehicleInfo = false; // Show the Edit mode
          });
        } else {
          setState(() {
            _isEditingVehicleInfo =
                true; // Show input fields if info is missing
          });
        }
      } else {
        setState(() {
          _isEditingVehicleInfo =
              true; // Show input fields if document doesn't exist
        });
      }
    }
  }

  Future<void> _showImageSelector() async {
    String? selectedImageName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Document'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Driving Licence'),
                onTap: () {
                  Navigator.of(context).pop('Driving Licence');
                },
              ),
              ListTile(
                title: Text('Registration Certificate'),
                onTap: () {
                  Navigator.of(context).pop('Registration Certificate');
                },
              ),
              ListTile(
                title: Text('Insurance'),
                onTap: () {
                  Navigator.of(context).pop('Insurance');
                },
              ),
              ListTile(
                title: Text('Pollution Certificate'),
                onTap: () {
                  Navigator.of(context).pop('Pollution Certificate');
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

  Future<void> _showUploadDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Upload'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_imageFile != null) ...[
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 80,
                ),
                SizedBox(height: 20),
                Text(
                  'Do you want to upload this document?',
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _uploadImage(); // Trigger the upload
              },
              child: _isUploading
                  ? CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : Text('Upload Document'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteImage(String imageName) async {
    _user = FirebaseAuth.instance.currentUser;
    if (_user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User is not authenticated')),
      );
      return;
    }

    try {
      // Delete the image from Firebase Storage
      var storageRef = FirebaseStorage.instance
          .ref()
          .child('Users/${_user!.uid}/$imageName.jpg');
      await storageRef.delete();

      // Delete the image document from Firestore
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(_user!.uid)
          .collection('documents')
          .doc(imageName)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$imageName deleted successfully')),
      );
    } catch (e) {
      print('Delete Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _getImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      // Show the upload confirmation dialog
      _showUploadDialog();
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
            .child('Users/${_user!.uid}/$fileName');
        var uploadTask = storageRef.putFile(_imageFile!);
        await uploadTask.whenComplete(() => null);
        String downloadURL = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('Users')
            .doc(_user!.uid)
            .collection('documents')
            .doc(_selectedImageName!)
            .set({'imageUrl': downloadURL});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Document uploaded successfully')),
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

  Future<void> _saveVehicleInfo() async {
    _user = FirebaseAuth.instance.currentUser;
    if (_user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User is not authenticated')),
      );
      return;
    }

    if (_vehicleNumberController.text.isEmpty || _selectedVehicleType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter vehicle number and select type')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('Users').doc(_user!.uid).set({
        'vehicleNumber': _vehicleNumberController.text,
        'vehicleType': _selectedVehicleType,
      }, SetOptions(merge: true));

      setState(() {
        _isEditingVehicleInfo = false; // Switch to Edit mode after saving
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vehicle information saved successfully')),
      );
    } catch (e) {
      print('Save Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _editVehicleInfo() {
    setState(() {
      _isEditingVehicleInfo = true;
    });
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (_isEditingVehicleInfo) ...[
                Container(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextField(
                        controller: _vehicleNumberController,
                        decoration: InputDecoration(
                          labelText: 'Vehicle Number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedVehicleType,
                        items: ['Bike', 'Car', 'Truck', 'Van', 'Bus']
                            .map((type) => DropdownMenuItem(
                                  child: Text(type),
                                  value: type,
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedVehicleType = value;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Vehicle Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        isExpanded: true,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _saveVehicleInfo,
                        child: Text('Save'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Vehicle Number: ${_vehicleNumberController.text}\nVehicle Type: $_selectedVehicleType',
                      textAlign: TextAlign.center,
                    ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: _editVehicleInfo,
                    ),
                  ],
                ),
              ],
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _showImageSelector,
                child: Text('Pick Document'),
              ),
              SizedBox(height: 20),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Users')
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
            ],
          ),
        ),
      ),
    );
  }
}

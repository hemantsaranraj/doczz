import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  _DocumentsPageState createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  User? _user;
  bool _isUploading = false;
  String? _selectedImageName;

  final TextEditingController _vehicleNumberController =
      TextEditingController();
  String? _selectedVehicleType;
  bool _isEditingVehicleInfo = false;

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

        setState(() {
          _vehicleNumberController.text =
              vehicleNumber ?? 'null'; // Set to "null" if not present
          _selectedVehicleType =
              vehicleType ?? 'null'; // Set to "null" if not present
          _isEditingVehicleInfo = false;
        });
      } else {
        setState(() {
          _isEditingVehicleInfo = true; // Show input fields if info is missing
        });
      }
    }
  }

  Future<void> _showImageSelector() async {
    String? selectedImageName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Document'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Driving Licence'),
                onTap: () {
                  Navigator.of(context).pop('Driving Licence');
                },
              ),
              ListTile(
                title: const Text('Registration Certificate'),
                onTap: () {
                  Navigator.of(context).pop('Registration Certificate');
                },
              ),
              ListTile(
                title: const Text('Insurance'),
                onTap: () {
                  Navigator.of(context).pop('Insurance');
                },
              ),
              ListTile(
                title: const Text('Pollution Certificate'),
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
          title: const Text('Confirm Upload'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_imageFile != null) ...[
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 80,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Do you want to upload this document?',
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _uploadImage();
              },
              child: _isUploading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Text('Upload Document'),
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
        const SnackBar(content: Text('User is not authenticated')),
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
        const SnackBar(content: Text('User is not authenticated')),
      );
      return;
    }

    if (_selectedImageName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image name')),
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
          const SnackBar(content: Text('Document uploaded successfully')),
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
        const SnackBar(content: Text('Please select an image')),
      );
    }
  }

  Future<void> _saveVehicleInfo() async {
    _user = FirebaseAuth.instance.currentUser;
    if (_user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User is not authenticated')),
      );
      return;
    }

    if (_vehicleNumberController.text.isEmpty || _selectedVehicleType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter vehicle number and select type')),
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
        const SnackBar(content: Text('Vehicle information saved successfully')),
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
        title: const Text('Documents'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Vehicle Info Editing Section
              if (_isEditingVehicleInfo) ...[
                SizedBox(
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
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedVehicleType,
                        items: ['Bike', 'Car', 'Truck', 'Van', 'Bus']
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
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
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _saveVehicleInfo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Displaying Vehicle Info Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Vehicle Number: ${_vehicleNumberController.text.isNotEmpty ? _vehicleNumberController.text : 'null'}\n'
                      'Vehicle Type: ${_selectedVehicleType ?? 'null'}',
                      textAlign: TextAlign.center,
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: _editVehicleInfo,
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),

              // Document Picker Button
              ElevatedButton(
                onPressed: _showImageSelector,
                child: const Text('Select a Document to upload'),
              ),
              const SizedBox(height: 20),

              // Document List Section
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Users')
                    .doc(_user?.uid)
                    .collection('documents')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var documents = snapshot.data!.docs;

                  return Column(
                    children: [
                      for (var doc in documents)
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8.0),
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
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => _deleteImage(doc.id),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
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

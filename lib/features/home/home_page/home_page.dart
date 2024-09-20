import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:doczz/features/home/home_page/number_plate_widget.dart'; // Import the custom NumberPlate widget

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<Map<String, String>> _getUserDetails() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Retrieve the user document using the user's UID
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          // Return the vehicle type and number from the document
          String vehicleType = userDoc.get('vehicleType') as String;
          String vehicleNumber = userDoc.get('vehicleNumber') as String;
          return {
            'username': userDoc.get('username') as String,
            'vehicleType': vehicleType,
            'vehicleNumber': vehicleNumber,
          };
        } else {
          return {
            'username': 'User',
            'vehicleType': 'Unknown',
            'vehicleNumber': 'Unknown',
          };
        }
      } catch (e) {
        print('Error fetching user details: $e');
        return {
          'username': 'New User',
          'vehicleType': 'Unknown',
          'vehicleNumber': 'Unknown',
        };
      }
    }
    return {
      'username': 'User',
      'vehicleType': 'Unknown',
      'vehicleNumber': 'Unknown',
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: _getUserDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Loading...'),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Error'),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final userDetails = snapshot.data ??
            {
              'username': 'User',
              'vehicleType': 'Unknown',
              'vehicleNumber': 'Unknown',
            };

        return Scaffold(
          appBar: AppBar(
            title: Text('Hi, ${userDetails['username']}'),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    NumberPlate(
                      vehicleNumber: userDetails['vehicleNumber'] ?? 'Unknown',
                    ),
                    const SizedBox(height: 30.0),
                    Text(
                      'Vehicle type: ${userDetails['vehicleType'] ?? 'Unknown'}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Users')
                      .doc(FirebaseAuth.instance.currentUser?.uid)
                      .collection('documents')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            'Kindly upload your details in the documents page',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }

                    final documents = snapshot.data!.docs;

                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        final imageUrl = documents[index]['imageUrl'];
                        final imageName = documents[index].id;

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FullScreenImage(imageUrl: imageUrl),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                          child: Text('Failed to load image.'));
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    imageName,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document View'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}

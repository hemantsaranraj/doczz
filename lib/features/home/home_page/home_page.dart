import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  Future<String> _getUsername() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Retrieve the user document using the user's UID
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Users') // Ensure this matches your collection name
            .doc(user
                .uid) // Use UID instead of email if UID is used as document ID
            .get();

        if (userDoc.exists) {
          // Return the username field from the document
          return userDoc.get('username') as String;
        } else {
          return 'User'; // Default username if document does not exist
        }
      } catch (e) {
        print('Error fetching username: $e');
        return 'User'; // Default username in case of an error
      }
    }
    return 'User'; // Default username if user is null
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getUsername(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Loading...'),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Error'),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final username = snapshot.data ?? 'User';

        return Scaffold(
          appBar: AppBar(
            title: Text('Hi, $username'),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser?.uid)
                .collection('documents')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No images found.'));
              }

              final documents = snapshot.data!.docs;

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                                return Center(
                                    child: Text('Failed to load image.'));
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              imageName,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
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
        );
      },
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  FullScreenImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image View'),
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

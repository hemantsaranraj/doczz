import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final TextEditingController _searchController = TextEditingController();
  QuerySnapshot? searchResults;

  void _searchUser() async {
    String searchText = _searchController.text.trim();

    if (searchText.isEmpty) return;

    try {
      QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('username', isEqualTo: searchText)
          .get();

      if (usersSnapshot.docs.isEmpty) {
        // Search by vehicle number if no username match is found
        usersSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .where('vehicleNumber', isEqualTo: searchText)
            .get();
      }

      if (usersSnapshot.docs.isEmpty) {
        // Show popup if no user found
        _showNoUserFoundDialog();
      } else {
        setState(() {
          searchResults = usersSnapshot;
        });
      }
    } catch (e) {
      print('Error searching user: $e');
    }
  }

  void _showNoUserFoundDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No user found'),
          content: const Text(
              'The username or vehicle number entered does not exist in the database.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome Admin'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Enter Username or Vehicle Number',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchUser,
                ),
              ),
            ),
            const SizedBox(height: 20),
            searchResults != null
                ? Expanded(
                    child: ListView.builder(
                      itemCount: searchResults!.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot userDoc = searchResults!.docs[index];
                        return UserDocumentsWidget(
                          userId: userDoc.id,
                          username: userDoc.get('username'),
                          vehicleType: userDoc.get('vehicleType'),
                          vehicleNumber: userDoc.get('vehicleNumber'),
                        );
                      },
                    ),
                  )
                : const Text('Search for a user to display their documents'),
          ],
        ),
      ),
    );
  }
}

class UserDocumentsWidget extends StatelessWidget {
  final String userId;
  final String username;
  final String vehicleType;
  final String vehicleNumber;

  const UserDocumentsWidget({
    super.key,
    required this.userId,
    required this.username,
    required this.vehicleType,
    required this.vehicleNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Username: $username',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          'Vehicle Type: $vehicleType',
          style: const TextStyle(fontSize: 18),
        ),
        Text(
          'Vehicle Number: $vehicleNumber',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 10),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Users')
              .doc(userId)
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
              return const Center(child: Text('No images found.'));
            }

            final documents = snapshot.data!.docs;

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 1.0,
              ),
              itemCount: documents.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
        const Divider(thickness: 2),
      ],
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

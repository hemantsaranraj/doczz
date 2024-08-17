import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doczz/features/home/admin/admin_dashboard.dart'; // Admin dashboard screen

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({Key? key}) : super(key: key);

  @override
  _AdminLoginPageState createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _adminLogin() async {
    try {
      // Attempt to sign in the user
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Check if the user is an admin
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userCredential.user?.email)
          .get();
      // print("User Document: ${userDoc.data()}");

      if (userDoc.exists) {
        // Cast the document data to a Map<String, dynamic>
        // Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        if (userDoc['isAdmin'] == "true") {
          // Navigate to the admin dashboard
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => AdminDashboard(), // Your admin dashboard
            ),
          );
        } else {
          // If not an admin, show an error
          FirebaseAuth.instance.signOut();
          _showErrorDialog("Access Denied",
              "You do not have permission to access this panel.");
        }
      } else {
        // Document does not exist
        FirebaseAuth.instance.signOut();
        _showErrorDialog("Login Failed", "User document not found.");
      }
    } catch (e) {
      _showErrorDialog("Login Failed", e.toString());
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final Color textColor =
        brightness == Brightness.dark ? Colors.white : Colors.black;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20),
              Icon(Icons.admin_panel_settings, size: 100, color: textColor),
              SizedBox(height: 80),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Admin Email',
                  labelStyle: TextStyle(color: textColor),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                style: TextStyle(color: textColor),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: textColor),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: textColor),
                    onPressed: _togglePasswordVisibility,
                  ),
                ),
                style: TextStyle(color: textColor),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _adminLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  minimumSize: Size(double.infinity, 48),
                ),
                child: Text('Admin Login',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold, color: textColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

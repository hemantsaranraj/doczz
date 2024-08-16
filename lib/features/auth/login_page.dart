import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:doczz/features/welcome_page/welcome_screen.dart'; // Correct import
import 'package:doczz/features/auth/register_page.dart'; // Correct import
import 'package:doczz/features/auth/admin_login_page.dart'; // Add this import

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              const WelcomeScreen(), // Ensure WelcomeScreen is a Widget
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Icon(Icons.error, color: Colors.red, size: 60),
          content: Text(e.toString()),
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
              Icon(Icons.person, size: 100, color: textColor),
              SizedBox(height: 80),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
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
              SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Forgot password action
                  },
                  child: Text('Forgot Password?',
                      style: TextStyle(color: textColor)),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  minimumSize: Size(double.infinity, 48),
                ),
                child: Text('Login',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold, color: textColor)),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          const RegisterPage(), // Ensure RegisterPage is a Widget
                    ),
                  );
                },
                child: Text('Don\'t have an account? Register here',
                    style: TextStyle(color: textColor)),
              ),
              SizedBox(height: 20), // Add spacing before the admin login button
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AdminLoginPage(),
                    ),
                  );
                },
                child: Text('Admin Login', // Add the admin login option
                    style: TextStyle(color: textColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

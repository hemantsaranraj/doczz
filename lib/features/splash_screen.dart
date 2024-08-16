import 'package:flutter/material.dart';
import 'package:doczz/constants/images.dart'; // Update with your actual path
import 'package:doczz/features/auth/login_page.dart'; // Update with your actual path
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Import Font Awesome Flutter package

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the current theme's brightness
    final brightness = Theme.of(context).brightness;

    // Choose the logo based on the current theme
    final logoImage = brightness == Brightness.light ? blackLogo : whiteLogo;

    // Get the background color from the current theme
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor, // Apply the background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Display the logo
            Image.asset(
              logoImage,
              width: 200, // Adjust size as needed
              height: 200, // Adjust size as needed
            ),
            SizedBox(height: 20), // Space between logo and button
            // Right arrow button to navigate to the LoginPage
            IconButton(
              icon: FaIcon(
                FontAwesomeIcons.arrowRight, // Use Font Awesome icon
                size: 40, // Adjust size as needed
                color: Theme.of(context)
                    .iconTheme
                    .color, // Adjust icon color based on theme
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        const LoginPage(), // Navigate to LoginPage
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

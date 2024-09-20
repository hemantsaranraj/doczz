import 'package:flutter/material.dart';
import 'package:doczz/constants/images.dart';
import 'package:doczz/features/auth/login_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    final logoImage = brightness == Brightness.light ? blackLogo : whiteLogo;

    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              logoImage,
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20), // Space between logo and button

            IconButton(
              icon: FaIcon(
                FontAwesomeIcons.arrowRight,
                size: 40,
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
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

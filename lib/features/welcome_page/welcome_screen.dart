import 'package:flutter/material.dart';
import 'package:doczz/features/home/home_page/home_page.dart';
import 'package:doczz/features/home/documents_page/documents_page.dart';
import 'package:doczz/features/home/settings_page/settings_page.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int _selectedIndex = 1;

  static final List<Widget> _pages = <Widget>[
    const DocumentsPage(),
    const HomePage(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.transparent,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.description,
                color: Theme.of(context).iconTheme.color,
              ),
              label: 'Documents',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                color: Theme.of(context).iconTheme.color,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.settings,
                color: Theme.of(context).iconTheme.color,
              ),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

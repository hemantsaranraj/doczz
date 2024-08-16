import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome to the Admin Dashboard!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to another admin feature or perform some admin action
              },
              child: const Text('Manage Users'),
            ),
            ElevatedButton(
              onPressed: () {
                // Another admin-specific feature
              },
              child: const Text('View Reports'),
            ),
          ],
        ),
      ),
    );
  }
}

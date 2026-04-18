import 'package:flutter/material.dart';
import '../screens/alerts_screen.dart';

class NotificationAction extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.notifications_none),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AlertsScreen()),
        );
      },
    );
  }
}

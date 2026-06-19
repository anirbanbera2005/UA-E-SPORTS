import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          "WELCOME TO UA ESPORTS",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}
// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taboua_app/auth.dart';
import 'package:taboua_app/messages/signup.dart';

class BottomBar extends StatelessWidget {
  final Color personIconColor;
  final Color scanIconBackgroundColor;
  final Color scanIconColor;
  final Color homeIconColor;
  final Color backgroundColor;
  bool isGuestUser = FirebaseAuth.instance.currentUser?.isAnonymous ?? true;
  

  BottomBar({
    this.personIconColor = const Color(0xFF616264),
    this.scanIconBackgroundColor = const Color(0xFF97B980),
    this.scanIconColor = Colors.white, // Default color of the circle
    this.homeIconColor = const Color(0xFF616264),
    this.backgroundColor = Colors.white, // Default background color
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      color: backgroundColor, // Set the background color
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          

IconButton(
            icon: Icon(
              isGuestUser ? Icons.person_add : Icons.person ,
              size: 25,
              color: personIconColor,
            ),
            onPressed: () {
              if (isGuestUser) {
                // Navigate to signup screen for guest users
                Navigator.pushNamed(context, '/signup_screen');
              } else {
                Navigator.pushNamed(context, '/profile_page');
              }
            },
          ),

          Container(
            width: 60.0,
            height: 60.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scanIconBackgroundColor,
            ),
            child: Center(
              child: IconButton(
                icon: Image.asset(
                  'images/scan2.png', 
                  width: 60.0, 
                  height: 60.0, 
                  color: scanIconColor, 
                ),
                onPressed: () {
                  Navigator.pushNamed(context,'/wasteType_model');
                },
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.home),
            color: homeIconColor,
            onPressed: () {
              Navigator.pushNamed(context, '/home_screen');
            },
          ),
        ],
      ),
    );
  }
}

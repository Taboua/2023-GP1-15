// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taboua_app/auth.dart';
import 'package:taboua_app/messages/signup.dart';
import 'bottom_bar.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = '';
  bool isGuestUser = false; // You'll set this based on your authentication logic
@override
void initState() {
  super.initState();
  determineUserType();
}


void determineUserType() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.isAnonymous ?? true) {
      // If user is null or isAnonymous is true, treat as a guest
      setState(() {
        isGuestUser = true;
      });
    } else {
      // User is not a guest, proceed to load user-specific data
      setState(() {
        isGuestUser = false;
      });
      _loadUserName();
    }
  }


  /*@override
  void initState() {
    super.initState();
    _loadUserName();
  }*/

  void _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          userName = userDoc['firstName'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3F3F3),

        appBar: AppBar(
           automaticallyImplyLeading: false,
          backgroundColor: Color(0xFFE9E9E9),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          toolbarHeight: 140, // Adjust the toolbar height
          title: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Text(
                  "مرحبا $userName",
                  style: GoogleFonts.balooBhaijaan2(
                    fontSize: 32.0,
                    color: Color(0xFF363436),
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Image.asset(
                  'images/logo.png', 
                  width: 90,
                  height: 90,
                ),
              ),
            ],
          ),
          

          //leading: GestureDetector(
           leading: isGuestUser ? null : GestureDetector(
          onTap: () {
            // Handle sign out
                FirebaseAuth.instance.signOut();
                Navigator.pushNamed(context, '/login_screen');
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Icon(
              Icons.logout, 
              size: 30,
              color: Colors.black,
            ),
          ),
        ),
        ),





     
     body: Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      ServiceButton(
        title: "حاويات النفايات",
        iconPath: "images/bin.png",
        routeName: '/view_garbage_bins',
      ),
      ServiceButton(
        title: "طلبات الحاويات",
        iconPath: "images/bin1.png",
        routeName: '/view_requests',
        isEnabled: !isGuestUser,

      ),
      ServiceButton(
        title: "مراكز اعاده التدوير",
        iconPath: "images/recyling.png",
        routeName: '/view_recycling_centers',
      ),
      ServiceButton(
        title: "تصنيف النفايات",
        iconPath: "images/scan1.png",
        routeName: '/waste_types',
      ),
      ServiceButton(
        title: "البلاغات",
        iconPath: "images/complaints.png",
        routeName: '/view_complaints',
        isEnabled: !isGuestUser,
      ),
    ],
  ),
),

    
   bottomNavigationBar: BottomBar(
    scanIconColor: Color(0xFF97B980),
    scanIconBackgroundColor : Colors.white,
    personIconColor : Colors.white,
    homeIconColor : Colors.white,
    backgroundColor : Color(0xFF97B980),
   ),

    );
  }
}







class ServiceButton extends StatelessWidget {
  final String title;
  final String iconPath;
  final String routeName;
  final bool isEnabled;

  const ServiceButton({
    Key? key,
    required this.title,
    required this.iconPath,
    required this.routeName,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: Container(
        width: 320,
        height: 80,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFE9E9E9),
          borderRadius: BorderRadius.circular(19),
        ),
        child: InkWell(
          onTap: isEnabled
              ? () {
                  Navigator.pushNamed(context, routeName);
                }
              : () {
               SignupDialog.showSignupDialog(context); 
                },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Text(
                  title,
                  style: GoogleFonts.balooBhaijaan2(
                    textStyle: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF363436),
                    ),
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Image.asset(
                  iconPath,
                  width: 45,
                  height: 45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



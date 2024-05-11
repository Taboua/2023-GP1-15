// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taboua_app/screens/bottom_bar.dart';
import 'package:taboua_app/screens/editProfilePage.dart';

class ProfilePage extends StatefulWidget {
  final User user;

  ProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String firstName = '';
  String lastName = '';
  String userEmail = '';
  String phoneNumber = ''; // Add this line for phone number
  String dateOfBirth = ''; // Add this line for date of birth
  bool isEditingPassword = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }



  void _loadUserData() async {
    final user = widget.user;
    // ignore: unnecessary_null_comparison
    if (user != null) {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          firstName = userDoc['firstName'];
          lastName = userDoc['lastName'];
          userEmail = user.email!;
          phoneNumber = userDoc['phoneNumber'];
          dateOfBirth = userDoc['DateOfBirth'];
        });
      }
    }
  }


   

  Widget _buildProfileItem(String title, String value) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end, // Align to the right
        children: [
          Text(
            title,
            style: GoogleFonts.balooBhaijaan2(
              textStyle: const TextStyle(
                fontSize: 20,
              ),
            ),
            textAlign: TextAlign.right,
          ),
          
        ],
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.end, // Align to the right
        children: [
          Spacer(), 
          Text(
            value,
            style: GoogleFonts.balooBhaijaan2(
              textStyle: const TextStyle(
                fontSize: 18,
              ),
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          SizedBox(height: 25),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                " المعلومات الشخصية",
                style: GoogleFonts.balooBhaijaan2(
                  textStyle: const TextStyle(
                    fontSize: 26,
                  ),
                ),
              ),
            ),
          ),
          

          if (firstName.isEmpty) 
            CircularProgressIndicator(

             valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF97B980)), 

            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildProfileItem("الاسم الأول", firstName),
                  SizedBox(height: 10),
                  _buildProfileItem("الاسم الأخير", lastName),
                  SizedBox(height: 10),
                  _buildProfileItem("البريد الإلكتروني", userEmail),
                  SizedBox(height: 10),
                  _buildProfileItem("رقم الهاتف", phoneNumber),
                  SizedBox(height: 10),
                  _buildProfileItem("تاريخ الميلاد", dateOfBirth),
                ],
              ),
            ),
          SizedBox(height: 20),

          Padding(
  padding: const EdgeInsets.symmetric(horizontal: 30),
  child: ElevatedButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProfilePage(
            currentFirstName: firstName,
            currentLastName: lastName,
            currentEmail: userEmail,
            currentPhoneNumber: phoneNumber,
            currentDateOfBirth: dateOfBirth,
          ),
        ),
      );
    },
    
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      backgroundColor: Color(0xFF97B980),
      padding: EdgeInsets.all(10),
      minimumSize: Size(300, 10),
      elevation: 0,
    ),
    child: Text(
     "تحديث المعلومات الشخصية" ,
      style: GoogleFonts.balooBhaijaan2(
        textStyle: const TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
      ),
    ),
  ),
),

SizedBox(height: 12),

Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: ElevatedButton(
              onPressed: () {
                // Handle sign out
                FirebaseAuth.instance.signOut();
                Navigator.pushNamed(context, '/login_screen');
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ), 
                backgroundColor: Color(0xFF97B980),
                padding: EdgeInsets.all(10),
                minimumSize: Size(300, 10),
                elevation: 0,
              ),
              child: Text(
                "تسجيل الخروج",
                style: GoogleFonts.balooBhaijaan2(
                  textStyle: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

SizedBox(height: 12),

Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: ElevatedButton(
              onPressed: () {
                  Navigator.pushNamed(context, '/delete_account');

              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ), 
                backgroundColor: Colors.red,
                padding: EdgeInsets.all(10),
                minimumSize: Size(300, 10),
                elevation: 0,
              ),
              child: Text(
                "حذف الحساب",
                style: GoogleFonts.balooBhaijaan2(
                  textStyle: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

        ],
      ),

      bottomNavigationBar: BottomBar(),
    );
  }
}

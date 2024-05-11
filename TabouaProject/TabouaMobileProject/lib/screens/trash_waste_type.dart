
// ignore_for_file: prefer_const_constructors, must_be_immutable, camel_case_types

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taboua_app/screens/view_garbage_bins.dart';
import 'dart:io';
import 'bottom_bar.dart';

class trash_waste_type extends StatelessWidget {
    File image;
    trash_waste_type({super.key, required this.image});
   String userId = FirebaseAuth.instance.currentUser!.uid; // to save image pred with user id

  @override
  Widget build(BuildContext context) {

 return Scaffold(
appBar: AppBar(
      iconTheme: IconThemeData(
    color: Colors.black, 
  ),
      backgroundColor: Colors.white,
      title: Text("حاويات النفايات",
      style: GoogleFonts.balooBhaijaan2(
        color: Colors.black,
        fontSize: 26,
      ),
      ),
),
 body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
           crossAxisAlignment: CrossAxisAlignment.center, 
        
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child:
                    Image.file(
                        image!,
                        height: 200,
                        width: 200,
                        fit: BoxFit.cover,
                      )
              ),
            SizedBox(height: 16),
            Text("نفايات لا يعاد تدويرها" ,
             style: TextStyle(fontSize:25 ,
             fontFamily: 'BalooBhaijaan2'),
             
             ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
         GestureDetector(
                onTap: () {
                  // Navigate to view garabge screen
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => viewGrabageBin(userId: userId),
                  ));
                },
                child: Text(
                  "حاويات النفايات" ,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'BalooBhaijaan2',
                    color: Colors.blue, 
                  ),
                ),
              ),
                           const SizedBox(width: 5),

  Text("الرجاء التخلص منها في" ,
             style: TextStyle(fontSize:16 ,
             fontFamily: 'BalooBhaijaan2'),
             
             ),
          ],), 
           
             const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomBar(),

    );
  }
}
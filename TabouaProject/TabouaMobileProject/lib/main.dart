
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:taboua_app/auth.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
//import 'package:page_transition/page_transition.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

@override
Widget build(BuildContext context) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
       useMaterial3: false,
       //fontFamily: 'BalooBhaijaan2',
    ),


    // First screen will appear when open app
    home: AnimatedSplashScreen(
            duration: 3000,
            splashIconSize: 160, // size of logo
            splash:Image.asset("images/logo.png" ,
            ),
            nextScreen: Auth(),// navigate to this screen
            splashTransition: SplashTransition.scaleTransition, // the way of transition
           // pageTransitionType: PageTransitionType.bottomToTop,
            )
  );
}

}




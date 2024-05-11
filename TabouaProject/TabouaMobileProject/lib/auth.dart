// ignore_for_file: dead_code, null_check_always_fails

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taboua_app/screens/change_email.dart';
import 'package:taboua_app/screens/change_location.dart';
import 'package:taboua_app/screens/change_password.dart';
import 'package:taboua_app/screens/complaint_details.dart';
import 'package:taboua_app/screens/correct_prediction.dart';
import 'package:taboua_app/screens/edit_complaint.dart';
import 'package:taboua_app/screens/edit_complaint_location.dart';
import 'package:taboua_app/screens/edit_request.dart';
import 'package:taboua_app/screens/forgot_password.dart';
import 'package:taboua_app/screens/home_screen.dart';
import 'package:taboua_app/screens/login_screen.dart';
import 'package:taboua_app/screens/profile_page.dart';
import 'package:taboua_app/screens/raise_complaint.dart';
import 'package:taboua_app/screens/requested_bin_details.dart';
import 'package:taboua_app/screens/signup_screen.dart';
import 'package:taboua_app/screens/trash_waste_type.dart';
import 'package:taboua_app/screens/user_prediction.dart';
import 'package:taboua_app/screens/view_location.dart';
import 'package:taboua_app/screens/view_complaints.dart';
import 'package:taboua_app/screens/view_garbage_bins.dart'; 
import 'package:taboua_app/screens/view_recycling_centers.dart';
import 'package:taboua_app/screens/view_requests.dart';
import 'package:taboua_app/screens/delete_account.dart';
import 'package:taboua_app/screens/wasteType_model.dart';
import 'package:taboua_app/screens/waste_prediction.dart';
import 'package:taboua_app/screens/waste_types.dart';



class Auth extends StatefulWidget {
  const Auth({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AuthState createState() => _AuthState();
}



class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> loginAsGuest() async {
    try {
      await _firebaseAuth.signInAnonymously();
      // Additional logic upon successful login, if needed
    } catch (e) {
      // Handle error
    }
  }
}




GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class _AuthState extends State<Auth> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthScreen(),
        '/view_garbage_bins': (context) => viewGrabageBin(userId:FirebaseAuth.instance.currentUser!.uid ,),
        // ignore: prefer_const_constructors
        '/view_recycling_centers': (context) => viewRecyclingCenters(),
        '/home_screen': (context) => const HomeScreen(),
        '/login_screen' :(context) => const LoginScreen(),
        '/signup_screen' :(context) => const SignupScreen(),
         '/profile_page': (context) => ProfilePage(user: FirebaseAuth.instance.currentUser!),
         '/password_change': (context) => const PasswordChange(),
         '/change_email': (context) => const EmailChange(),
         '/forgot_password': (context) => const ForgetPassword(),
         '/view_requests': (context) => viewRequests(userId: FirebaseAuth.instance.currentUser!.uid),
          '/delete_account': (context) => DeleteAccount(user: FirebaseAuth.instance.currentUser!),
          '/wasteType_model': (context) => WasteTypeModel(),
          '/waste_types': (context) => waste_types(),
         '/waste_prediction': (context) => waste_predicition(image: null!, type: null!, probability: '',),
        '/correct_prediction': (context) => correct_prediction(wasteType:null!),
        '/trash_waste_type': (context) => trash_waste_type(image:null!),
       '/user_prediction': (context) => user_prediction(image:null! , wrongType: null!,),
       '/view_complaints': (context) => view_complaints(userId: FirebaseAuth.instance.currentUser!.uid),
       '/raise_complaint': (context) => raise_complaint(selectedLocation: null,userId: FirebaseAuth.instance.currentUser!.uid ),
       '/change_location': (context) => change_location(currentLocation: null, complaintLocation:null , userId:FirebaseAuth.instance.currentUser!.uid , address: null!,),
       'complaint_details': (context) => complaint_details(complaint:null , userId: FirebaseAuth.instance.currentUser!.uid,),
       'edit_complaint': (context) => edit_complaint(complaint: null!, userId:FirebaseAuth.instance.currentUser!.uid , updatedLocation: null!),
       'edit_complaint_location': (context) => edit_complaint_location(userId:FirebaseAuth.instance.currentUser!.uid , complaint: null! , address: null!,),
       'view_location': (context) => view_location( location:null! , localArea : null! , screenLable: null!,),
       'requested_bin_details': (context) => requested_bin_details( garbageBinRequest:null! , userId :FirebaseAuth.instance.currentUser!.uid),
       'edit_request': (context) => edit_request( userId:FirebaseAuth.instance.currentUser!.uid , request:null! , updatedLocation: null!,),




      },
    );
  }
}

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const HomeScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}

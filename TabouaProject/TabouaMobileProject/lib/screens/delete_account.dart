// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, avoid_print, use_rethrow_when_possible

import 'package:firebase_auth/firebase_auth.dart';
// ignore: unnecessary_import
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeleteAccount extends StatefulWidget {
  @override
  // ignore: override_on_non_overriding_member
  final User user;

  const DeleteAccount({Key? key, required this.user}) : super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  _DeleteAccountState createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // ignore: unused_field
  bool _isLoading = false;
  bool? isChecked = false;
  final _passwordController = TextEditingController();
  String _passwordErrorText = "";
  String _confirmDeleteAccount = "";

  Future<void> _deleteAccount() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final password = _passwordController.text.trim(); // check the password that user enter
      if (password.isNotEmpty) {
        // Re-authenticate with the entered password
        await _reauthenticate(password);
        // delete the account
        await _auth.currentUser?.delete();
        //Sign out
        FirebaseAuth.instance.signOut();
        Navigator.pushNamed(context, '/login_screen');
        print("User account deleted successfully");
      }
    } catch (e) {
      print("Error deleting account: $e");
      _passwordErrorText = "كلمة السر غير صحيحة";
      // Handle errors
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
// if user log in in app from long time , then need to reauthincate 
  Future<void> _reauthenticate(String password) async {
    try {
      final userInfo = widget.user; // get user id to retreive user email
      // ignore: unnecessary_null_comparison
      if (userInfo != null) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: userInfo.email!,
          password: password,
        );// get user credintinal 
        await userInfo.reauthenticateWithCredential(credential);
        print("Re-authenticated successfully");
      } else {
        print("No user is currently signed in.");
      }
    } on FirebaseAuthException catch (e) {
      print("Error during re-authentication: $e");
      throw e; // Propagate the exception for further handling
    }
  }

// validte password
  void _validatePassword(String value) {
    if (value.isEmpty) {
      setState(() {
        _passwordErrorText = "كلمة السر مطلوبة";
      });
    } else {
      setState(() {
        _passwordErrorText = "";
      });
    }
  }
// check if user agree to delete his agreement to delete account
  void _validateConfirmDeleteAccount(bool isChecked) {
    if (isChecked == false) {
      setState(() {
        _confirmDeleteAccount = "الرجاء الموافقة على حذف الحساب";
      });
    } else {
      setState(() {
        _confirmDeleteAccount = "";
      });
    }
  }

//Check if user enter all fileds
  Future _validateUserInputs() async {
    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      setState(() {
        _passwordErrorText = "كلمة السر مطلوبة";
      });
    }
    if (isChecked == false) {
      setState(() {
        _confirmDeleteAccount = "الرجاء الموافقة على حذف الحساب";
      });
    }
    if (isChecked == true && password.isNotEmpty) {
      _deleteAccount(); // call deleteAccount function
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(height: 40),
            IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
                padding: EdgeInsets.only(right: 320.0),
                color: Color(0xFF363436)),

            // Screen title
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "حذف الحساب",
                  style: GoogleFonts.balooBhaijaan2(
                    textStyle: const TextStyle(
                      fontSize: 26,
                    ),
                  ),
                ),
              ),
            ),
            // Display infmration to user
            Padding(
              padding: EdgeInsets.only(right: 33.0, left: 33.0),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Icon(
                    Icons.info, // Replace with your desired icon
                    color: Colors.red, // Icon color
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 33,
                    ),
                    child: Text(
                      "بعد الضغط على زر التأكيد لحذف الحساب ، سوف يتم حذف حسابك من نظام تبوأ ولن تستطيع تسجيل الدخول لهذا الحساب مره أخرى",
                      textAlign: TextAlign.right,
                      style: GoogleFonts.balooBhaijaan2(
                        textStyle: const TextStyle(
                          fontSize: 17,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),
            // Show password filed
            Stack(
              alignment: AlignmentDirectional.topEnd,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Container(
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: Colors.grey), // Add a gray border
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'كلمة السر',
                            prefixIcon: Icon(
                              Icons.lock,
                            ), // Add a lock icon
                          ),
                          onChanged: (value) {
                            _validatePassword(value);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // only will show the error message when user not enter password pr incorrect password
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _passwordErrorText,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),

//Move to Forget Password screen
            Padding(
              padding: EdgeInsets.only(right: 33.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/forgot_password');
                },
                child: Text(
                  'نسيت كلمة السر؟',
                  style: GoogleFonts.balooBhaijaan2(
                    fontSize: 18,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
              ),
            ),
            // CheckBox input
            Padding(
              padding: EdgeInsets.only(right: 22.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "أوافق على حذف الحساب",
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.balooBhaijaan2(
                      textStyle: const TextStyle(
                        fontSize: 17,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Checkbox(
                    tristate: true,
                    activeColor: Color(0xFF97B980), // Color when checked
                    checkColor: Colors.white, // Color of the check icon
                    fillColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                      if (states.contains(MaterialState.selected)) {
                        return Color(0xFF97B980); // Color when unchecked
                      }
                      return Colors.grey; // Default color when unchecked
                    }),
                    value: isChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        isChecked = value ?? false; 
                        _validateConfirmDeleteAccount(isChecked!); // to check if user check the box
                      });
                    },
                  ),
                ],
              ),
            ),
            // only the error message will show if user not check the box
            Padding(
              padding: EdgeInsets.only(right: 66.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _confirmDeleteAccount,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),

            SizedBox( height: 20, ),
            // delete account button
            Padding(
              padding: EdgeInsets.all(25),
              child: GestureDetector(
                onTap: _validateUserInputs,
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(0xFF97B980),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Text(
                      'التأكيد لحذف الحساب',
                      style: GoogleFonts.balooBhaijaan2(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore_for_file: prefer_const_constructors, unused_element, prefer_final_fields

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taboua_app/auth.dart';
import 'package:taboua_app/messages/confirm.dart';
import 'package:taboua_app/messages/success.dart';

class EmailChange extends StatefulWidget {
  const EmailChange({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _EmailChangeState createState() => _EmailChangeState();
}

class _EmailChangeState extends State<EmailChange> {
  final _emailController = TextEditingController();
  String _emailErrorText = "";
  String _confirmationMessage = "";

  void _validateEmail(String value) {
    if (value.isEmpty) {
      setState(() {
        _emailErrorText = "البريد الإلكتروني مطلوب";
      });
    } else if (!isValidEmail(value)) {
      setState(() {
        _emailErrorText = "البريد الإلكتروني غير صحيح";
      });
    } else {
      setState(() {
        _emailErrorText = "";
      });
    }
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    return emailRegex.hasMatch(email);
  }



void _changeEmail() async {
  final newEmail = _emailController.text;

  if (newEmail.isEmpty) {
    if (mounted) {
      setState(() {
        _emailErrorText = "البريد الإلكتروني مطلوب";
      });
    }
    return;
  }

  if (_emailErrorText.isEmpty) {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      // Check if the new email is already in use
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: newEmail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        if (mounted) {
          setState(() {
            _emailErrorText = "البريد الإلكتروني مستخدم بالفعل";
          });
        }
        return;
      }

      // Show confirmation dialog
      // ignore: use_build_context_synchronously
      ConfirmationDialog.show(
        context,
        "تأكيد تغيير البريد الإلكتروني",
        "هل أنت متأكد أنك تريد تغيير البريد الإلكتروني؟",
        () async {
          try {
            // Send email verification to the new email address
            await user?.verifyBeforeUpdateEmail(newEmail);

            // Show success message dialog
            if (mounted) {
              SuccessMessageDialog.show(
                context,
                "تم إرسال رسالة تأكيد إلى البريد الإلكتروني الجديد. يرجى التحقق من بريدك للتأكيد.",
                '/profile_page',
              );
            }

            // Wait for the user to re-authenticate and update their email
            await _waitForEmailVerification(user);

            // Update email in the users table
            await _updateEmailInUsersTable(user, newEmail);
          } catch (e) {
            //print("Error updating email: $e");

            // Handle other errors
            if (mounted) {
              setState(() {
                _emailErrorText = "حدث خطأ أثناء تحديث البريد الإلكتروني";
              });
            }
          }
        },
      );
    } catch (e) {
      // Handle other errors
      if (mounted) {
        setState(() {
          _emailErrorText = "حدث خطأ أثناء تحديث البريد الإلكتروني";
        });
      }
    }
  }
}

Future<void> _waitForEmailVerification(User? user) async {
  // Wait for the user to re-authenticate
  await user?.reload();
  user = FirebaseAuth.instance.currentUser;

  // Wait for email verification
  while (!(user?.emailVerified ?? false)) {
    await Future.delayed(const Duration(seconds: 120));
    await user?.reload();
    user = FirebaseAuth.instance.currentUser;
  }
}

Future<void> _updateEmailInUsersTable(User? user, String newEmail) async {
  try {
    // Wait for email verification before updating email in the users table
    await _waitForEmailVerification(user);

    // Update email in the users table
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .update({'email': newEmail});
  } catch (e) {
    _emailErrorText = "حدث خطأ أثناء تحديث البريد الإلكتروني";
    
  }
}


  void _goToProfilePage() {
    navigatorKey.currentState?.pushReplacementNamed('/profile_page');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [


            IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
             Navigator.pop(context);
            },
            padding: const EdgeInsets.only(right: 320.0),
           color: const Color(0xFF363436) // Set the color for the back arrow
           ),
              
              Container(
                padding: const EdgeInsets.all(16),
                child: Text(
                  " تحديث البريد الإلكتروني",
                  style: GoogleFonts.balooBhaijaan2(
                    textStyle: const TextStyle(
                      fontSize: 26,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'البريد الإلكتروني الجديد',
                          prefixIcon: Icon(
                            Icons.email,
                          ),
                        ),
                        onChanged: (value) {
                          _validateEmail(value);
                        },
                      ),
                    ),
                  ),
                ),
              ),
               Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 50),
                     child: Align(
                     alignment: Alignment.centerRight,
                     child: Text(
                    _emailErrorText ?? "",
                    style: TextStyle(color: Colors.red),
                       ),
                     ),
                    ),
              SizedBox(height: 20),
              Text(
                _confirmationMessage,
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: GestureDetector(
                  onTap: _changeEmail,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFF97B980),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Text(
                        ' تحديث البريد الإلكتروني',
                        style: GoogleFonts.balooBhaijaan2(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 270),


            ],
          ),

        ),
      ),
    );
  }
}

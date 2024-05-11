// ignore_for_file: use_key_in_widget_constructors, use_build_context_synchronously, empty_catches, prefer_const_constructors, unused_element

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taboua_app/auth.dart';
import 'package:taboua_app/messages/confirm.dart';
import 'package:taboua_app/messages/success.dart';

class PasswordChange extends StatefulWidget {
  const PasswordChange({Key? key});

  @override
  State<PasswordChange> createState() => _PasswordChangeState();
}

class _PasswordChangeState extends State<PasswordChange> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _passwordErrorText = "";
  String _confirmPasswordErrorText = "";
  String _confirmationMessage = "";

  void _validatePassword(String value) {
    if (value.isEmpty) {
      setState(() {
        _passwordErrorText = "كلمة المرور مطلوبة";
      });
    } else if (!_isPasswordValid(value)) {
      setState(() {
        _passwordErrorText =
            "كلمة المرور يجب أن تحتوي على 8 أحرف على الأقل مع حرف كبير وحرف صغير ورقم وحرف خاص";
      });
    } else {
      setState(() {
        _passwordErrorText = "";
      });
    }
  }

  bool _isPasswordValid(String password) {
    final RegExp passwordPattern = RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#\$%^&*_\-])[\w!@#\$%^&*_\-]{8,}$',
    );
    return passwordPattern.hasMatch(password);
  }

  void _validateConfirmPassword(String value) {
    if (value.isEmpty) {
      setState(() {
        _confirmPasswordErrorText = "يرجى تأكيد كلمة المرور";
      });
    } else if (value != _passwordController.text) {
      setState(() {
        _confirmPasswordErrorText = "كلمة المرور غير متطابقة";
      });
    } else {
      setState(() {
        _confirmPasswordErrorText = "";
      });
    }
  }

  void _showConfirmationDialog() {
  final newPassword = _passwordController.text;
  final newPassword2 = _confirmPasswordController.text;

  if (newPassword.isEmpty) {
    setState(() {
      _passwordErrorText = "كلمة المرور مطلوبة";
    });
  }

  if (newPassword2.isEmpty) {
    setState(() {
      _confirmPasswordErrorText = "تأكيد كلمة المرور مطلوب";
    });
  }
  else {
    ConfirmationDialog.show(
      context,
      "تأكيد تحديث كلمة المرور",
      "هل أنت متأكد أنك ترغب في تحديث كلمة المرور؟",
      _changePassword,
    );

  }
    
  }

  




 void _changePassword() async {
  final newPassword = _passwordController.text;

  

  if (_passwordErrorText.isEmpty && _confirmPasswordErrorText.isEmpty) {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      await user!.updatePassword(newPassword);
      SuccessMessageDialog.show(
        context,
        "تم تحديث كلمة المرور بنجاح!",
        '/profile_page', 
      );
      setState(() {
        _passwordErrorText = ""; // Clear error messages
        _confirmPasswordErrorText = ""; // Clear error messages
      });
    } catch (e) {
      
    }
  } else {
    // Clear confirmation message if there are validation errors
    setState(() {
      _confirmationMessage = "";
    });
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
            icon: Icon(Icons.arrow_back),
            onPressed: () {
             Navigator.pop(context);
            },
            padding: EdgeInsets.only(right: 320.0),
           color: Color(0xFF363436) 
           ),
              Container(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "تحديث كلمة المرور",
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
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'كلمة المرور الجديدة',
                          prefixIcon: Icon(
                            Icons.lock,
                          ),
                        ),
                        onChanged: (value) {
                          _validatePassword(value);
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
                    _passwordErrorText ?? "",
                    style: TextStyle(color: Colors.red),
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
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'تأكيد كلمة المرور الجديدة',
                          prefixIcon: Icon(
                            Icons.lock,
                          ),
                        ),
                        onChanged: (value) {
                          _validateConfirmPassword(value);
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
                    _confirmPasswordErrorText ?? "",
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
                  onTap: _showConfirmationDialog,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFF97B980),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Text(
                        'تحديث كلمة المرور',
                        style: GoogleFonts.balooBhaijaan2(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
             
               SizedBox(height: 190),
            ],
          ),
        ),
      ),
    );
  }
}

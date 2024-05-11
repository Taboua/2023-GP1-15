import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taboua_app/auth.dart';

class SignupDialog {
  static void showSignupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "سجل الآن",
                  style: GoogleFonts.balooBhaijaan2(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "سجل الآن لتتمكن من الاستفادة من هذه الخدمات",
                  style: GoogleFonts.balooBhaijaan2(
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "إلغاء",
                        style: GoogleFonts.balooBhaijaan2(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        
                         Navigator.of(context).pop(); // Close the dialog
                    navigatorKey.currentState?.pushReplacementNamed('/signup_screen'); // Close the dialog
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF97B980),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "تسجيل",
                        style: GoogleFonts.balooBhaijaan2(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

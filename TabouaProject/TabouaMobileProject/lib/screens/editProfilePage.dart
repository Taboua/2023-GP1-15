// ignore_for_file: file_names, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taboua_app/messages/confirm.dart';
import 'package:taboua_app/messages/success.dart';

class EditProfilePage extends StatefulWidget {
  final String currentFirstName;
  final String currentLastName;
  final String currentEmail;
  final String currentPhoneNumber;
  final String currentDateOfBirth;

  EditProfilePage({
    required this.currentFirstName,
    required this.currentLastName,
    required this.currentEmail,
    required this.currentPhoneNumber,
    required this.currentDateOfBirth,
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController phoneNumberController;
  late TextEditingController dateOfBirthController;
  

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current values
    firstNameController = TextEditingController(text: widget.currentFirstName);
    lastNameController = TextEditingController(text: widget.currentLastName);
    phoneNumberController = TextEditingController(text: widget.currentPhoneNumber);
    dateOfBirthController = TextEditingController(text: widget.currentDateOfBirth);
  }

  DateTime? _selectedDate;

  // Function to show the date picker
Future<void> _selectDate(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: _selectedDate ?? DateTime.now(),
    firstDate: DateTime(1900),
    lastDate: DateTime.now(),
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData.light().copyWith(
          primaryColor: Color(0xFF97B980), // Color of the header background
          hintColor: Colors.black, // Color of the selected date
          colorScheme: ColorScheme.light(
            primary: Color(0xFF97B980), // Color of the text in the header
            onPrimary: Colors.white, // Color of the text in the selected date
          ),
          buttonTheme: ButtonThemeData(
            textTheme: ButtonTextTheme.primary, // Style of the 'OK' button
          ),
        ),
        child: child!,
      );
    },
  );

  if (picked != null && picked != _selectedDate) {
    setState(() {
      _selectedDate = picked;
      dateOfBirthController.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      _validateDOB(dateOfBirthController.text);
    });
  }
}

  
  Future<bool> _showConfirmationDialog() async {
  // Check if any of the required fields is empty
  if (firstNameController.text.isEmpty ||
      lastNameController.text.isEmpty ||
      //dateOfBirthController.text.isEmpty ||
      phoneNumberController.text.isEmpty) {
    // Set error messages for the empty fields
    if (firstNameController.text.isEmpty) {
      setState(() {
        _firstNameErrorText = "الاسم الأول مطلوب";
      });
    }
    if (lastNameController.text.isEmpty) {
      setState(() {
        _lastNameErrorText = "الاسم الأخير مطلوب";
      });
    }
    /*if (dateOfBirthController.text.isEmpty) {
      setState(() {
        _dobErrorText = "تاريخ الميلاد مطلوب";
      });
    }*/
    if (phoneNumberController.text.isEmpty) {
      setState(() {
        _phoneNumberErrorText = "رقم الهاتف مطلوب";
      });
    }
    
    // Return false to indicate that the confirmation dialog should not appear
    return false;
  }

  // All required fields are filled, clear any previous error messages
  setState(() {
    _firstNameErrorText = null;
    _lastNameErrorText = null;
    _dobErrorText = null;
    _phoneNumberErrorText = null;
  });

  // Show the confirmation dialog
  Completer<bool> completer = Completer<bool>();
  ConfirmationDialog.show(
    context,
    "تأكيد المعومات الشخصية",
    "هل أنت متأكد من أنك تريد حفظ التغييرات؟",
    () {
      completer.complete(true);
    },
  );

  return completer.future;
}


 Future<void> _saveEditedInformation() async {

   /*if (dateOfBirthController.text.isEmpty) {
    setState(() {
      _dobErrorText = "تاريخ الميلاد مطلوب";
    });
  } */

    if (phoneNumberController.text.isEmpty) {
      setState(() {
        _phoneNumberErrorText = "رقم الهاتف مطلوب";
      });
    }

     if (firstNameController.text.isEmpty) {
      setState(() {
        _firstNameErrorText = "الاسم الأول مطلوب";
      });
    }

    if (lastNameController.text.isEmpty) {
      setState(() {
        _lastNameErrorText = "الاسم الأخير مطلوب";
      });
    }

  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {

    // Update user information in Firestore
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'firstName': firstNameController.text,
      'lastName': lastNameController.text,
      'phoneNumber': phoneNumberController.text,
      'DateOfBirth': dateOfBirthController.text,
    });

  }
}


  void _showSuccessMessage() {
    SuccessMessageDialog.show(
      context,
      "! تم تحديث المعلومات بنجاح ",
      '/profile_page', // Specify the destination page after success
    );
  }

  String? _firstNameErrorText;
  String? _lastNameErrorText;
  String? _phoneNumberErrorText;
  String? _dobErrorText;



    void _validateFirstName(String value) {
    if (value.isEmpty) {
      setState(() {
        _firstNameErrorText = "الاسم الأول مطلوب";
      });
    } else {
      setState(() {
        _firstNameErrorText = null;
      });
    }
  }

    void _validateLastName(String value) {
    if (value.isEmpty) {
      setState(() {
        _lastNameErrorText = "الاسم الأخير مطلوب";
      });
    } else {
      setState(() {
        _lastNameErrorText = null;
      });
    }
  }

   void _validatePhoneNumber(String value) {
    if (value.isEmpty) {
      setState(() {
        _phoneNumberErrorText = "رقم الهاتف مطلوب";
      });
    } else if (!RegExp(r'^\+9665\d{8}$').hasMatch(value)) {
      setState(() {
        _phoneNumberErrorText = "رقم الهاتف السعودي غير صحيح";
      });
    } else {
      setState(() {
        _phoneNumberErrorText = null;
      });
    }
  }
  
  /*void _validateDOB(String value) {
  // Define a regular expression for the expected date format
  RegExp datePattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  if (value.isEmpty) {
    setState(() {
      _dobErrorText = "تاريخ الميلاد مطلوب";
    });
  } else if (!datePattern.hasMatch(value)) {
    setState(() {
      _dobErrorText = "تنسيق تاريخ الميلاد غير صحيح ";
    });
  } else {
    setState(() {
      _dobErrorText = null;
    });
  }
}*/

void _validateDOB(String value) {
  // Define a regular expression for the expected date format
  RegExp datePattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  // If the value is empty, consider it valid since the field is optional
  if (value.isEmpty) {
    setState(() {
      _dobErrorText = null; // No error message needed for an empty, optional field
    });
    return; // Exit the function early
  }

  // Proceed with validation if the field is not empty
  if (!datePattern.hasMatch(value)) {
    setState(() {
      _dobErrorText = "تنسيق تاريخ الميلاد غير صحيح";
    });
  } else {
    // Convert the input value to a DateTime object
    DateTime dob = DateTime.parse(value);
    DateTime now = DateTime.now();
    // Calculate the age
    int age = now.year - dob.year;
    if (dob.month > now.month || (dob.month == now.month && dob.day > now.day)) {
      age--; // Adjust the age if the birthday has not occurred yet this year
    }

    if (age < 18) {
      // User is younger than 18
      setState(() {
        _dobErrorText = "يجب أن يكون عمرك 18 عامًا أو أكثر";
      });
    } else {
      // Age is 18 or older, or the DOB field is empty (and optional)
      setState(() {
        _dobErrorText = null; // Clear any previous error message
      });
    }
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
           color: Color(0xFF363436) 
           ),
           
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "تحديث المعلومات الشخصية",
                  style: GoogleFonts.balooBhaijaan2(
                    textStyle: const TextStyle(
                      fontSize: 26,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            // First Name
          Stack(
            alignment: AlignmentDirectional.topEnd,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextFormField(
                    controller: firstNameController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    onChanged: (value) {
                            _validateFirstName(value);
                          },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  "الاسم الأول",
                  style: TextStyle(
                    backgroundColor: Colors.grey[50],
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),

          Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 50),
                     child: Align(
                     alignment: Alignment.centerRight,
                     child: Text(
                    _firstNameErrorText ?? "",
                    style: TextStyle(color: Colors.red),
                       ),
                     ),
                    ),

          SizedBox(height: 10),



          // Last Name 
          Stack(
            alignment: AlignmentDirectional.topEnd,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextFormField(
                    controller: lastNameController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    onChanged: (value) {
                            _validateLastName(value);
                          },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  "الإسم الأخير",
                  style: TextStyle(
                    backgroundColor: Colors.grey[50],
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          
          Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 50),
                     child: Align(
                     alignment: Alignment.centerRight,
                     child: Text(
                    _lastNameErrorText ?? "",
                    style: TextStyle(color: Colors.red),
                       ),
                     ),
                    ),

          SizedBox(height: 10),


          // Phone Number
          Stack(
            alignment: AlignmentDirectional.topEnd,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                
                  child: TextFormField(
                    controller: phoneNumberController,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                     onChanged: (value) {
                              _validatePhoneNumber(value);
                            },
                  
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  " رقم الهاتف ",
                  style: TextStyle(
                    backgroundColor: Colors.grey[50],
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),

           Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 50),
                     child: Align(
                     alignment: Alignment.centerRight,
                     child: Text(
                    _phoneNumberErrorText ?? "",
                    style: TextStyle(color: Colors.red),
                       ),
                     ),
                    ),

          SizedBox(height: 10),

          // Date Of birth
          Stack(
            alignment: AlignmentDirectional.topEnd,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextFormField(
                    controller: dateOfBirthController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 40 , vertical: 16),
                    ),
                    onChanged: (value) {
                                    _validateDOB(value);
                                  },         
                  ),
                  
                ),
                
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12 , vertical: 17),
                child: GestureDetector(
              onTap: () => _selectDate(context),
              child: Icon(
                Icons.calendar_today,
                color: Colors.grey,
                size: 22,
              ),
            ),
                ),
            
              

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  " تاريخ الميلاد",
                  style: TextStyle(
                    backgroundColor: Colors.grey[50],
                    color: Colors.black54,
                  ),
                  
                ),
                
              ),
            ],
          ), 




          Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 50),
                     child: Align(
                     alignment: Alignment.centerRight,
                     child: Text(
                    _dobErrorText ?? "",
                    style: TextStyle(color: Colors.red),
                       ),
                     ),
                    ),



            SizedBox(height: 10),

            Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8 ),
            child: ElevatedButton(
              onPressed: () async {

                bool confirmed = await _showConfirmationDialog();
                if (confirmed) {
                  await _saveEditedInformation();
                  _showSuccessMessage();
                  //Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ), 
                backgroundColor: Color(0xFF97B980),
                padding: EdgeInsets.all(10),
                minimumSize: Size(800, 10),
              ),
              child: Text(
                " تحديث المعلومات الشخصية",
                style: GoogleFonts.balooBhaijaan2(
                  textStyle: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 60),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/password_change');
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  //side: BorderSide(color: Colors.black54),
                ), 
                backgroundColor: const Color(0xFFE9E9E9),
                elevation: 0, 
                padding: EdgeInsets.all(10),
                minimumSize: Size(800, 10),
              ),
              child: Text(
                "تحديث كلمة المرور",
                style: GoogleFonts.balooBhaijaan2(
                  textStyle: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF363436),
                  ),
                ),
              ),
            ),
          ),

           SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/change_email');
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  
                ), 
                backgroundColor: const Color(0xFFE9E9E9),
                elevation: 0, 
                padding: EdgeInsets.all(10),
                minimumSize: Size(800, 10),
              ),
              child: Text(
                "تحديث البريد الإلكتروني",
                style: GoogleFonts.balooBhaijaan2(
                  textStyle: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF363436)
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


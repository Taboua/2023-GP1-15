

// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, use_build_context_synchronously, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();
   final _phoneNumberController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
      


  String? _emailErrorText;
  String? _passwordErrorText;
  String? _confirmPasswordErrorText;
  String? _firstNameErrorText;
  String? _lastNameErrorText;
  String? _signupErrorText;
  String? _dobErrorText;
  String? _phoneNumberErrorText;
  DateTime? _selectedDate;

  void _validateEmail(String value) {
    if (value.isEmpty) {
      setState(() {
        _emailErrorText = "البريد الإلكتروني مطلوب";
      });
    } else if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$').hasMatch(value)) {
      setState(() {
        _emailErrorText = "البريد الإلكتروني غير صحيح";
      });
    } else {
      setState(() {
        _emailErrorText = null;
      });
    }
  }

  void _validatePassword(String value) {
    
    if (value.isEmpty) {
      setState(() {
        _passwordErrorText = "كلمة السر مطلوبة";
      });
      return;
    }
    final RegExp passwordRegex = RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#\$%^&*_\-])[\w!@#\$%^&*_\-]{8,}$',
    );

    if (!passwordRegex.hasMatch(value)) {
      setState(() {
        _passwordErrorText = "كلمة السر يجب أن تحتوي على 8 أحرف على الأقل، حرف كبير و حرف صغير، رقم، رمز";
      });
    } else {
      setState(() {
        _passwordErrorText = null;
      });
    }
  }

  void _validateConfirmPassword(String value) {
    final password = _passwordController.text;
    if (value.isEmpty) {
      setState(() {
        _confirmPasswordErrorText = "يجب تأكيد كلمة السر";
      });
    } else if (value != password) {
      setState(() {
        _confirmPasswordErrorText = "كلمة السر غير متطابقة";
      });
    } else {
      setState(() {
        _confirmPasswordErrorText = null;
      });
    }
  }

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
  
/*void _validateDOB(String value) {
  // Define a regular expression for the expected date format
  RegExp datePattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  if (value.isEmpty) {
    return;
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



  void _validatePhoneNumber(String value) {
    String phoneNumber = '+966 $value';

    if (value.isEmpty) {
      setState(() {
        _phoneNumberErrorText = "رقم الهاتف مطلوب";
      });
    } else if (!RegExp(r'^\+966 5\d{8}$').hasMatch(phoneNumber)) {
      setState(() {
        _phoneNumberErrorText = "رقم الهاتف غير صحيح";
      });
    } else {
      setState(() {
        _phoneNumberErrorText = null;
      });
    }
  }
  
Future<void> _selectDate(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: _selectedDate ?? DateTime.now(),
    firstDate: DateTime(1900),
    lastDate: DateTime.now(),
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData.light().copyWith(
          primaryColor: Color(0xFF97B980), 
          hintColor: Colors.black, 
          colorScheme: ColorScheme.light(
            primary: Color(0xFF97B980), 
            onPrimary: Colors.white, 
          ),
          buttonTheme: ButtonThemeData(
            textTheme: ButtonTextTheme.primary, 
          ),
        ),
        child: child!,
      );
    },
  );

  if (picked != null && picked != _selectedDate) {
    setState(() {
      _selectedDate = picked;
      _dobController.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      _validateDOB(_dobController.text);
    });
  }

}




Future signup() async {
  if (_formKey.currentState!.validate()) {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final phoneNumber = _phoneNumberController.text.trim();
    final dateOfBirth = _dobController.text.trim();

    String phoneNumber1 = '+966 $phoneNumber';

    if (phoneNumber.isEmpty) {
      setState(() {
        _phoneNumberErrorText = "رقم الهاتف مطلوب";
      });
    }

    if (email.isEmpty) {
      setState(() {
        _emailErrorText = "البريد الإلكتروني مطلوب";
      });
    }

     if (password.isEmpty) {
      setState(() {
        _passwordErrorText = "كلمة السر مطلوبة";
      });
    }

    if (firstName.isEmpty) {
      setState(() {
        _firstNameErrorText = "الاسم الأول مطلوب";
      });
    }

    if (lastName.isEmpty) {
      setState(() {
        _lastNameErrorText = "الاسم الأخير مطلوب";
      });
    }

    if (confirmPassword.isEmpty) {
      setState(() {
        _confirmPasswordErrorText = "يجب تأكيد كلمة السر";
      });
    } 

    try {
      // Check if the email is already in use
      final checkEmailExists =
          await _auth.fetchSignInMethodsForEmail(email);
      if (checkEmailExists.isNotEmpty) {
        setState(() {
          _signupErrorText = "البريد الإلكتروني مستخدم بالفعل";
        });
        return;
      }

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create a user in the "users" collection
      await usersCollection.doc(userCredential.user!.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': userCredential.user!.email,
        'userId': userCredential.user!.uid,
        'phoneNumber' : phoneNumber1,
        'DateOfBirth' : dateOfBirth
      });

      

      User? user = userCredential.user;

      if (user != null) {
        // ignore: unused_local_variable
        String userId = user.uid;
      }

      Navigator.pushNamed(context, '/home_screen');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        setState(() {
          _signupErrorText = "البريد الإلكتروني مستخدم بالفعل";
        });
      }
      
    } catch (e) {
      print('Error during registration: $e');
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  //SizedBox(height: 10),
                  Image.asset(
                    'images/logo.png',
                    height: 160,
                  ), 

                  //SizedBox(height: 12),
                  Text(
                    '! أنشئ حسابك الآن',
                    style: GoogleFonts.balooBhaijaan2(
                      fontSize: 26,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 40),
                  
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
                          child: TextFormField(
                            controller: _firstNameController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'الاسم الأول',
                              prefixIcon: Icon(
                                Icons.person,
                              ),
                            ),
                            onChanged: (value) {
                            _validateFirstName(value);
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
                    _firstNameErrorText ?? "",
                    style: TextStyle(color: Colors.red),
                       ),
                     ),
                    ),



                  
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
                          child: TextFormField(
                            controller: _lastNameController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'الاسم الأخير',
                              prefixIcon: Icon(
                                Icons.person,
                              ),
                            ),
                            onChanged: (value) {
                            _validateLastName(value);
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
                    _lastNameErrorText ?? "",
                    style: TextStyle(color: Colors.red),
                       ),
                     ),
                    ),
                 

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
                          child: TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'البريد الإلكتروني',
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
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'كلمة السر',
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
                          child: TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'تأكيد كلمة السر',
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
                  

                  // ... (DOB TextFormField)
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
                          child: Row(
                            children: [
                              // Calendar Icon
                              GestureDetector(
                                onTap: () => _selectDate(context),
                                child: Icon(
                                  Icons.calendar_today,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: _dobController,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'تاريخ الميلاد yyyy-mm-dd (اختياري)',
                                  ),
                                  onChanged: (value) {
                                    _validateDOB(value);
                                  },
                                ),
                              ),
                            ],
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
                    _dobErrorText ?? "",
                    style: TextStyle(color: Colors.red),
                       ),
                     ),
                    ),

                  // ... (PhoneNumber TextFormField)

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
                          child: TextFormField(
                            controller: _phoneNumberController,
                            //initialValue: '+966 ', 
                            
                            //flagsButtonPadding: const EdgeInsets.only(right: 120),
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.phone,
                              ),
                              border: InputBorder.none,

                              hintText: ' رقم الجوال ' ,
                              
                              suffix: Padding(
                             padding: const EdgeInsets.symmetric(horizontal: 30), // Adjust padding as needed
                              child: Text('966+'),
                            ),
                             
                            ),
                            onChanged: (value) {
                               //String phoneNumber = '+966 $value';
                               //print(phoneNumber);
                              _validatePhoneNumber(value);
                              },

                            //initialValue: '+966 ',
                            textAlign: TextAlign.start,
                            
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
                    _phoneNumberErrorText ?? "",
                    style: TextStyle(color: Colors.red),
                       ),
                     ),
                    ),

                  
                  
                  Text(
                    _signupErrorText ?? "",
                    style: TextStyle(color: Colors.red),
                  ),

                  

                  SizedBox(height: 7),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: GestureDetector(
                      onTap: signup,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Color(0xFF97B980),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: Text(
                            ' إنشاء حساب',
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login_screen');
                        },
                        child: Text(
                          'سجل دخولك الآن',
                          style: GoogleFonts.balooBhaijaan2(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      Text(
                        'هل أنت عضو بالفعل؟',
                        style: GoogleFonts.balooBhaijaan2(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Services/wrong_prediction_database.dart';
import '../messages/infoMessage.dart';
import 'bottom_bar.dart';

enum wasteType {
  metal('معدن'),
  paper('ورق'),
  fabric('أقمشة'),
  cardboard('كرتون'),
  glass('زجاج'),
  plastic('بلاستيك'),
  eletronic('إلكترونيات') ,
  nonRecyclable('نفايات لا يعاد تدويرها'),
  other('أخرى');

  const wasteType(this.label);
  final String label;
}
class user_prediction extends StatefulWidget {
  File image;
  String wrongType;
  user_prediction({ super.key ,required this.image , required this.wrongType});

  @override
  State<user_prediction> createState() => _user_predictionState();
}

class _user_predictionState extends State<user_prediction> {
  final TextEditingController wsteController = TextEditingController();
  wasteType? selectedType;
  String? errorMessage;
  wrong_prediction_database object = new wrong_prediction_database(); // object of wrong_prediction_database class to save data to firebase
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isOtherSelected = false; 
  String otherWasteType= '';

  // function to store image and correct waste type to firebase
  void reclassifiyWasteType(String correctType){
    //show message info
    InfoMessageDialog.show(
    context, 
    "شكرا" , 
    "شكرا لمساعدتك لفريق تَبوأ لتحسين من جودة الذكاء الاصطناعي. سوف يتم إرسال هذه الصورة للفريق",
    '/home_screen',
   );
   
 // add image of wrong prediction to firebase storage
  object.uploadFile(widget.image ,correctType , widget.wrongType , otherWasteType!);

  }


   Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
    color: Colors.black, //change your color here
  ),
      backgroundColor: Colors.white,
      title: Text('نوع النفايات',
      style: GoogleFonts.balooBhaijaan2(
        color: Colors.black,
        fontSize: 26,
      ),
      ),
      ),
              
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(55),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              
              children: [
                 Text(
                  "لتحسين جودة تَبوأ الذكاء الاصطناعي ، ساعد الفريق في اختيار النوع الصحيح للنفايات",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.balooBhaijaan2(fontSize: 18
                  
                  ),
                ),
                SizedBox(height: 26),
      
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                   borderRadius: BorderRadius.circular(5.0),
      
                  ),
                  child: Image.file(
                    widget.image,
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 26),
                
                Padding(
                  padding: const EdgeInsets.only(left:19 ),
      
                  child: Column(
                      children: <Widget>[
                        // Dropdown menu for color
                    if(selectedType!=null)
                         Row(
                         mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                          Text(
                            ' النوع الصحيح ( ${selectedType?.label} )' ,
                            style: GoogleFonts.balooBhaijaan2(fontSize: 16),
                            ),
                           Padding(
                             padding: const EdgeInsets.symmetric(horizontal: 5),
                        
                          )
                         ],
                        )
                    else
                       const Text('الرجاء اختيار نوع النفايات الصحيح',
                       style: TextStyle(fontSize: 16 , fontFamily: 'BalooBhaijaan2'),
                       ),
                  
                   const SizedBox(height: 20),
      
                        /////Dropdown menu of waste type 
                        
                        Directionality(
                          textDirection: TextDirection.rtl,
                            child: DropdownMenu<wasteType>(
                              controller: wsteController,
                              requestFocusOnTap: false,
                              label: const Text('نوع النفايات'),
                              onSelected: (wasteType?type) {
                                setState(() {
                                  selectedType = type; // to update selected waste type
                                  errorMessage = null; // to update error message
                                 isOtherSelected = type == wasteType.other;

                                });
                              },
                              dropdownMenuEntries: wasteType.values
                                  .map<DropdownMenuEntry<wasteType>>(
                                (wasteType color) {
                                  return DropdownMenuEntry<wasteType>(
                                    value: color, // font color
                                    label: color.label, // waste type
                                    style: MenuItemButton.styleFrom(
                                     foregroundColor: Colors.black,
                                                                   
                                    ),
                                  );
                                  
                                },
                              ).toList(),
                                menuHeight: 200, // height of dropdown menu list
                               
                            ),
                        ),
                        
                        const SizedBox(height: 10),

                        if (isOtherSelected) //  show text input when "other" is selected
      Form(
        key: _formKey ,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 50),
          child: Directionality(
              textDirection: TextDirection.rtl,
              child: TextFormField(
                textAlign: TextAlign.right,
                maxLines: 1,
                maxLength: 15,
                decoration: InputDecoration(
                  labelText: "نوع النفايات",
                  labelStyle: TextStyle(color: Color(0xff07512d)),
            
                  hintText: "نوع النفايات",
                  alignLabelWithHint: true,
                  floatingLabelAlignment: FloatingLabelAlignment.start,
                  
                  focusedBorder: UnderlineInputBorder(
                   borderSide: BorderSide(color: _formKey.currentState?.validate() == false ? Colors.red : Color(0xff07512d)),
  
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    otherWasteType = value;
                  });
                },
                validator: (complaintSubject) {
                  if (otherWasteType == null || otherWasteType!.isEmpty || otherWasteType!.trim().isEmpty) {
                    return 'يرجى إدخال نوع النفايات';
                  }
                return null;
                },
              ),
            ),
        ),
      ),              
     SizedBox(height: 20),
                      
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
             const SizedBox(height: 20),
      
             ElevatedButton(
          
          onPressed: () {
    if (selectedType == null) {
      setState(() {
        errorMessage = 'الرجاء اختيار نوع النفايات';
      });
    } else if (selectedType!.label == wasteType.other.label && (otherWasteType == null || otherWasteType!.isEmpty)) {
      // it will show error message of form fileds 
      setState(() {
        errorMessage = 'الرجاء كتابة نوع النفايات';
      });

    } else {
      // Call function when the user has selected a waste type or filled out the text input
      reclassifiyWasteType(selectedType!.label);
    }
  },
  
             style: ElevatedButton.styleFrom(
             shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(18),
            ),
              backgroundColor: Color(0xFF97B980),
             padding: EdgeInsets.all(10),
             minimumSize: Size(250, 10),
             elevation: 0,
            ),
            child: Text(
            "إرسال" ,
            style: GoogleFonts.balooBhaijaan2(
            textStyle: const TextStyle(
            fontSize: 18,
            color: Colors.white,
             ),
           ),
          ),
        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
            bottomNavigationBar: BottomBar(),

    );
  }
  



}

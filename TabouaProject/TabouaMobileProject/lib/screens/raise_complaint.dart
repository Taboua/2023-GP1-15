// ignore_for_file: prefer_const_constructors, camel_case_types, avoid_print, non_constant_identifier_names, sized_box_for_whitespace, unnecessary_null_comparison, must_be_immutable

import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'hide TextDirection;
import 'package:permission_handler/permission_handler.dart';
import 'package:taboua_app/Services/complaints_database.dart';
import 'package:taboua_app/screens/change_location.dart';
import '../Services/address_request.dart';
import '../messages/success.dart';

enum complaintsType {
  binLocation('موقع الحاوية'),
  binCleanliness('نظافة الحاوية'),
  binUnloading('وقت تفريغ الحاوية'),
  binFull('حاوية ممتلئة'),
  hazardouswaste('مخلفات خطرة'),
  discardedWaste('مخلفات مهملة'),
  other('أخرى');

  const complaintsType(this.label);
  final String label;
}
class raise_complaint extends StatefulWidget {
Position? selectedLocation; // new location the user selected
String? userId;
raise_complaint({super.key ,required this.selectedLocation , required this.userId});

  @override
  State<raise_complaint> createState() => _raise_complaintState();
}



class _raise_complaintState extends State<raise_complaint> {
Position? _currentLocation; // user current location
String? address; // local address for the user
bool isLoading = true; //to track loading featch user current address
bool _imageLoding = false;
final TextEditingController complaintsController = TextEditingController();
complaintsType? selectedType; // selected complaints type by user
List<File> images = [];
List<String> imaUrls = [];
String? errorComplaintType ;
String? errorComplaintDescription;
String? complaintAdditionalDetails;
String? errorComplaintSubject;
bool validated = false;
bool isOtherSelected = false;
String? complaintSubject;
final _formKey = GlobalKey<FormState>();

 
@override
void initState() {
super.initState();
_getLocation();
}
//get user current location
Future<void> _getLocation() async {
final status = await Permission.location.request();
if (status.isGranted) {
try {
final position = await Geolocator.getCurrentPosition(
desiredAccuracy: LocationAccuracy.bestForNavigation,
);

setState(() {
_currentLocation = position;
if(widget.selectedLocation !=null){
// get user local address by featching his Lat and Lon if user select new location
user_address(context, LatLng(widget.selectedLocation!.latitude, widget.selectedLocation!.longitude));
}
else{
// get user local address by featching his  current Lat and Lon if
user_address(context, LatLng(_currentLocation!.latitude, _currentLocation!.longitude));

}
});

} catch (e) {
print('Error getting location: $e');
}

} else {
print('Location permission not granted');
}

}
// Fetach user local address by using Google API
Future<void> user_address (BuildContext context , LatLng position) async {
String current_address = await addressRequest.searchCoordinateAddress(position, context); // get address from address_request class
setState(() {
  address = current_address;
  isLoading = false;
});
}

// Dialog the will shown when user click on ADD attchments button
 void _showAttachmentSheet(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Padding(
          padding: EdgeInsets.only(bottom: 0 , top: 0),
          child: Text(
                'إرفاق الصور',
                style: GoogleFonts.balooBhaijaan2(
                fontSize: 16,
                ),
                ),
        ),
        message: Padding(
          padding: EdgeInsets.only(top: 0 ,),
          child: Text(
                'يمكنك إضافة ثلاثة صور كحد أقصى',
                style: GoogleFonts.balooBhaijaan2(
                fontSize: 14,
                ),
                ),
        ),
              
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
           // isDefaultAction: true,
            onPressed: () {
              _pickImage(ImageSource.gallery);
            },
            child: Text(
              'اختيار من مكتبة الصور',
              style: GoogleFonts.balooBhaijaan2(
               color: Colors.blue,
              ),
              )
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              _pickImage(ImageSource.camera);
            },
            child: Text(
              'التقاط صورة',
              style: GoogleFonts.balooBhaijaan2(
               color: Colors.blue,
              ),
              ),
          ),
         
        ],
      ),
    );
  }

  // function to pick images from user deivce either by camera or aceess image gallery
  Future<void> _pickImage(ImageSource source) async {
  final pickedFile = await ImagePicker().pickImage(
    source: source,
    maxWidth: 480, //maximum width for the image
    maxHeight: 480, // maximum height for the image
    imageQuality: 85, //  image quality
    preferredCameraDevice: CameraDevice.rear, 
  );

  if (pickedFile != null) {
     File image = File(pickedFile.path); // convert selected image to File
      setState(() {
        images.add(image);
      });
    }
  }

// the function will delete image when user calick on cancle button
 void _deleteImage(int index) {
    setState(() {
      images.removeAt(index);
    });
  }

// function will validate user inputs
void _validateComplaint() {
  if ( selectedType == null || selectedType!.label == null) {
    setState(() {
      errorComplaintType = "يرجى اختيار نوع المشكلة";
    });
  }
  else{

setState(() {
     errorComplaintType = null;
    });
  }
  if (complaintAdditionalDetails ==null || complaintAdditionalDetails == null || complaintAdditionalDetails!.trim().isEmpty) {
    setState(() {
    errorComplaintDescription = "يرجى إدخال تفاصيل المشكلة";
    validated = false;
   });
  }
  else{
    setState(() {
   errorComplaintDescription = null;

   });

  }
  
  if(errorComplaintType==null && selectedType!.label != "أخرى" ){
    if(errorComplaintDescription==null ){
      setState(() {
   validated = true;
      
    });
    }
  
  }
  else if (errorComplaintDescription==null && errorComplaintType==null && _formKey.currentState?.validate() == true){
     setState(() {
   validated = true;
    });
  }
  }

// the function will call when user click on image will appear the image on dialog
void _showImageDialog(File imageFile) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: Container(
          width: 300,
          height: 300,
          child: Stack(
            children: [
              Image.file(
                imageFile,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Icon(
                    Icons.cancel_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}


 
//Generate random complaint number
int generateUniqueNumber() {
final random = Random();
return random.nextInt(10000); // Generates a random number between 0 and 9999
}
// genrate unique complaintNo
String generateComplaintNumber() {
// Get the current date and time
final now = DateTime.now();
final date = DateFormat('yyMMdd');
// Format the current date as a string
final formattedDate = date.format(now);
// Generate a unique 4-digit number
final uniqueNumber = generateUniqueNumber().toString().padLeft(4, '0');
// Combine the formatted date with the unique number
final complaintNumber = formattedDate + uniqueNumber;
return complaintNumber;
}

//Function to add New complaint to firebase
void addComplaint() async {
  _validateComplaint();

  if(validated == true){
    setState(() {
      _imageLoding = true;
    });

 // Function to generate a complaint number
final complaintNo = generateComplaintNumber();
// Create instnace of complaints_database class
complaints_database complaintDB = complaints_database();
imaUrls =await complaintDB.uploadFiles(images);

// complaint data
final complaintData = {
  'location': GeoPoint(
  widget.selectedLocation != null
      ? widget.selectedLocation!.latitude
      : _currentLocation!.latitude,
  widget.selectedLocation != null
      ? widget.selectedLocation!.longitude
      : _currentLocation!.longitude,
),

'complaintNo': complaintNo,
'complaintDate': Timestamp.fromDate(DateTime.now()),
'complainerId': widget.userId, // user ID
'status': 'جديد', 
'localArea': address,
'complaintType':selectedType!.label,
'description':complaintAdditionalDetails,
};
if (imaUrls.isNotEmpty) {
    complaintData['ImagesOfUserComplaints'] = imaUrls;
  }
  if (complaintSubject != null) {
    complaintData['complaintSubject'] = complaintSubject;
  }
  

complaintDB.add(complaintData); // add to firebase

 if (mounted) {
          SuccessMessageDialog.show(
            context,
            "تم رفع البلاغ بنجاح",
            '/view_complaints',
          );
        }
  }
  else{
     setState(() {
      _imageLoding = false;
    });
    return;
   
  }

}

  
  @override
  Widget build(BuildContext context) {
  return Scaffold(
  appBar: AppBar(
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
    backgroundColor: Colors.white,
    title: Text(
      "بلاغ جديد",
      style: GoogleFonts.balooBhaijaan2(
        color: Colors.black,
        fontSize: 26,
      ),
    ),
  ),
  body: GestureDetector(
     onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
    child: SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20),
          Center(
            child: Container(
              //padding: const EdgeInsets.all(0),
              child: Column(    
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50),
                    child:Column(
                     crossAxisAlignment: CrossAxisAlignment.end, 
    
                      children:[ 
                        Padding(
                          padding: EdgeInsets.only(right: 0),
                          child: Text(
                          "موقع البلاغ",
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'BalooBhaijaan2',
                          ),
                                          ),
                        ),
                        SizedBox(height: 10,),
                        if(isLoading)
                           CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF97B980)),
                            )
                          else
                           Directionality(
                            textDirection: TextDirection.rtl,
                            child: Column(
                              children:[
                                 Text(
                                  "$address",
                                  style: GoogleFonts.balooBhaijaan2(
                                    textStyle: const TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ], 
                            ),
                          ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      
                     Position newLoction = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => 
                          
                          change_location(currentLocation: _currentLocation,complaintLocation : widget.selectedLocation != null? widget.selectedLocation : _currentLocation  , userId: widget.userId , address: address,),
                        ),
                      );
                      user_address(context, LatLng(newLoction.latitude, newLoction.longitude));
                      setState(() {
                        widget.selectedLocation = newLoction;
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 50),
                      child: Text(
                        "تغيير الموقع",
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'BalooBhaijaan2',
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                    Divider(
                      color: Color(0xFF97B980), 
                      thickness: 0.9,
                            ),    
                  SizedBox(height: 10),
       
           Column(
           crossAxisAlignment: CrossAxisAlignment.end,
           children: [
           Padding(
            padding: EdgeInsets.symmetric(horizontal: 50),
             child: Text(
                 'ما هي المشكلة؟',
                 style: GoogleFonts.balooBhaijaan2(
                 fontSize: 16,
                 ),
               ),
           ),
          SizedBox(height: 8),
        
        Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children:[ DropdownMenu<complaintsType>(
             width: 350,
              controller: complaintsController,
              requestFocusOnTap: false,
              label: const Text('اختر نوع المشكلة'),
              onSelected: (complaintsType? type) {
                setState(() {
                  selectedType = type;
                  errorComplaintType= null;
                  isOtherSelected = type == complaintsType.other;
                });
              },
              dropdownMenuEntries: complaintsType.values
                  .map<DropdownMenuEntry<complaintsType>>(
                (complaintsType type) {
                  return DropdownMenuEntry<complaintsType>(
                    value: type,
                    label: type.label,
                    
                    style: MenuItemButton.styleFrom(
                      foregroundColor: Colors.black,
                      
                    ),
                  );
                },
              ).toList(),
              menuHeight: 250,
            ),
      Padding(
         padding: const EdgeInsets.symmetric(horizontal: 50),
         child: Align(
               alignment: Alignment.centerRight,
               child: Text(
               errorComplaintType ?? "",
              style: TextStyle(color: Colors.red),
              ),
            ),
          ),      
            ],
          ),
          
        ),
        
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
                      labelText: "موضوع المشكلة",
                      labelStyle: TextStyle(color: Color(0xff07512d)),
                            
                      hintText: "موضوع المشكلة",
                      alignLabelWithHint: true,
                      floatingLabelAlignment: FloatingLabelAlignment.start,
                      
                      focusedBorder: UnderlineInputBorder(
                       borderSide: BorderSide(color: _formKey.currentState?.validate() == false ? Colors.red : Color(0xff07512d)),
                  
                      ),
                    ),
                    onChanged: (value) {
                      
                        complaintSubject = value;
                       _validateComplaint();
                      
                    },
                    validator: (complaintSubject) {
                      if (complaintSubject == null || complaintSubject.isEmpty || complaintSubject.trim().isEmpty) {
                        return 'يرجى إدخال موضوع المشكلة';
                      }
                    return null;
                    },
                  ),
                ),
              ),
          ),
                    
       SizedBox(height: 20),
    
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 50),
          child: Text(
            'تفاصيل إضافية',
            style: GoogleFonts.balooBhaijaan2(
            fontSize: 16,
            ),
          ),
        ),
        SizedBox(height: 8),
        
         
          Padding(
             padding: EdgeInsets.symmetric(horizontal: 38),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                width: 400,
          
            child: Column(
              children:[
               TextField(
              onChanged: (text) {
              setState(() {
            complaintAdditionalDetails = text;
            _validateComplaint();
              });
            },
              decoration: InputDecoration(
              labelText:'أخبرنا أكثر عن المشكلة',
              border: OutlineInputBorder(),
              ),
               keyboardType: TextInputType.multiline,
               maxLines: 5, 
              maxLength: 300,
         
                ),
            
            Padding(
           padding: const EdgeInsets.only(top: 0 , right: 10),
           child: Align(
                   alignment: Alignment.centerRight,
                   child: Text(
                   errorComplaintDescription??'',
                  style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
              ],
            ),
              ),
            ),
          ),
        
    
          Padding(
           padding: EdgeInsets.symmetric(horizontal: 50 ,vertical: 16),
    
            child: Text(
            'هل لديك ما تريد إضافته؟',
            style: GoogleFonts.balooBhaijaan2(
            fontSize: 16,
            ),
              ),
          ),
        SizedBox(height: 8),
        
        if(images.length<3)
          Padding(
           padding: EdgeInsets.symmetric(horizontal: 50),
    
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: GestureDetector(
                onTap: () {
                
                _showAttachmentSheet(context);
                } ,
                child: Icon(
                  Icons.add_circle,
                  size: 40,
                  color: Color(0xFF97B980),
                  
                  
                  ),
              ),
            ),
          ),
        
                   Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50),
                     child: Directionality(
                       textDirection: TextDirection.rtl,
                         child: Container(
                          width: 350,
                           child: Row(
                            children: [
                              for (int i = 0; i < images.length; i++)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                       _showImageDialog(images[i]);
    
                                    },
                                    child: Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        Image.file(
                                          images[i],
                                          width: 60, 
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                        _deleteImage(i);
                                         },
                                          child: Icon(
                                            Icons.cancel_rounded, 
                                            color: Colors.red,
                                            
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                           ),
                         ),
                       ),
                   ),
               
               SizedBox(height: 70),
                   Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50),
                     child: ElevatedButton(
                               
                                onPressed: _imageLoding?null : addComplaint,
                      style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ), 
                      backgroundColor:_imageLoding? Colors.grey :
                       Color(0xFF07512D),
                      padding: EdgeInsets.all(10),
                      minimumSize: Size(350, 10),
                                 ),
                       child: _imageLoding?
                       CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ): 
                       Text(
                      "رفع البلاغ",
                      style: GoogleFonts.balooBhaijaan2(
                        textStyle: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                                 ),
                               ),
  
                   ),
  
              
      ],
    ),
    
    
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  ),
);

  }
 
}


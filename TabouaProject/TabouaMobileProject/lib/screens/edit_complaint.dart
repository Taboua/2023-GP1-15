//import 'dart:convert';
// ignore_for_file: must_be_immutable, unnecessary_null_comparison, prefer_const_constructors, sized_box_for_whitespace, prefer_if_null_operators, non_constant_identifier_names, camel_case_types, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taboua_app/Services/complaints_database.dart';
import 'package:taboua_app/models/complaints.dart';
import 'package:taboua_app/screens/edit_complaint_location.dart';
import 'dart:io';
import '../Services/address_request.dart';
import 'package:transparent_image/transparent_image.dart';
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
class edit_complaint extends StatefulWidget {
  complaints complaint;
  String userId;
  LatLng?updatedLocation;
  edit_complaint({required this.userId,required this.complaint,super.key ,required this.updatedLocation });

  @override
  State<edit_complaint> createState() => _edit_complaintState();
}

class _edit_complaintState extends State<edit_complaint> {
final TextEditingController complaintsController = TextEditingController();
final TextEditingController complaintsDescriptionController = TextEditingController();

complaints_database complaint = complaints_database();
complaintsType? selectedType; // selected complaints type by user
String?errorComplaintType;
String? complaintAdditionalDetails;
List<File> images = [];
List<String> imaUrls = [];
List<String> selectedImgUrls = [];
String? address ;
String?errorComplaintDescription;
bool? validated;
String? complaintSubject;
final _formKey = GlobalKey<FormState>();
@override
void initState() {
  super.initState();
  selectedType = fromString(widget.complaint.complaintType);
    complaintsDescriptionController.text = widget.complaint.descrption!;
  complaintAdditionalDetails = widget.complaint.descrption ;
     address = widget.complaint.localArea;
    
    imaUrls = widget.complaint.imagesOfUserComplaints;
    _fetchImages();
    _buildImageList(imaUrls, selectedImgUrls);
   
  
}
 static complaintsType fromString(String? typeString) {
    switch (typeString) {
      case 'موقع الحاوية':
        return complaintsType.binLocation;
      case 'نظافة الحاوية':
        return complaintsType.binCleanliness;
      case 'وقت تفريغ الحاوية':
        return complaintsType.binUnloading;
      case 'حاوية ممتلئة':
        return complaintsType.binFull;
        case 'مخلفات خطرة':
        return complaintsType.hazardouswaste;
        case 'مخلفات مهملة':
        return complaintsType.discardedWaste;
      case 'أخرى':
        return complaintsType.other;
      default:
        return complaintsType.other; // Default value
    }
  }
  // function to pick images from user deivce either by camera or aceess image gallery
  Future<void> _pickImage(ImageSource source) async {
  final pickedFile = await ImagePicker().pickImage(
    source: source,
    maxWidth: 480, //maximum width for the image
    maxHeight: 480, // maximum height for the image
    imageQuality: 85, //  image quality
    preferredCameraDevice: CameraDevice.rear, // preferred camera device
  );

  if (pickedFile != null) {
     File image = File( pickedFile.path); // convert selected image to File
      if(mounted){
        setState(() {
       images.add(image);
      });

      }
     
     List<String> newSelectedImgUrls = await complaint.uploadFiles(images);
      if(mounted){
      setState(() {
     selectedImgUrls= newSelectedImgUrls;
      });
      }
      
    }
  }


void _deleteImage(int index, bool isSelectedImagesFromGallery) {
  setState(() {
    if (!isSelectedImagesFromGallery) {
      // Delete from selectedImages list
      if (index >= 0 && index < selectedImgUrls.length) {
        complaint.deleteComplaintImage(selectedImgUrls[index]);
        selectedImgUrls.removeAt(index);
      }
    } else {
      // Delete from imageUrls list
      if (index >= 0 && index < imaUrls.length) {
        imaUrls.removeAt(index);
      }
    }
  });
}

void _fetchImages() async {
  if (widget.complaint.complaintNo != null ) {
    // Fetch images based on complaintNo
    List<String> fetchedImages =
        await complaint.getComplaintImages(widget.complaint.complaintNo!);

    if (mounted) {
      setState(() {
        imaUrls = fetchedImages;
      });
    }
  } else {
    print('Warning: complaintNo is null or empty');
  }
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

  // format complaint Date 
  String _formatDate(Timestamp? date) {
    return date != null
        ? '${date.toDate().year}-${date.toDate().month}-${date.toDate().day}'
        : '';
  }

 Future<void> user_address (BuildContext context , LatLng position) async {
String current_address = await addressRequest.searchCoordinateAddress(position, context); // get address from address_request class
setState(() {
  address = current_address;
});
}
// function will validate user inputs
void _validateComplaint() {
  if (complaintsDescriptionController == null || complaintAdditionalDetails == null || complaintAdditionalDetails!.isEmpty || complaintAdditionalDetails!.trim().isEmpty) {
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
  if(selectedType != null && selectedType!.label != "أخرى" ) {
    if(errorComplaintDescription==null ){
     setState(() {
   validated = true;
    });
    }
    
  }
  if(errorComplaintDescription==null && _formKey.currentState?.validate() == true ){
    setState(() {
   validated = true;
    });
  }
  }
//Function to add New complaint to firebase
void updateComplaint() async {
  _validateComplaint();
setState(() {
   if(validated == true){
// Create instnace of complaints_database class
complaints_database complaintDB = complaints_database();

String? complaintId = widget.complaint.id;
// complaint data
final complaintData = {
  'location': GeoPoint(
  widget.updatedLocation!.latitude,
  widget.updatedLocation!.longitude
),

'complainerId': widget.userId, // user ID
'localArea': address,
'complaintType':selectedType!.label,
'description':complaintAdditionalDetails!= null? complaintAdditionalDetails : widget.complaint.descrption ,
};

if (selectedImgUrls!= null && selectedImgUrls.isNotEmpty ) {
    complaintData['ImagesOfUserComplaints'] = imaUrls + selectedImgUrls ;
  }
  else{
   complaintData['ImagesOfUserComplaints'] = imaUrls  ;
  }

  if(selectedType!.label == "أخرى"){
   complaintData['complaintSubject'] = complaintSubject  ;
  }

complaintDB.updateComplaint(complaintData , complaintId!); // add to firebase

 if (mounted) {
          SuccessMessageDialog.show(
            context,
            "تم حفظ تغييرات البلاغ بنجاح",
            '/view_complaints',
          );
        }
  }
});
}

  @override
  Widget build(BuildContext context) {
  double dropdownWidth = MediaQuery.of(context).size.width - 35;  // take the width of screen and the - 35

    return Scaffold(
      appBar: AppBar(
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
    backgroundColor: Colors.white,
    title: Text(
      "تفاصيل البلاغ",
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
     child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 17),
          child: ListView(
            children: [
              _buildAttribute('رقم البلاغ', widget.complaint.complaintNo),
              _buildAttribute('تاريخ البلاغ', _formatDate(widget.complaint.complaintDate)),
              _buildAttribute('حالة البلاغ', widget.complaint.status),
              _buildAttribute('نوع البلاغ',''),
              
            
     
        Directionality(
          textDirection: TextDirection.rtl,
            child: 
          Column(
          crossAxisAlignment: CrossAxisAlignment.start,
         children: [ 
              DropdownMenu<complaintsType>(
              width: dropdownWidth ,
                controller: complaintsController,
                requestFocusOnTap: false,
                label: Text('${widget.complaint.complaintType}'),
                onSelected: (complaintsType? type) {
                  setState(() {
                    selectedType = type;
                    errorComplaintType= null;
                  });
                },
                dropdownMenuEntries: complaintsType.values
                  .map<DropdownMenuEntry<complaintsType>>(
                    (complaintsType type) {
                      return DropdownMenuEntry<complaintsType>(
                        value: type,
                        label: type.label,
                        style: MenuItemButton.styleFrom(
                          foregroundColor: type == selectedType ? Color(0xFF97B980) : Colors.black,
                        fixedSize:Size.fromWidth(double.infinity),
                        ),
                      );
                    },
                  ).toList(),
                menuHeight: 340,
              ),   
    ],
   ),
   
            ),
      
   
     if (selectedType!.label == "أخرى") //  show text input when "other" is selected
      Form(
        key: _formKey ,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
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
                initialValue: widget.complaint.complaintSubject != "null" ? widget.complaint.complaintSubject : '' ,
                onChanged: (value) {
                  setState(() {
                    complaintSubject = value;
                  });
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
   
      _buildAttribute('وصف البلاغ',''),
       
     Column(
      children:[
      Directionality(
      textDirection: TextDirection.rtl,
      child: TextField(
        controller: complaintsDescriptionController,
        onChanged: (text) {
          setState(() {
            complaintAdditionalDetails = text ;
            _validateComplaint();
          });
        },
        decoration: InputDecoration(
          labelText: 'أخبرنا أكثر عن المشكلة',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.multiline,
        maxLines: 3,
        maxLength: 300,
      ),
     ),
      Padding(
       padding: const EdgeInsets.only(top: 0 , right: 10),
       child: Align(
               alignment: Alignment.centerRight,
               child: Text(
               errorComplaintDescription?? '',
              style: TextStyle(color: Colors.red),
              ),
            ),
          ),
      ],
     ),
   
   
         _buildAttribute('موقع البلاغ',address),
   
         Directionality(
          textDirection:TextDirection.rtl, 
          child:  GestureDetector(
                  onTap: () async {
                  LatLng newLocation = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => edit_complaint_location(userId: widget.userId, complaint: widget.complaint , address: address,),
                      ),
                    );
                    user_address(context, LatLng(newLocation.latitude, newLocation.longitude));
                    widget.updatedLocation = newLocation;
                  },
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
   
       SizedBox(height: 20,) ,
     if( ((imaUrls.length+selectedImgUrls.length)<3)) 
     Row(
     mainAxisAlignment: MainAxisAlignment.end,
     children: [
        Directionality(
          textDirection: TextDirection.rtl,
          child: GestureDetector(
            onTap: () {
              _showAttachmentSheet(context);
            },
            child: Icon(
              Icons.add_circle,
              size: 40,
              color: Color(0xFF97B980),
            ),
          ),
        ),
     ],
   ),
         if(widget.complaint.imagesOfUserComplaints !=null)
          _buildImageList(imaUrls , selectedImgUrls),
   
   
   SizedBox(height: 40,),
     ElevatedButton(
                onPressed: () {
                    updateComplaint();
                },
                
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ), 
                  backgroundColor: Color(0xFF07512D),
                  padding: EdgeInsets.all(10),
                  minimumSize: Size(100, 40),
                  elevation: 0,
                ),
                child: Text(
                  "حفظ التغييرات",
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
   ),

    );
  }
/// Widget to  style the complaint info 
  Widget _buildAttribute(String label, var value) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.balooBhaijaan2(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
  /// Widget to show image on dialog
void _showImageDialog(String imageUrl , bool isSelectedImagesFromGallery) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: Stack(
          children: [
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imageUrl ),

                  
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: Icon(
                  Icons.cancel,
                  size: 30,
                  
                  ),
                color: Colors.white,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
/// list of image
Widget _buildImageList(List<String> imageUrls, List<String> selectedImages) {
  if ((imageUrls != null && imageUrls.isNotEmpty) || (selectedImages != null && selectedImages.isNotEmpty)) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'المرفقات',
              style: GoogleFonts.balooBhaijaan2(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Container(
              height: 80,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // List of images from imageUrls
                  for (int index = 0; index < imageUrls.length; index++)
                    _buildImageItem(imageUrls[index], '', index , true),
                  SizedBox(width: 8), // Add spacing between image lists
                  // List of images from selectedImages
                  for (int index = 0; index < selectedImages.length; index++)
                    _buildImageItem('', selectedImages[index], index , false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  } else {
    return Container();
  }
}

Widget _buildImageItem(String imageUrl, String selectedImage, int index , bool isSelectedImagesFromGallery) {
  return GestureDetector(
    onTap: () {
            _showImageDialog(isSelectedImagesFromGallery ? imageUrl : selectedImage, isSelectedImagesFromGallery);

    },
    child: Container(
      width: 80,
      height: 80,
      child: Stack(
        children: [
          // Use imageUrl for image from imageUrls list
          if (imageUrl.isNotEmpty)
            FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: imageUrl,
            ),
          // Use selectedImage for image from selectedImages list
          if (selectedImage.isNotEmpty)
            FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: selectedImage,
            ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                _deleteImage(index , isSelectedImagesFromGallery);
              },
              child: Icon(
                Icons.cancel_rounded,
                color: Colors.red,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}



}
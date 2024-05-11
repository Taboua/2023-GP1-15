
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:taboua_app/api_service.dart';
import 'package:taboua_app/messages/infoMessage.dart';
import 'package:taboua_app/screens/bottom_bar.dart';
import 'package:taboua_app/screens/trash_waste_type.dart';
import 'package:taboua_app/screens/waste_prediction.dart';

class WasteTypeModel extends StatefulWidget {
  @override
  _WasteTypeModelState createState() => _WasteTypeModelState();
}

class _WasteTypeModelState extends State<WasteTypeModel> {
  File? _image;
  String? _wasteType;
  String? _probability; 
  bool _isLoading = false;



  Future<void> _pickImage(ImageSource source) async {
  final pickedFile = await ImagePicker().getImage(
    source: source,
    maxWidth: 480, // Set the maximum width for the image
    maxHeight: 480, // Set the maximum height for the image
    imageQuality: 85, // Set the image quality
    preferredCameraDevice: CameraDevice.rear, // Set the preferred camera device
  );

  if (pickedFile != null) {
    File? croppedImage = await _cropImage(File(pickedFile.path));

    if (croppedImage != null) {
      setState(() {
        _image = croppedImage;
        _wasteType = null;
      });
    }
  }
}




  Future<File?> _cropImage(File imageFile) async {
  File? croppedFile;

  final imageCropper = ImageCropper();

  final croppedResponse = await imageCropper.cropImage(
    sourcePath: imageFile.path,
    aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1), // Set a square aspect ratio
    cropStyle: CropStyle.rectangle,
  );

  if (croppedResponse != null) {
    croppedFile = File(croppedResponse.path!);
  }

  return croppedFile;
}


  Future<void> _classifyImage() async {
    if (_image == null) {

InfoMessageDialog.show(
  context,
  'تنبيه',
  'الرجاء اختيار صورة أولاً',
  "/wasteType_model"
);
      return;
    }

    setState(() {
    _isLoading = true; // Start loading
  });

Map<String, dynamic> classificationResult = await ApiService.classifyWaste(_image!);

 // Extract wasteType and probability
    String wasteType = classificationResult['wasteType'];
    String? probability = classificationResult['probability']; 

if (wasteType == 'none') {
  InfoMessageDialog.show(
    context,
    'يرجى المحاولة مرة أخرى',
    ' لم يتم العثور على كائنات في الصورة ',
    "/wasteType_model", 
  );
} else if (wasteType == 'error') {
  InfoMessageDialog.show(
    context,
    'خطأ',
    'حدثت مشكلة أثناء التصنيف. الرجاء المحاولة مرة أخرى.',
    "/wasteType_model", 
  );
  }else {

     Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => waste_predicition(image: _image!, type: wasteType! , probability: probability!,),
    ),
  );setState(() {
    _isLoading = false; // Stop loading
    _wasteType = wasteType;
  });

}


    setState(() {
      _wasteType = wasteType;
    });
  }



  Widget _loadingOverlay() {
  return _isLoading
      ? Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
          ),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        )
      : SizedBox.shrink(); // If not loading, don't show anything
}






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3F3F3),
      appBar: AppBar(
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
    backgroundColor: Color(0xFFF3F3F3),
    
    title: Text(
      'تصنيف النفايات',
      style: GoogleFonts.balooBhaijaan2(
        color: Colors.black,
        fontSize: 26,
      ),
    ),
  ),
   
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             
            Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(5.0)
              ),
              child: _image != null
                  ? Image.file(
                      _image!,
                      height: 350,
                      width: 350,
                      fit: BoxFit.cover,
                    )
                  : Center(
                      child: Text(
                        'لم يتم اختيار صورة',
                        style: GoogleFonts.balooBhaijaan2(fontSize: 18),
                      ),
                    ),
            ),


            SizedBox(height: 16),


            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
               ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.gallery),
                   style: ElevatedButton.styleFrom(
                   backgroundColor: Color(0xFF97B980),
                   padding: EdgeInsets.all(4.5), 
                   minimumSize: Size(120, 10), // Set the background color
                   shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(12.0), // Set the border radius
                  ),
                 ),
               child: Text(
                'اختيار صورة',
                 style: GoogleFonts.balooBhaijaan2(
                 fontSize: 18,
                 //fontWeight: FontWeight.bold,
                   ),
                    ), 
                      ),

            //SizedBox(width: 25.0),  

                 ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.camera),
                   style: ElevatedButton.styleFrom(
                   backgroundColor: Color(0xFF97B980),
                   padding: EdgeInsets.all(4.5), 
                   minimumSize: Size(120, 10),
                   shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(12.0), // Set the border radius
                  ),
                 ),
               child: Text(
                'التقاط صورة',
                 style: GoogleFonts.balooBhaijaan2(
                 fontSize: 18,
                 //fontWeight: FontWeight.bold,
                   ),
                    ),
                      ),

              ],
            ),

            
            SizedBox(height: 60),

           

                      ElevatedButton(
  onPressed: _isLoading ? null : _classifyImage, // Disable button when loading
  style: ElevatedButton.styleFrom(
    backgroundColor:_isLoading? Colors.grey :
     Color(0xff07512d),
    padding: EdgeInsets.all(6), 
    minimumSize: Size(250, 10), 
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
  ),
  child: _isLoading
    ? CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      )
    : Text(
        'تصنيف النفايات',
        style: GoogleFonts.balooBhaijaan2(
          fontSize: 18,
        ),
      ),
),


          // _loadingOverlay(), 
           
          ],
        ),
      ),
      bottomNavigationBar: BottomBar(),
    );
  }
}

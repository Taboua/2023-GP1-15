import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:taboua_app/models/wrong_prediction.dart';
import 'package:path/path.dart';

class wrong_prediction_database{

final CollectionReference wrongWasteType = FirebaseFirestore.instance.collection("wrongPredictionType");// refer to collection name in firebase

String userId = FirebaseAuth.instance.currentUser!.uid; // to save image pred with user id

// generate random number of image path
String generateRandomNumber(){
final now = DateTime.now();
final date = DateFormat('yyMMdd');
// Format the current date as a string
final formattedDate = date.format(now);

final random = Random();
final randomDigits = random.nextInt(10000);

final uniqueNumber = randomDigits.toString().padLeft(4, '0');
String finalNumber = formattedDate + uniqueNumber;
return finalNumber;

}

// add wrong image predcition to database
Future addWrongPrediction(String URL , String type , String correctType , String otherWasteType) async {
try{
final wasteData = {
"imageURL":URL,
"wrongType":type,
"correctType":correctType
};
  // Check if otherWasteType is not null and not empty
    if (otherWasteType != null && otherWasteType.isNotEmpty) {
      wasteData["otherWasteType"] = otherWasteType;
    }
    
await wrongWasteType.add(wasteData);
print("added");
  }catch(e){
    print("not added");
  }

}
// upload image to stoarge in firebase as link 
Future uploadFile(File image , String wrongType , String correctType , String otherWasteType) async {
  String randomWasteNumber = generateRandomNumber(); // to generate random number for image path
  final path = '${"waste-$userId-$randomWasteNumber"}';
    final destination = 'wrongPrediction/$path'; // name of folder in firebase storage called wrongPrediction
    try {
      final ref = FirebaseStorage.instance
          .ref(destination);
      await ref.putFile(image!); // to put file image on stoarge in firebase
      String newUrl = await ref.getDownloadURL(); // save image url 
      addWrongPrediction(newUrl , wrongType , correctType , otherWasteType!); // to add image and type to firebase
    } catch (e) {
      print('error occured to store image in firebase storge');
    }
  }





}
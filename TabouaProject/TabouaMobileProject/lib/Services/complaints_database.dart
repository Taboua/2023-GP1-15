import 'dart:math';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:taboua_app/models/complaints.dart';

class complaints_database{
String userId = FirebaseAuth.instance.currentUser!.uid; // to save image pred with user id

  final CollectionReference complaintsCollection =
  FirebaseFirestore.instance.collection("complaints");

 Stream<List<complaints>> getComplaints(String userId, String? selectedFilter , String? selectedComplaintType) {
    Query query = complaintsCollection
    .where('complainerId', isEqualTo: userId);

    if (selectedFilter != null && selectedFilter != 'الكل') {
      // If a specific status is selected, add a filter for that status
      query = query.where('status', isEqualTo: selectedFilter);
       
    }

     if (selectedComplaintType != null && selectedComplaintType != 'الكل') {
      // If a specific status is selected, add a filter for that status
      query = query.where('complaintType', isEqualTo: selectedComplaintType);
       
    }


    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((DocumentSnapshot document) {
        return complaints.fromJson(document);
      }).toList();
    });
  }
 Future<List<String>> getComplaintImages(String complaintNo) async {
    try {
      // Query the complaints collection based on complaintNo
      QuerySnapshot querySnapshot = await complaintsCollection
          .where('complaintNo', isEqualTo: complaintNo)
          .get();

      // Check if any documents are found
      if (querySnapshot.docs.isNotEmpty) {
        // Get the first document's data (assuming complaintNo is unique)
        Map<String, dynamic> complaintData = querySnapshot.docs.first.data() as Map<String, dynamic>;

        // Extract the ImagesOfUserComplaints field from the data
        List<String>? images = complaintData['ImagesOfUserComplaints']?.cast<String>();

        // Return the images list
        return images ?? [];
      } else {
        // No documents found with the specified complaintNo
        print('No documents found with complaintNo: $complaintNo');
        return [];
      }
    } catch (e) {
      // Handle any errors that occurred during the fetch
      print('Error fetching complaint images: $e');
      return [];
    }
  }
  Future<void> add(Map<String, dynamic> data) async {
    // Add a new document with a generated ID
    try{
    await complaintsCollection.add(data);

    }
    catch(e){
    print("Error adding complaint: $e");

    }
  }
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

// upload images to Firebase Storge
Future<List<String>> uploadFiles(List<File> images) async {
  List<String> imageUrls = [];

  for (File image in images) {
    String randomWasteNumber = generateRandomNumber();
    final path = '${"complaint-$userId-$randomWasteNumber"}';
    final destination = 'ImagesOfUserComplaints/$path';

    try {
      final ref = FirebaseStorage.instance.ref(destination);
      await ref.putFile(image);
      String newUrl = await ref.getDownloadURL();
      imageUrls.add(newUrl);
    } catch (e) {
      print('Error occurred while storing image in Firebase Storage');
    }
  }

  return imageUrls;
}


Future<void> deleteComplaint(complaints complaint) async {
  try {
    // Delete images from Firebase Storage
    for (String imageUrl in complaint.imagesOfUserComplaints ) {
      if (imageUrl != null && imageUrl.isNotEmpty) {
        // Create a reference to the image in Firebase Storage
        Reference photoRef = FirebaseStorage.instance.refFromURL(imageUrl);

        // Delete the image
        await photoRef.delete().then((value) {
        }).catchError((error) {
          print('Error deleting image: $error');
        });
      }
    }

    // Delete the complaint document from Firestore
    await complaintsCollection.doc(complaint.id).delete();
  } catch (e) {
    print("Error deleting complaint: $e");
  }
}

Future<void> deleteComplaintImage(String imageUrl) async {
  try {
    // Delete images from Firebase Storage
      if (imageUrl != null && imageUrl.isNotEmpty) {
        // Create a reference to the image in Firebase Storage
        Reference photoRef = FirebaseStorage.instance.refFromURL(imageUrl);

        // Delete the image
        await photoRef.delete().then((value) {
        }).catchError((error) {
          print('Error deleting image: $error');
        });
      }
    

    // Delete the complaint document from Firestore
  } catch (e) {
    print("Error deleting complaint image: $e");
  }
}

  Future<void> updateComplaint(Map<String, dynamic> data , String complintId) async {
    try {
      // Create a map with the updated data
      // Update the document with the new data
      await complaintsCollection.doc(complintId).update(data);
    } catch (e) {
      // Handle error (print or throw an exception)
      print("Error updating complaint: $e");
      throw e;
    }
  }


}
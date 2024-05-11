// ignore_for_file: file_names, camel_case_types, avoid_print, use_rethrow_when_possible

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taboua_app/models/garbage_bin_requests.dart';

class garbage_bin_requestDB {
  final CollectionReference garbageRequestColleaction =
  FirebaseFirestore.instance.collection("requestedGarbageBin");

  Stream<List<garbage_bin_requests>> getgarbage_bin_requests(String userId, String? selectedFilter) {
    Query query = garbageRequestColleaction
    .where('requesterId', isEqualTo: userId);
    //.orderBy('requestDate', descending: true)
     

    if (selectedFilter != null && selectedFilter != 'الكل') {
      // If a specific status is selected, add a filter for that status
      query = query.where('status', isEqualTo: selectedFilter);
       
    }

  
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((DocumentSnapshot document) {
        return garbage_bin_requests.fromJson(document);
      }).toList();
    });
  }


  Future<void> deleteGarbageBinRequest(garbage_bin_requests request) async {
    try {
      await garbageRequestColleaction.doc(request.id).delete();

    } catch (e) {
      // Handle error (print or throw an exception)
      print("Error deleting request: $e");
      throw e;
    }
  }

   Future<void> add(Map<String, dynamic> data) async {
    // Add a new document with a generated ID
    try{
   await garbageRequestColleaction.add(data);

    }
    catch(e){
            print("Error adding request: $e");

    }
  }

  Future<void> updateRequest(Map<String, dynamic> data , String complintId) async {
    try {
      // Create a map with the updated data
      // Update the document with the new data
      await garbageRequestColleaction.doc(complintId).update(data);
    } catch (e) {
      // Handle error (print or throw an exception)
      print("Error updating complaint: $e");
      throw e;
    }
  }

}
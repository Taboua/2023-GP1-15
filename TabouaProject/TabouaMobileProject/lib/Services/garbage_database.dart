// ignore_for_file: camel_case_types

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taboua_app/models/garbage_bin.dart';


class garbageDatabase{

//collection refrence 
final CollectionReference garbageColleaction = FirebaseFirestore.instance.collection("garbageBins");




Stream<List<Garbage_Bin>> getGarbageBin() {
    return garbageColleaction
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((document) => Garbage_Bin.fromJson(document.data() as Map<String, dynamic>))
        .toList());
  }

}
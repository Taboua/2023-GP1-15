// ignore_for_file: camel_case_types, non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

class complaints {
String? id;
String? complainerId;
String? complaintNo;
Timestamp? complaintDate;
String? descrption;
String?complaintType;
List<String> imagesOfUserComplaints;
List<String> ImagesOfStaffResponse;
String? localArea;
String? status;
GeoPoint? location;
Timestamp? responseDate;
String? staffResponse;
Timestamp? inprogressDate;
String? complaintSubject;

complaints({
required this.id,
required this.complainerId,
required this.complaintNo,
required this.complaintDate,
required this.descrption,
required this.complaintType,
required this.imagesOfUserComplaints,
required this.localArea,
required this.status,
required this.location,
required this.inprogressDate,
required this.staffResponse,
required this.ImagesOfStaffResponse,
required this.responseDate,
required this.complaintSubject,
});



factory complaints.fromJson(DocumentSnapshot document) {
    String id = document.id;
    Map<String, dynamic> parsedJSON = document.data() as Map<String, dynamic>;
    return complaints(
      id: id,
      complaintDate: parsedJSON['complaintDate'] as Timestamp?,
      complaintNo: parsedJSON['complaintNo'].toString(),
      complainerId: parsedJSON['complainerId'].toString(),
      status: parsedJSON['status'].toString(),
      descrption: parsedJSON['description'].toString(),
      complaintType: parsedJSON['complaintType'].toString(),
      imagesOfUserComplaints: List<String>.from(parsedJSON['ImagesOfUserComplaints']?? []),
      localArea: parsedJSON['localArea'].toString(),
      location: GeoPoint(
        parsedJSON['location'].latitude,
        parsedJSON['location'].longitude,
      ),
      responseDate: parsedJSON['responseDate'] as Timestamp?,
      staffResponse: parsedJSON['staffResponse'].toString(),
      ImagesOfStaffResponse: List<String>.from(parsedJSON['ImagesOfStaffResponse']?? []),
      inprogressDate: parsedJSON['inprogressDate'] as Timestamp?,
      complaintSubject:parsedJSON['complaintSubject'].toString(),

    );
  }

}
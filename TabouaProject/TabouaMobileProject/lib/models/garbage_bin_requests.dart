// ignore_for_file: file_names, implementation_imports, depend_on_referenced_packages

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';


class garbage_bin_requests {
  final String? id;
  final Timestamp? requestDate;
  final String? requestNo;
  final String? requesterId;
  final String? status;
  final GeoPoint? location;
  final Timestamp? responseDate;
  final String? staffComment;
  final Timestamp? inprogressDate;
  final String? requestReason;
  final String? garbageSize;
  final String? localArea;
  final String? newlocalArea;
  final GeoPoint? newlocation;
  final String? SelectedGarbageSize;

  garbage_bin_requests({
    this.id,
    this.requestDate,
    this.requestNo,
    this.requesterId,
    this.status,
    this.location,
    this.responseDate,
    this.staffComment,
    this.inprogressDate,
    this.requestReason,
    this.garbageSize,
    this.localArea,
    this.newlocalArea,
    this.newlocation,
    this.SelectedGarbageSize,
  });

  factory garbage_bin_requests.fromJson(DocumentSnapshot document) {
    String id = document.id;
    Map<String, dynamic> parsedJSON = document.data() as Map<String, dynamic>;

    return garbage_bin_requests(
      id: id,
      requestDate: parsedJSON['requestDate'] as Timestamp?,
      requestNo: parsedJSON['requestNo'].toString(),
      requesterId: parsedJSON['requesterId'].toString(),
      status: parsedJSON['status'].toString(),
      location: GeoPoint(
        parsedJSON['location'].latitude!,
        parsedJSON['location'].longitude!,
      ),
      responseDate: parsedJSON['responseDate'] as Timestamp?,
      staffComment: parsedJSON['staffComment']?.toString(),
      inprogressDate: parsedJSON['inprogressDate'] as Timestamp?,
      requestReason: parsedJSON['requestReason']?.toString(),
      garbageSize: parsedJSON['garbageSize']?.toString(),
      SelectedGarbageSize: parsedJSON['SelectedGarbageSize']?.toString(),

      localArea: parsedJSON['localArea'],
      newlocalArea: parsedJSON['newlocalArea'],
      newlocation: parsedJSON['newlocation'] != null
        ? GeoPoint(
            parsedJSON['newlocation'].latitude,
            parsedJSON['newlocation'].longitude,
          )
        : null,

    );
  }


  void updateRequest(LatLng? selectedLocation, String selectedSize, String text) {}
}
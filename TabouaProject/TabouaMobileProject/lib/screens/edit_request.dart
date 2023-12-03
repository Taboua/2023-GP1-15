// ignore_for_file: library_private_types_in_public_api, prefer_final_fields, use_build_context_synchronously, prefer_const_constructors, sized_box_for_whitespace, prefer_collection_literals, avoid_print

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taboua_app/Services/garbagebinRequestDB.dart';
import 'package:taboua_app/messages/confirm.dart';
import 'package:taboua_app/messages/success.dart';
import 'package:taboua_app/models/GarbageBinRequests.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EditRequestPage extends StatefulWidget {
  final GarbageBinRequests request;

  const EditRequestPage({Key? key, required this.request}) : super(key: key);

  @override
  _EditRequestPageState createState() => _EditRequestPageState();
}

class _EditRequestPageState extends State<EditRequestPage> {
  TextEditingController _reasonController = TextEditingController();
  String _selectedSize = 'حاوية صغيرة'; // Default size
  LatLng? selectedLocation;

  @override
  void initState() {
    super.initState();
    _reasonController.text = widget.request.requestReason ?? '';
    _selectedSize = widget.request.garbageSize ?? 'حاوية صغيرة';
    selectedLocation = widget.request.location != null
        ? LatLng(
            widget.request.location!.latitude,
            widget.request.location!.longitude,
          )
        : null;
  }

  // Function to handle marker drag
  void _onMarkerDragEnd(LatLng newPosition) {
    setState(() {
      selectedLocation = newPosition;
    });
  }

  void updateRequest(
    LatLng? selectedLocation,
    String selectedSize,
    String requestReason,
  ) async {
    // Assuming you have the ID available in the 'id' field
    try {
      await garbagebinRequestDB().updateRequest(
        widget.request.id!,
        selectedLocation,
        selectedSize,
        requestReason,
      );
    } catch (e) {
      // Handle error (print or throw an exception)
    }
    // Display success message
        SuccessMessageDialog.show(
          context,
          "تم تحديث الطلب بنجاح",
          '/view_requests', 
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تعديل الطلب',
          style: TextStyle(
            color: Colors.black,
            fontSize: 26,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'سبب الطلب',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.right,
            ),
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                hintText: 'سبب الطلب',
                errorText: _reasonController.text.isEmpty ? 'يرجى إدخال سبب الطلب' : null,
              ),
              textAlign: TextAlign.right,
            ),
            SizedBox(height: 20),
            Text(
              'حجم الحاوية',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.right,
            ),
            DropdownButton<String>(
              value: _selectedSize,
              onChanged: (String? value) {
                setState(() {
                  _selectedSize = value!;
                });
              },
              items: ['حاوية صغيرة', 'حاوية كبيرة']
                  .map<DropdownMenuItem<String>>(
                    (String value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, textAlign: TextAlign.right),
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: 20),
            Text(
              'لتغيير موقع الحاوية قم بالضغط على الموقع المراد',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.right,
            ),
            Container(
              height: 370,
              child: GoogleMap(
                zoomControlsEnabled: true,
                zoomGesturesEnabled: true,
                myLocationButtonEnabled: true,
               scrollGesturesEnabled: true,
               rotateGesturesEnabled:false,
              tiltGesturesEnabled: true,
              myLocationEnabled: true,
                initialCameraPosition: CameraPosition(
                  target: selectedLocation ?? LatLng(0.0, 0.0),
                  zoom: 19,
                ),
                markers: selectedLocation != null
                    ? Set<Marker>.from([
                        Marker(
                          icon:BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                          markerId: MarkerId('selected_location'),
                          position: selectedLocation!,
                          draggable: true,
                          onDragEnd: _onMarkerDragEnd,
                        ),
                      ])
                    : Set<Marker>(),
                onTap: (LatLng newPosition) {
                  setState(() {
                    selectedLocation = newPosition;
                  });
                },
                onMapCreated: (GoogleMapController controller) {},
              ),
            ),
            SizedBox(height: 20),


            ElevatedButton(
               onPressed: () {
                 // Validate the reason field
    if (_reasonController.text.isEmpty) {
      // Display an error message or handle the validation error as needed
      // For now, we'll print an error message
      print("الرجاء إدخال سبب الطلب");
      return;
    }


  
    // Display confirmation dialog before updating
    ConfirmationDialog.show(
      context,
      "تأكيد التعديل",
      "هل أنت متأكد أنك تريد حفظ التعديلات؟",
      () async {
        // Update the request with the new data
       updateRequest(
          selectedLocation,
          _selectedSize,
          _reasonController.text,
        );
      },
    );
        
  },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF97B980),
                padding: EdgeInsets.all(10),
                minimumSize: Size(370, 10),
                shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
              ),
              child: Text(
                "حفظ التعديلات",
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
    );
  }
}

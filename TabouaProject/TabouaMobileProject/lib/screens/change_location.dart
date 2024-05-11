// ignore_for_file: camel_case_types, prefer_final_fields, non_constant_identifier_names, prefer_const_constructors

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Services/address_request.dart';

class change_location extends StatefulWidget {
  Position? currentLocation;
  Position? complaintLocation;
  String? userId;
  String? address;
  change_location({ required this.currentLocation , required this.complaintLocation ,required this.userId , super.key , required this.address });

  @override
  State<change_location> createState() => _change_locationState();
}

class _change_locationState extends State<change_location> {
  bool _isLoading = false;
  Marker? current_location;
  Set<Marker> markers = {};
  LatLng? selectedLocation;
  GoogleMapController? _mapController;
  String? address;
  bool isChanged = false;
    @override
    void initState() {
     super.initState();
     markers = {
      Marker(
        markerId: MarkerId('current_location'),
        position: LatLng(
          widget.complaintLocation?.latitude ?? 10.0,
          widget.complaintLocation?.longitude ?? 10.0,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        draggable: true,
      ),
    };
  }
Future<void> user_address (BuildContext context , LatLng position) async {
String current_address = await addressRequest.searchCoordinateAddress(position, context); // get address from address_request class
setState(() {
  address = current_address;
});
}
  void _goToMyLocation() async {
    Position? position = widget.currentLocation;
      const double zoomLevel = 15.5; 

    if (position != null) {
         final LatLng userLocation = LatLng(position.latitude, position.longitude);
       _mapController?.moveCamera(CameraUpdate.newLatLngZoom(userLocation , zoomLevel) );
       setState(() {
      markers.removeWhere((marker) => marker.markerId.value == 'current_location');
      markers.add(Marker(
        markerId: MarkerId('current_location'),
        position: userLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        draggable: true,
      ));
      selectedLocation = userLocation;
      user_address(context, userLocation);
      
    });
    }
  }
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }
  @override
  Widget build(BuildContext context) {
     final screenSize = MediaQuery.of(context).size;

    return Scaffold(

   body: Stack(
    children: [
      Container(
     child: Padding(
      padding: EdgeInsets.only(top:30 , bottom: 30),
       child: _isLoading ? // to load the map
        // circle indictor when load map
         Center(child:CircularProgressIndicator( 
       valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF97B980)), 
        )) :
        GestureDetector(
       onVerticalDragStart: (start) {},
       child: GoogleMap(
       zoomControlsEnabled: true,
       zoomGesturesEnabled: true,
       myLocationButtonEnabled: false,
       scrollGesturesEnabled: true,
       rotateGesturesEnabled:false,
       tiltGesturesEnabled: true,
       myLocationEnabled: true,
       onMapCreated: _onMapCreated,
       initialCameraPosition: CameraPosition(
       target: LatLng(
       widget.complaintLocation!.latitude ?? 10.0,
       widget.complaintLocation!.longitude ?? 10.0,
       ),
       zoom: 15.5,
       ),

       
       // Faciltate the finger gesture on map
       gestureRecognizers: Set()
              ..add(Factory<PanGestureRecognizer>(() => PanGestureRecognizer()))
              ..add(Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()))
              ..add(Factory<TapGestureRecognizer>(() => TapGestureRecognizer()))
              ..add(Factory<VerticalDragGestureRecognizer>(
                  () => VerticalDragGestureRecognizer())),
        
       onTap: (LatLng position) {
          setState(() {
            markers.removeWhere((marker) => marker.markerId.value == 'current_location');// remove the marker before and add new one withe new location
            markers.add(Marker(
              markerId: MarkerId('current_location'),
              position: position,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
              draggable: true,
            ));
           selectedLocation = position;
          user_address(context, position);
          isChanged = true;
          }
          );
        },
       markers: markers,
       ),
       
        ),
        
     ),
   ),
   // myLocation button
     Positioned(
            bottom: 160.0,
            right: 10.0,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () {
                  _goToMyLocation(); // return camera to user location
              },
              child: Icon(
                Icons.my_location,
                color: Colors. grey.shade700,
              ),
            ),
          ),
      
// Address Bar 
Positioned(
  top: 89,
  left: 0,
  right: 0,
  child: Padding(
    padding: EdgeInsets.symmetric(horizontal: 16),
    child: Container(
      height: screenSize.height * 0.12,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Wrap(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,

                children:[ 
                  Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Icon(
                    Icons.my_location,
                    color: Colors.grey.shade700,
                  ),
                ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  width: screenSize.width * 0.5, 
                  child: Text(
                    address ?? widget.address.toString(),
                    style: GoogleFonts.balooBhaijaan2(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
),

          Positioned(
            bottom: 90,
             left: 20.0,
             right: 20.0,
              child: ElevatedButton(
              onPressed: () {
                DateTime timestamp = DateTime.now();
                double accuracy = 0.0; 
                double altitude = 0.0; 
                double altitudeAccuracy = 0.0; 
                double heading = 0.0; 
                double headingAccuracy = 0.0; 
                double speed = 0.0; 
                double speedAccuracy = 0.0; 
               if(selectedLocation != null){
               Position newLocation = Position(
                  latitude: selectedLocation!.latitude, 
                  longitude: selectedLocation!.longitude,
                  timestamp: timestamp,
                  accuracy: accuracy,
                   altitude: altitude,
                   altitudeAccuracy: altitudeAccuracy,
                   heading: heading,
                   headingAccuracy: headingAccuracy,
                   speed: speed,
                   speedAccuracy: speedAccuracy,
                  );

              // return new location selected to raise complaint screen
               Navigator.pop(context ,newLocation );
              }
              else {
              // return user location to raise complaint screen
               Navigator.pop(context , widget.currentLocation );
              }
               },
                
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ), 
                backgroundColor: Color(0xFF97B980),
                padding: EdgeInsets.all(10),
                minimumSize: Size(300, 10),
              ),
              child: Text(
                "تأكيد تغيير الموقع",
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

    );
  }
  
}
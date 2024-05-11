import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:taboua_app/models/garbage_bin_requests.dart';
import '../Services/address_request.dart';

class edit_request_location extends StatefulWidget {
garbage_bin_requests? request;
Position? currentLocation;
Position? requestLocation;
String userId;
String? address;
 edit_request_location({super.key , required this.userId , required this.request, required this.address});

  @override
  State<edit_request_location> createState() => _edit_request_locationState();
}

class _edit_request_locationState extends State<edit_request_location> {

   bool _isLoading = false;
  Marker? current_location;
  Set<Marker> markers = {};
  LatLng? selectedLocation;
  GoogleMapController? _mapController;
  String? address; // local address for the user
  Position? _currentLocation;


     void initState() {
     super.initState();
     _getLocation();
     markers = {
      Marker(
        markerId: MarkerId('current_location'),
        position: LatLng(
          widget.request?.location!.latitude ?? 10.0,
          widget.request?.location!.longitude ?? 10.0,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        draggable: true,
      ),
    };
  }
  Future<void> _getLocation() async {
final status = await Permission.location.request();
if (status.isGranted) {
try {
final position = await Geolocator.getCurrentPosition(
desiredAccuracy: LocationAccuracy.bestForNavigation,
);

setState(() {
  _currentLocation = position;
});
} catch (e) {
print('Error getting location: $e');
}

} else {
print('Location permission not granted');
}

}
Future<void> user_address (BuildContext context , LatLng position) async {
String current_address = await addressRequest.searchCoordinateAddress(position, context); // get address from address_request class
setState(() {
  address = current_address;
});
}
 void _goToMyLocation() async {
    DateTime timestamp = DateTime.now();
                double accuracy = 0.0; 
                double altitude = 0.0; 
                double altitudeAccuracy = 0.0; 
                double heading = 0.0; 
                double headingAccuracy = 0.0; 
                double speed = 0.0; 
                double speedAccuracy = 0.0; 
                  Position position = Position(
                  latitude: widget.request!.location!.latitude,
                  longitude: widget.request!.location!.longitude,
                  timestamp: timestamp,
                  accuracy: accuracy,
                   altitude: altitude,
                   altitudeAccuracy: altitudeAccuracy,
                   heading: heading,
                   headingAccuracy: headingAccuracy,
                   speed: speed,
                   speedAccuracy: speedAccuracy,
                  );
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
       widget.request!.location!.latitude ?? 10.0,
       widget.request!.location!.longitude ?? 10.0,
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
          user_address(context , position);
          }
          );
        },
       markers: markers,
       ),
       
        ),
        
     ),
   ),
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
          Positioned(
            bottom: 90,
             left: 20.0,
             right: 20.0,
              child: ElevatedButton(
              onPressed: () {
               if(selectedLocation != null){
                Navigator.pop(context , selectedLocation );

              }
              else {
               double lat = widget.request!.location!.latitude;
               double lng = widget.request!.location!.longitude;
               LatLng latLng = LatLng(lat, lng);
               Navigator.pop(context , latLng );
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
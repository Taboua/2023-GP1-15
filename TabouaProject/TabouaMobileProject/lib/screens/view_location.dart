import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';

class view_location extends StatefulWidget {
  LatLng location; 
  String localArea;
  String? screenLable;
   view_location({super.key , required this.location , required this.localArea , required this.screenLable});

  @override
  State<view_location> createState() => _view_locationState();
}

class _view_locationState extends State<view_location> {
  Marker? complaint_location;
  Set<Marker> markers = {};
  LatLng? selectedLocation;
  GoogleMapController? _mapController;

  void initState() {
     super.initState();
     
     markers = {
      Marker(
        markerId: MarkerId('complaint_location'),
        position: LatLng(
          widget.location?.latitude ?? 10.0,
          widget.location?.longitude ?? 10.0,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        draggable: false,
        
      ),
      
    };
  }
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
   
  }

   void _goToMyLocation() async {
    GeoPoint?location  = GeoPoint(widget.location.latitude, widget.location.longitude);
      const double zoomLevel = 17.5; // Specify your desired zoom level here

    if (location != null) {
         final LatLng userLocation = LatLng(location.latitude, location.longitude);
       _mapController?.moveCamera(CameraUpdate.newLatLngZoom(userLocation , zoomLevel) );
      
    }
   }
   Future<void> _launch(Uri url) async {
   await canLaunchUrl(url)
    ? await launchUrl(url)
    : print('could_not_launch_this_app');
}
  @override
  Widget build(BuildContext context) {
         final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
    backgroundColor: Colors.white,
    title: Text(
      "${widget.screenLable}",
      style: GoogleFonts.balooBhaijaan2(
        color: Colors.black,
        fontSize: 26,
      ),
    ),
  ),
     body: Stack(
    children: [
      Center(
        child: Container(
          width: screenSize.width * 0.95,
          height: screenSize.height * 0.5,
           decoration: BoxDecoration(
                        border: Border.all(color: Colors.green),
                      ),
         
         child: 
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
         widget.location.latitude?? 10.0,
         widget.location.longitude?? 10.0,
         ),
         zoom: 17.5,
         ),
      
         
         // Faciltate the finger gesture on map
         gestureRecognizers: Set()
                ..add(Factory<PanGestureRecognizer>(() => PanGestureRecognizer()))
                ..add(Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()))
                ..add(Factory<TapGestureRecognizer>(() => TapGestureRecognizer()))
                ..add(Factory<VerticalDragGestureRecognizer>(
                    () => VerticalDragGestureRecognizer())),
          
         
         markers: markers,
         ),
         
          ),
          
           ),
         ),
      
      Positioned(
      top: 50,
      right: 9,
      child: Column(
         crossAxisAlignment: CrossAxisAlignment.center,
         children: [
          Padding(
          padding: EdgeInsets.symmetric(horizontal: 20 , vertical: 30 ),
            child: Row(
              children: [
                       Directionality(
                        textDirection: TextDirection.rtl,
                         child: SizedBox(
                          width: 350,
                           child: GestureDetector(
                            onTap:() {
                              final String? locationUrl = "https://www.google.com/maps/search/?api=1&query=${widget.location.latitude}, ${widget.location.longitude}";
                            if (locationUrl != null) {
                              final Uri locationUri = Uri.parse(locationUrl);
                              _launch(locationUri);
                            } else {
                              print('Website URL is null or invalid.');
                            }
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                "${widget.localArea}",
                                style: GoogleFonts.balooBhaijaan2(
                                  textStyle: const TextStyle(
                                    fontSize: 22,
                                    color:Colors.blue,
                                  ),
                                ),
                               ),
                            ),
                            
                           ),
                         ),
                       ),
                     SizedBox(width: 5), 
  
                
                Icon(
                  Icons.location_pin, 
                  color:Color(0xFF97B980), 
                  size: 40,
                ),
              ],
            ),
          ), 
      ],
    ),
  ),


   // myLocation button
     Positioned(
            bottom: 200.0,
            right: 20.0,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () {
                _goToMyLocation();
              },
              child: Icon(
                Icons.my_location,
                color: Colors. grey.shade700,
              ),
            ),
          ),     
    ],
    ),

    );
  }
}
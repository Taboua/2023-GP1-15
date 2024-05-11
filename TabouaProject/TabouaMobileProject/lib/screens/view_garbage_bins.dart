// ignore_for_file: unused_field, unnecessary_null_comparison, unused_local_variable, camel_case_types, prefer_final_fields, prefer_collection_literals, avoid_print, prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, unnecessary_brace_in_string_interps, use_build_context_synchronously, await_only_futures

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import'dart:async';
import 'package:taboua_app/Services/garbage_database.dart';
import 'package:provider/provider.dart';
import 'package:taboua_app/Services/garbage_bin_requestDB.dart';
import 'package:taboua_app/messages/signup.dart';
import 'package:taboua_app/models/garbage_bin.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:taboua_app/screens/bottom_bar.dart';
import 'package:toastification/toastification.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Services/address_request.dart';
import 'dart:math';
import 'package:intl/intl.dart' hide TextDirection;
import '../messages/requestToaster.dart';
import 'package:custom_info_window/custom_info_window.dart';

enum garbageSizes { big ,  small }

class viewGrabageBin extends StatefulWidget {
final String userId;
const viewGrabageBin({Key? key , required this.userId}) : super(key: key);

@override

State<viewGrabageBin> createState() => _viewGrabageBinState();

}

class _viewGrabageBinState extends State<viewGrabageBin> {
Uint8List? markerIcon ;
garbageDatabase garbageDb = garbageDatabase(); // create instance from GarbageDatabase
ToastManager toastManager = ToastManager();
Set<Marker> _markers = Set(); // markers list

GoogleMapController? _mapController;
LatLng? latlong;
Position? _currentLocation;
LatLng? requestLocation;
bool _isLoading = true;
Marker? draggedMarker; // Variable to hold the dragged marker
bool isButtonVisible = true;
bool isTapOnMap = false;
bool isMarkerDraggable = false;
bool requestWindow = false;
bool isToastVisible = false;
String address = '';
final Toastification toastification = Toastification();
int tosateMessageAppear = 0;
double mapZoomLevel = 15.5;
//to compute distnace
  double minLat = double.infinity;
  double minLong = double.infinity;
  double maxLat = double.negativeInfinity;
  double maxLong = double.negativeInfinity;
  bool isGuestUser = FirebaseAuth.instance.currentUser?.isAnonymous ?? true;


String? requestReasonError ;
final _formKey = GlobalKey<FormState>();
String dropdownValue = "الكل";
CustomInfoWindowController? _customInfoWindowController;

@override
void initState() {
super.initState();
_getLocation(); // get user current location
_fetchGarbageBins(); // fetach data from firebase
  }
    @override
  void dispose() {
    super.dispose();
  }

  @override
void setState(VoidCallback fn) {
if (mounted){
super.setState(fn);
}
}


// function to get cuurent user location
Future<void> _getLocation() async {
final status = await Permission.location.request();
if (status.isGranted) {
try {
final position = await Geolocator.getCurrentPosition(
desiredAccuracy: LocationAccuracy.bestForNavigation,
);

setState(() {
_currentLocation = position;
requestLocation = LatLng(position.latitude, position.longitude);
_isLoading = false;
user_address(context, LatLng(_currentLocation!.latitude, _currentLocation!.longitude));
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
      const double zoomLevel = 15.5; 
        final LatLng userLocation = LatLng(_currentLocation!.latitude, _currentLocation!.longitude);
       _mapController?.moveCamera(CameraUpdate.newLatLngZoom(userLocation , zoomLevel) );
       
    if(isMarkerDraggable == true){
      setState(() {
    draggedMarker = Marker(
      markerId: const MarkerId('dragged_marker'),
      position: userLocation,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      draggable: true,
    );
          user_address(context, userLocation);

  });
    }
  }
// to resize icon marker
Future<Uint8List>getBytesFromAssets (String path , int width) async{
  try {
ByteData data = await rootBundle.load(path);
ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),targetHeight:width );
ui.FrameInfo fi = await codec.getNextFrame() ;
return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();


  }catch(e){
     print("Error loading asset_________________: $e");
     return Uint8List(0);
  }

}
// function when user click on link open it on browser
 Future<void> _launch(Uri url) async {
   await canLaunchUrl(url)
    ? await launchUrl(url)
    : print('could_not_launch_this_app');
}

Future<void> _showMarkerDetails(String garbageSize , LatLng location){
 return showModalBottomSheet(
  backgroundColor: Colors.transparent,
  isScrollControlled: false,
  context: context,
  builder: (BuildContext bc) {
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      maxChildSize: 0.3,
      minChildSize: 0.3,
      expand: false,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: ListView.separated(
              controller: scrollController,
              itemCount: 1,
              separatorBuilder: (context, index) => SizedBox(height: 100), 
              itemBuilder: (context, index) {
                return Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    children: [
                      ListTile(
                        title: RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: [
                              TextSpan(
                                text: 'حجم الحاوية:  ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: '${garbageSize}',
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ListTile(
                        title: GestureDetector(
                          onTap: () {
                            final String? locationUrl = "https://www.google.com/maps/search/?api=1&query=${location.latitude}, ${location.longitude}";
                            if (locationUrl != null) {
                              final Uri locationUri = Uri.parse(locationUrl);
                              _launch(locationUri);
                            } else {
                              print('Website URL is null or invalid.');
                            }
                          },
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'الموقع الجغرافي للحاوية في خرائط قوقل: ',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: 'اضغط هنا',
                                  style: TextStyle(
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  },
);

}
// fetach garbge info from firebase
void _fetchGarbageBins() {
  // Use data from garbageDatabase 
  final garbageDb = garbageDatabase();
  final garbageBinsStream = garbageDb.getGarbageBin();
  
  LatLng? nearestMarkerLocation;
  double nearestMarkerDistance = double.infinity;

  garbageBinsStream.listen((List<Garbage_Bin> garbageBins) async {
    // Clear existing markers
    _markers.clear();

    // Filter garbageBins based on the selected type
    final filteredGarbageBins = dropdownValue != "الكل"
        ? garbageBins.where((bin) => bin.size == dropdownValue).toList()
        : garbageBins;

   double totalLat = 0.0;
    double totalLong = 0.0;
    // Create markers from the filtered data
    for (final garbageBin in filteredGarbageBins) {
      final lat = garbageBin.location?.latitude; 
      final long = garbageBin.location?.longitude; 
      final Uint8List markerIcon = await getBytesFromAssets("images/trash.png", 90);


      if (lat != null && long != null) {
    
        totalLat += lat;
        totalLong += long;
        final marker = Marker(
          markerId: MarkerId(garbageBin.serialNumber?? ""),
          position: LatLng(lat, long),
          icon: markerIcon != null ? BitmapDescriptor.fromBytes(markerIcon) : BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(
            title: "حجم الحاوية:",
            snippet: 
               '${garbageBin.size}'.toString(),
            
          ),
          onTap: () {
       _showMarkerDetails((garbageBin.size).toString() , LatLng(lat, long ));
          },
          
        );
        
        setState(() {
          _markers.add(marker);
        });

        // Calculate distance between current location and the marker using Haversine formula
        if(_currentLocation != null) {
          final double distance = calculateDistance(
          _currentLocation!.latitude,
          _currentLocation!.longitude,
          lat,
          long,
        );

        // Update nearest marker if the current one is closer
        if (distance < nearestMarkerDistance) {
          nearestMarkerDistance = distance;
          nearestMarkerLocation = LatLng(lat, long);
        }
        }
        
      }
    }

    // Animate the camera to the nearest marker if one was found
    if (nearestMarkerLocation != null && isTapOnMap!=true) {
            final GoogleMapController? controller = await _mapController;
       controller?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(nearestMarkerLocation!.latitude, nearestMarkerLocation!.longitude), 15.5));
    }
  });
}


// Calculat distance between current location and nearest filtered bins
double calculateDistance(double fromLat, double fromLong, double toLat, double toLong) {
  const double earthRadius = 6371000.0; // Earth radius in meters
  // Convert degrees to radians
  final double lat1Rad = fromLat * (pi / 180);
  final double lon1Rad = fromLong * (pi / 180);
  final double lat2Rad = toLat * (pi / 180);
  final double lon2Rad = toLong * (pi / 180);

  // Calculate differences
  final double dLat = lat2Rad - lat1Rad;
  final double dLon = lon2Rad - lon1Rad;

  // Haversine formula
  final double a = pow(sin(dLat / 2), 2) +
      cos(lat1Rad) * cos(lat2Rad) * pow(sin(dLon / 2), 2);
  final double c = 2 * asin(sqrt(a));

  // Calculate distance in meters
  final double distance = earthRadius * c;

  return distance;
}


// to show map controller
void _onMapCreated(GoogleMapController controller) {
_mapController = controller;
}

// display tosate info to guide user to request garbage bin
void displayToast(BuildContext context) async {
       if (toastManager.isToastVisible && tosateMessageAppear>0) {
         toastManager.showCustomToast(context);
       } else {
        tosateMessageAppear =0;
         toastManager.dismiss(); // Dismiss the toast if it's visible
       }
     }

//Success Meesage for request bins
void showSucessMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "تم بنجاح",
                  style: GoogleFonts.balooBhaijaan2(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "تم طلب حاوية النفايات بنجاح",
            
                  style: GoogleFonts.balooBhaijaan2(
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF97B980),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "استمرار",
                    style: GoogleFonts.balooBhaijaan2(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
}
void showRequestDialog(BuildContext context , LatLng position , String address) {
String title = "طلب حاوية";
String message = "بيانات طلب الحاوية";
String dropdownValue = 'حاوية صغيرة';
String userInputText = '';
List<String> sizes = [ 'حاوية صغيرة', 'حاوية كبيرة']; // Updated dropdown list
String? bigGarbage = sizes[0];
String? smallGarbage = sizes[1];
garbageSizes? selectedSize = garbageSizes.big;
double dropdownWidth = MediaQuery.of(context).size.width - 110;  // take the width of screen and the - 35

showDialog(
context: context,
builder: (context) {
return Dialog(
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(20),
),
child: Container(
padding: EdgeInsets.all(16),
child: Column(
mainAxisSize: MainAxisSize.min,

children: [
Text(
title,
style: GoogleFonts.balooBhaijaan2(
fontSize: 18,
fontWeight: FontWeight.bold,
),

),

SizedBox(height: 20),
Text(
message,
style: GoogleFonts.balooBhaijaan2(
fontSize: 16,
),
textAlign: TextAlign.center,
),

SizedBox(height: 20),

            //////// reuqest bins input fileds =>  bins size  , request reason
            
            Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'حجم الحاوية',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                     textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                  ),
                  Container(
                    child: DropdownMenu<String>(
                      width:dropdownWidth ,
                      initialSelection: dropdownValue,
                      onSelected: (String? value) {
                        // This is called when the user selects an item.
                        setState(() {
                          dropdownValue = value!;
                        });
                      },
                      dropdownMenuEntries: sizes
                          .where((value) => value != 'حجم الحاوية')
                          .map<DropdownMenuEntry<String>>((String value) {
                        return DropdownMenuEntry<String>(value: value, label: value);
                      }).toList(),
                    ),
                  ),
                ],
                    
              ),
            ),
            
// request reason text filed
  Form(
  key: _formKey,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Text field for request reason
      Directionality(
        textDirection: TextDirection.rtl,
        child: TextFormField(
          textAlign: TextAlign.right,
          maxLines: 2,
          maxLength: 70,
          decoration: InputDecoration(
            labelText: "سبب طلب الحاوية",
            labelStyle: TextStyle(color: Color(0xff07512d)),
      
            hintText: "سبب طلب الحاوية",
            alignLabelWithHint: true,
            floatingLabelAlignment: FloatingLabelAlignment.start,
            
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: _formKey.currentState?.validate() == false ? Colors.red : Color(0xff07512d)),
            ),
          ),
          onChanged: (value) {
            setState(() {
              userInputText = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty || value.trim().isEmpty) {
              return 'الرجاء إدخال سبب الطلب';
            }
            return null;
          },
        ),
      ),

      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           ElevatedButton(
      onPressed: () {
        setState(() {
          isButtonVisible = true;
          isTapOnMap = false;
          isMarkerDraggable = false;
          draggedMarker = null;
          _mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(_currentLocation!.latitude, _currentLocation!.longitude), zoom: 15.5)));
        });
        Navigator.of(context).pop(); // Close the dialog

      },
      //Click close
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        "الغاء",
        style: GoogleFonts.balooBhaijaan2(
          color: Colors.white,
        ),
      ),
    ),
        SizedBox(width: 20), 
        // confirm bins request
          ElevatedButton(
            onPressed: () {
              setState(() {
                if(_formKey.currentState?.validate() == true){
                isButtonVisible = true;
                isTapOnMap = false;
                isMarkerDraggable = false;
                draggedMarker = null;
                _mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(_currentLocation!.latitude, _currentLocation!.longitude), zoom: 15.5)));

                addRequest(dropdownValue, userInputText, position , address); // to add request to firebase
                Navigator.of(context).pop(); // Close the dialog
                
                   showSucessMessage();   // show sucess message after request garabage bin
                }           
              });     
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF97B980),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              "تأكيد",
              style: GoogleFonts.balooBhaijaan2(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      
    ],
  ),
)
],
),
),
);
},
);
}
//Generate random request number
int generateUniqueNumber() {
final random = Random();
return random.nextInt(10000); // Generates a random number between 0 and 9999
}
// genrate unique requestNo
String generateRequestNumber() {
// Get the current date and time
final now = DateTime.now();
final date = DateFormat('yyMMdd');
// Format the current date as a string
final formattedDate = date.format(now);
// Generate a unique 4-digit number
final uniqueNumber = generateUniqueNumber().toString().padLeft(4, '0');
// Combine the formatted date with the unique number
final requestNumber = formattedDate + uniqueNumber;
return requestNumber;
}

//Function to add New request to firebase
void addRequest(String garbgeSize , String requestReason , LatLng position , String address) async {
// Function to generate a request number
final requestNumber = generateRequestNumber();
//  Create instnace of garbage_bin_requestDB class
garbage_bin_requestDB requestDB = garbage_bin_requestDB();
// Request data
final requestData = {
'location': GeoPoint(position.latitude, position.longitude), 
'requestNo': requestNumber,
'requestDate': Timestamp.fromDate(DateTime.now()),
'requesterId': widget.userId, // user ID
'status': 'جديد', 
'garbageSize':garbgeSize,
'requestReason':requestReason,
'localArea': address,

};
requestDB.add(requestData); // add to firebase
}


Widget filterMarkers(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth * 0.3; 
    double fontSize = screenWidth * 0.03; 

  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 3),
    
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: SizedBox(
          width: containerWidth,
          child: InputDecorator(
            decoration: InputDecoration(
              
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30), 
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 0 , vertical: 0),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                dropdownStyleData: DropdownStyleData(
                  isOverButton: false,
                  maxHeight: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(17), 
                  ),
                ),
                value: dropdownValue,
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValue = newValue ?? 'الكل';
                       _fetchGarbageBins();
                  });
                },
                items: <String>[
                  'الكل',
                  'حاوية صغيرة',
                  'حاوية كبيرة',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    alignment: AlignmentDirectional.centerEnd,
                    child: Container(
        
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20), 
                        color: Colors.transparent, 
                      ),
                      child: Padding(
                      padding: EdgeInsets.zero, 

                        child: Text(
                          value,
                          style: TextStyle(fontSize: fontSize),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                      
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    
  );
}

@override

Widget build(BuildContext context) {
final screenSize = MediaQuery.of(context).size; // get screen size

//stream to fetach new data wehn upadted from firebase
return StreamProvider<List<Garbage_Bin>>.value(
initialData: [],
value:garbageDb.getGarbageBin(),
child: Scaffold(
  appBar: AppBar( 
    iconTheme: IconThemeData(
    color: Colors.black, 
  ),   
        title: Text(
      'حاويات النفايات', 
      style: GoogleFonts.balooBhaijaan2(
        color: Colors.black,
        fontSize: 26,
      ),
    ),
        backgroundColor: Color(0xFFF3F3F3),

        actions: [
          filterMarkers(context), // Add the filter dropdown to the app bar
        ],
      ),
body: _isLoading ? // to load the map

// circle indictor when load map
const Center(child:CircularProgressIndicator( 
   valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF97B980)), 
)) :
GestureDetector(
  onVerticalDragStart: (start) {},
  child: Stack(
    children: [
    GoogleMap(
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
    _currentLocation?.latitude ?? 10.0,
    _currentLocation?.longitude ?? 10.0,
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
  
    onTap:!isButtonVisible && isTapOnMap ? // option to click on sepcific location wehn user reuqest bin
    
    (LatLng position) {
    setState(() {
    draggedMarker = Marker(
    markerId: const MarkerId('dragged_marker'),
    position: position,
    icon:BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    draggable: true,
    );
    
    if(isMarkerDraggable) {
    user_address(context , position);
    }
   
    requestLocation = position;

    });
    }
    :null,
    markers: draggedMarker != null ? Set.of([draggedMarker!]) : _markers, // if click on reuqest buttton teh will show only the dragble button if not click will show all markers
    
    ),
// Address Bar 
if(isButtonVisible == false) 
Positioned(
  top: screenSize.height * 0.05,
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
                    address!,
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
if(isButtonVisible == false)
 Positioned(
        bottom: MediaQuery.of(context).size.height * 0.08, 
        left: MediaQuery.of(context).size.width * 0.1, 
        right: MediaQuery.of(context).size.width * 0.1, 
              child: ElevatedButton(
              onPressed: () {
               showRequestDialog(context, requestLocation!, address);
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
                "طلب حاوية للموقع الحالي",
                style: GoogleFonts.balooBhaijaan2(
                  textStyle: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
           bottom: screenSize.height * 0.01, 
          right: screenSize.width * 0.02, 
            child: FloatingActionButton(
              heroTag: 'my_location_button', // Unique hero tag
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

    ],
  ),
  
),


floatingActionButton:isButtonVisible?
Opacity(
  opacity: isGuestUser ? 0.7 : 1.0, 
  child: FloatingActionButton.extended(
  
  onPressed: () {
    if (isGuestUser) {
      SignupDialog.showSignupDialog(context);
    } else {
      toastManager.isToastVisible = true;
      tosateMessageAppear += 1; // to not display toast message more than one time
      displayToast(context); // Display the toast message

      // Update the dragged marker
      setState(() {
        draggedMarker = Marker(
          markerId: MarkerId('dragged_marker'),
          position: LatLng(requestLocation!.latitude , requestLocation!.longitude ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          draggable: true,
        );

        isButtonVisible = false; // Hide the button on click
        isTapOnMap = true;
        isMarkerDraggable = true;


      });
    }
  },
  backgroundColor: Color(0xff07512d),
  
  tooltip: 'طلب حاوية',
  label: Row(
    children: [
      Image.asset(
        'images/bin1.png',
        width: 24,
        height: 24,
        color: Colors.white,
      ),
      
      SizedBox(width: 8),
      Text(
        'طلب حاوية',
        style: GoogleFonts.balooBhaijaan2(fontSize: 18),
      ),
    ],
    
  ),
  ),
  
):null,
floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat, 
bottomNavigationBar:BottomBar(),

),

);

}

}
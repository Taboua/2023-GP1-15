import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/directions.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:taboua_app/models/recycling_center_prediction.dart';
import 'package:taboua_app/screens/view_recycling_centers.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Services/recycling_center.dart';
import '../models/recycling_center.dart';
import 'bottom_bar.dart';

class correct_prediction extends StatefulWidget {
  final wasteType;

  const correct_prediction({super.key , required this.wasteType});

  @override
  State<correct_prediction> createState() => _correct_predictionState();
}

class _correct_predictionState extends State<correct_prediction> {

List<recycling_center_prediction> centers = [];

double distance = 0;
Position? _currentLocation;

final StreamController<List<recycling_center_prediction>> _recyclingCenterStreamController = StreamController<List<recycling_center_prediction>>();


 void initState() {
    super.initState();
    _getLocation(); // get user current location
    featchRecyclingCenter(); // featch recyling center fron firebase
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
});

} catch (e) {
print('Error getting location: $e');
}

} else {
print('Location permission not granted');
}

}

// Calculate distnace between user location and each centers
Future<double> calculate_distance(LatLng origin, LatLng destination) async {
final GoogleMapsDirections _directions =
GoogleMapsDirections(apiKey:"AIzaSyAg5Moce2vsJ85oYfgX6wekMYaf8GpGdTs");

final DirectionsResponse response = await _directions.directionsWithLocation(
  Location(lat: origin.latitude, lng: origin.longitude),
  Location(lat: destination.latitude, lng: destination.longitude),
);

if (response.isOkay) {
final route = response.routes!.first;
final distanceInMeters = route.legs!.fold<num>(0, (prev, leg) => prev + leg.distance!.value!)?.toInt() ?? 0;
final distanceInKilometers = distanceInMeters / 1000;
setState(() {
distance = 0.0;
distance = distanceInKilometers;
});
}

return distance;
}

// fetach centers information and sorted by distance
Future<void> featchRecyclingCenter() async {

  await Future.delayed(Duration(seconds: 2)); 

  final recyclingCenterDB = recyclingCentersDatabase();
  final recyclingCenterStream = recyclingCenterDB.getRecyclingCenters();

  final List<recycling_center_prediction> updatedCenters = []; // list to store returned centers

 // check which center handle secific waste type
  recyclingCenterStream.listen((List<recyclingcenter> recyclingcenters) async {
    var filteredRecyclingCenters =
        recyclingcenters.where((center) => center.type!.contains(widget.wasteType)).toList();

    if (filteredRecyclingCenters.isEmpty) {
      filteredRecyclingCenters =
          recyclingcenters.where((center) => center.type!.contains("أخرى")).toList();
    }

    // loop through list and calculate the distance and store infmation on object
    for (final recyclingcenter in filteredRecyclingCenters) {
      double calculated_distance = await calculate_distance(
        LatLng(
          _currentLocation?.latitude ?? 0.0,
          _currentLocation?.longitude ?? 0.0,
        ),
        LatLng(
          recyclingcenter.location?.latitude ?? 0.0,
          recyclingcenter.location?.longitude ?? 0.0,
        ),
      );

      updatedCenters.add(
        recycling_center_prediction(
          locationURL: recyclingcenter.locationURL!,
          name: recyclingcenter.name!,
          latitude: recyclingcenter.location?.latitude ?? 0.0,
          longitude: recyclingcenter.location?.longitude ?? 0.0,
          distance: calculated_distance,
        ),
      );
    }

    setState(() {
      centers = List.from(updatedCenters); // save centers with its info(name , locationURL , distance)
    });

// sort centers form smallest distnace to largest
centers.sort((a, b) => a.distance.compareTo(b.distance));

 // display centers on list
 _recyclingCenterStreamController.add(centers);

  });
}

// fetach all center information by its name 
 Future<void> fetchRecyclingCenterByName(BuildContext context, String centerName) async {
  //await Future.delayed(Duration(seconds: 2));

  final recyclingCenterDB = recyclingCentersDatabase();
  final recyclingCenterStream = recyclingCenterDB.getRecyclingCenters();

  recyclingCenterStream.listen((List<recyclingcenter> recyclingcenters) async {
    var filteredRecyclingCenters = recyclingcenters
        .where((center) => center.name == centerName);
       
    if (filteredRecyclingCenters.isEmpty) {
      print('No recycling center found with the name: $centerName');
      return;
    }
  _showCenterDetails(context , filteredRecyclingCenters.first); // call function to show the center info dailog
  });

}
// widget to show images as animating slider 
Widget buildCarousel(List<String> imageURLs) {
  return CarouselSlider(
    options: CarouselOptions(
      aspectRatio: 16 / 9,
      enlargeCenterPage: true,
      enableInfiniteScroll: true,
      autoPlay: true,
    ),
    items: imageURLs.map((imageURL) {
      return Builder(
        builder: (BuildContext context) {
          return Container(
          width: double.infinity,
           height: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 5.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              image: DecorationImage(
                image: NetworkImage(imageURL),
                fit: BoxFit.fill,
              ),
            ),
          );
        },
      );
    }).toList(),
  );
}

// function when user click on link open it on browser
 Future<void> _launch(Uri url) async {
   await canLaunchUrl(url)
    ? await launchUrl(url)
    : print('could_not_launch_this_app');
}

// fromating center opening hours for weekdays
String _formatHour(int? hour , String range) {
  if (hour == null) {
    return 'مغلق'; // Handle the case when the center is close
  }
  String period = 'ص';
  if(hour<12) {
    hour+=3;
  }
  if (hour >= 12) {
    period = 'م';
    if (hour > 12) {
      hour -= 9;
    }
  }
  if(range =='من') {
    return '$hour:00 $period';
  }
else {
  range = "إلى";
    return '$range $hour:00 $period';
}
}
// fromating center opening hours for weekends
String _formatHourWeekend(int? hour , String range) {
  if (hour == null) {
    return 'مغلق'; 
  }
  String period = 'ص';

  if(hour<12) {
    hour+=3;
  }
  if (hour >= 12) {
    period = 'م';
    if (hour > 12) {
      hour -= 9;
    }
  }
  if(range =='من') {
    return '$hour:00 $period';
  }
else {
  range = "إلى";
    return '$range $hour:00 $period';

}
}

// show center info 
Future<void> _showCenterDetails(BuildContext context, recyclingcenter recyclingCenter) {

final Map<String, dynamic>? openingHours = recyclingCenter.openingHours; // to get map openinghours from firebase
 String WeekdaysFormattedFromHour = '' ;
  String WeekdaysFormattedToHour = '';
  String FriFormattedFromHour = '';
   String FriFormattedToHour = '';
  String SatFormattedFromHour = '';
   String SatFormattedToHour = '';
 if (openingHours != null) {
    String weekdaysFrom = (openingHours['weekdays']['from']) ?? '';
    String weekdaysTo = (openingHours['weekdays']['to']) ?? '';

    String FriFrom = (openingHours['fri']['from']) ?? '';
     String FriTo = (openingHours['fri']['to']) ?? '';

    String SatFrom = (openingHours['sat']['from']) ?? '';
    String SatTo = (openingHours['sat']['to']) ?? '';

int? WeedaysFromHour;
int? WeekdaysToHour;
int?FrifromHour;
int?FriToHour;
int?SatfromHour;
int?SatToHour;

if (weekdaysFrom.isNotEmpty) {
  DateTime toDateTime = DateTime.parse(weekdaysFrom); // parse time from string to DateTime
  WeedaysFromHour = toDateTime.hour; // get Hour 
}

if (weekdaysTo.isNotEmpty) {
  DateTime toDateTime = DateTime.parse(weekdaysTo);// parse time from string to DateTime
  WeekdaysToHour = toDateTime.hour; // get hour
}

if (FriFrom.isNotEmpty) {
  DateTime toDateTime = DateTime.parse(FriFrom);// parse time from string to DateTime
  FrifromHour = toDateTime.hour; // get hour
}

if (FriTo.isNotEmpty) {
  DateTime toDateTime = DateTime.parse(FriTo);// parse time from string to DateTime
  FriToHour = toDateTime.hour; // get Hour
}

if (SatFrom.isNotEmpty) {
  DateTime toDateTime = DateTime.parse(SatFrom); // parse time from string to DateTime
  SatfromHour = toDateTime.hour; // get Hour
}

if (SatTo.isNotEmpty) {
  DateTime toDateTime = DateTime.parse(SatTo);// parse time from string to DateTime
  SatToHour = toDateTime.hour; // get Hour
}

   // fromating oprning hour time 
   WeekdaysFormattedFromHour = _formatHour(WeedaysFromHour , "من");
   WeekdaysFormattedToHour = _formatHour(WeekdaysToHour , "إلى");
   FriFormattedFromHour = _formatHourWeekend( FrifromHour, "من");
   FriFormattedToHour = _formatHourWeekend( FriToHour, "إلى");
   SatFormattedFromHour = _formatHourWeekend( SatfromHour, "من");
   SatFormattedToHour = _formatHourWeekend( SatToHour, "إلى");

} else {
  print("openingHours empty");
}

// return cenetr information window
  return showModalBottomSheet(
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    context: context,
    builder: (BuildContext bc) {
      return DraggableScrollableSheet(
        initialChildSize: 0.4,
        maxChildSize: 0.9,
        minChildSize: 0.32,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: ListView.builder(
              controller: scrollController,
              itemCount: 1,
              itemBuilder: (context, index) {
                return Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 50,
                        child: Divider(
                          thickness: 5,
                          color: Colors.grey,
                        ),
                      ),
                      ListTile(
                        title: Text('${recyclingCenter.name}',
                          style: TextStyle(
                          fontWeight: FontWeight.bold,
                           )  ,
                        ),
                      ),
                  
                   ListTile(
                   title: RichText(
                  text: TextSpan(
                 style: DefaultTextStyle.of(context).style,
               children: [
              TextSpan(
               text: 'وصف: ',
              style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
             TextSpan(
               text: '${recyclingCenter.description}',
               style: TextStyle(
               fontWeight: FontWeight.normal, 
          ),
        ),
      ],
      ),
      ),
   ),

          ListTile(
           title: RichText(
           text: TextSpan(
            style: DefaultTextStyle.of(context).style,
           children: [
          TextSpan(
          text: 'رقم الهاتف: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
          TextSpan(
          text: '${recyclingCenter.phoneNo}',
          style: TextStyle(
            fontWeight: FontWeight.normal, 
          ),
        ),
      ],
    ),
  ),
),
     
  ListTile(
  title: RichText(
    text: TextSpan(
      style: DefaultTextStyle.of(context).style,
      children: [
        TextSpan(
          text: 'النفايات المستقبلة: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        TextSpan(
          text: '${recyclingCenter.type}',
          style: TextStyle(
            fontWeight: FontWeight.normal, 
          ),
        ),
      ],
    ),
  ),
),

ListTile(
         title: Text(
            'أوقات العمل:',
            style: TextStyle(
            fontWeight: FontWeight.bold, 
          ),                       
     ),              
       subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'أيام الأسبوع : $WeekdaysFormattedFromHour $WeekdaysFormattedToHour',
            style: TextStyle(color: Colors.black),
          ),
    (FriFormattedFromHour == "مغلق" ||FriFormattedToHour == "مغلق") // if center close then show close
    ? Text(
        'الجمعة: $FriFormattedFromHour',
        style: TextStyle(color: Colors.black),
      )
    : Text(
        'الجمعة: $FriFormattedFromHour $FriFormattedToHour',
        style: TextStyle(color: Colors.black),
      ),
          
          (SatFormattedFromHour == "مغلق" ||SatFormattedToHour == "مغلق")
    ? Text(
        'السبت: $SatFormattedFromHour',
        style: TextStyle(color: Colors.black),
      )
    : Text(
        'السبت: $SatFormattedFromHour $SatFormattedToHour',
        style: TextStyle(color: Colors.black),
      ),
         
        ],
      ),
                      ),
                      ListTile(
                    title: GestureDetector(
                     onTap: () {
                     final String? websiteUrl = recyclingCenter.websiteURL;
                   if (websiteUrl != null) {
                  final Uri websiteUri = Uri.parse(websiteUrl);
                 _launch(websiteUri);
               } else {
                 print('Website URL is null or invalid.');
              }
                 },
                child: RichText(
                 text: TextSpan(
                  children: [
                  TextSpan(
                  text: 'الموقع الإلكتروني: ',
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
                 ListTile(
                    title: GestureDetector(
                     onTap: () {
                     final String? locationUrl = recyclingCenter.locationURL;
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
                text: 'الموقع الجغرافي للمركز في خرائط قوقل: ',
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
       buildCarousel([recyclingCenter.logoURL ?? '', recyclingCenter.imageURL ?? '']), // to call widget for image slider

                    ],
                  ),
                );
              },
            ),

          );
        },
      );
    },
  );
}

// Display recycling centers list 
Widget centersList(List<recycling_center_prediction> centers) {
  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: centers.map((center) {

        return GestureDetector(
          onTap: () {
           fetchRecyclingCenterByName(context , center.name);
          },
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Container(
                width: 300,
                height: 80,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: Text(
                              center.name,
                              style: GoogleFonts.balooBhaijaan2(
                                color: Colors.blue,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 5), // space between icon and text
                              Text(
                                'المسافة: ${center.distance} كم',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Positioned(
                        top: 25, 
                        right: 5,
                        child: CircleAvatar(
                          radius: 8,
                          backgroundColor: Color(0xFF97B980),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    ),
  );
}

Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
      iconTheme: IconThemeData(
    color: Colors.black, 
  ),
      backgroundColor: Colors.white,
      title: Text("مراكز إعادة التدوير",
      style: GoogleFonts.balooBhaijaan2(
        color: Colors.black,
        fontSize: 26,
      ),
      ),
),
body:SingleChildScrollView(
  child:   Padding(padding:const EdgeInsets.all(20.0),
  child: Center(
    child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center, 
      children: [
          SizedBox(height: 40),
          Container(
        width: 100.0,
        height: 100.0,
        child: Image.asset(
         'images/recyling.png',
         fit: BoxFit.cover, 
         ),
        ),
        Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
         children: [
          Text(" التي تُعيد تدوير " ,
         style: GoogleFonts.balooBhaijaan2(
          fontSize: 22,
          color: Color(0xFF363436),
         ),
               
          ),
          GestureDetector(
                  onTap: () {
                    // Navigate to view garabge screen
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => viewRecyclingCenters(),
                    ));
                  },
                  child: Text(
                    "مراكز إعادة التدوير" ,
                    style:GoogleFonts.balooBhaijaan2(
                      fontSize: 22,
                      color: Colors.blue, 
                    ),
                  ),
                ),
         ],
        ),
            
           Text("( " + widget.wasteType + " )",
               style: TextStyle(
                fontSize:25 ,
                color: Color(0xFF363436),
                
                ),
               ),
              
                 SizedBox(height: 10),
  
           
              SizedBox(height: 40),
                StreamBuilder<List<recycling_center_prediction>>(
                  stream: _recyclingCenterStreamController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active && snapshot.hasData && snapshot.data!.isNotEmpty) {
                      return centersList(snapshot.data!);
                    } else {
                      return const CircularProgressIndicator(
  
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF97B980)), 
  
                      );
                    }
                  },
                ),
                
    ]),
  ),
  
  ),
),
      bottomNavigationBar: BottomBar(),

    );
  }
  }
  
  
  


// ignore_for_file: camel_case_types

class recycling_center_prediction {

  String locationURL;
  String name;
  double latitude;
  double longitude;
  double distance; 

  recycling_center_prediction({
    required this.locationURL,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.distance = 0.0, // Default distance
  });
}



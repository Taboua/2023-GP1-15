// ignore_for_file: camel_case_types

class wrong_prediction{

String? wrongType;
String? imageURL;
String? correctType;

wrong_prediction({this.wrongType ,this.imageURL});

wrong_prediction.fromJson(Map<String, dynamic> parsedJSON)
:wrongType = parsedJSON['wrongType'].toString(),
  imageURL = parsedJSON['imageURL'].toString(),
  correctType = parsedJSON['correctType'].toString();

}
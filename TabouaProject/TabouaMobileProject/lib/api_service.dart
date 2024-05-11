

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiService {
  
  
static const String baseUrl = 'https://garbage-classification-service-duxsosyzta-zf.a.run.app';


   // Helper function to convert digits to Arabic
  static String _convertDigitsToArabic(String input) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return input.replaceAllMapped(RegExp(r'\d'), (match) {
      return arabicDigits[int.parse(match.group(0)!)];
    });
  }

  static Future<Map<String, dynamic>> classifyWaste(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/classify'));
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(await response.stream.bytesToString());
        String wasteType = data['waste_type'];

        if (wasteType == "none") {
          // Return only the waste type without probability
          return {'wasteType': wasteType, 'probability': null};
        } else {
          double probability = data['probability']; 
          String formattedProbability = probability.toStringAsFixed(2);
          // Convert digits to Arabic
          String arabicProbability = _convertDigitsToArabic(formattedProbability);


          // Return waste type and probability as a formatted string with two decimal places
          return {'wasteType': wasteType, 'probability': ' %$arabicProbability'};
        }
      } else {
        print('Failed to classify waste. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during waste classification: $e');
    }

    return {'wasteType': 'error', 'probability': null}; // Return an error code or handle as appropriate
  }
}


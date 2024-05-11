import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taboua_app/screens/bottom_bar.dart';

class waste_types extends StatelessWidget {
  
  final List<String> wasteTypes = [
   "نفايات",
    "بلاستيك",
    "زجاج",
    "ورق",
    "كرتون",
    "معدن",
    "إلكترونيات",
    "أقمشة",
  ];

Widget build(BuildContext context) {
  final Size screenSize = MediaQuery.of(context).size;
  final bool isSmallScreen = screenSize.height < 600;

  return Scaffold(
    appBar: AppBar(
      title: Text(
        'تصنيف النفايات',
        style: GoogleFonts.balooBhaijaan2(
          color: Colors.black,
          fontSize: 26,
        ),
      ),
      iconTheme: IconThemeData(
      color: Colors.black,
    ),
    backgroundColor: Color(0xFFF3F3F3),
    
    ),
    backgroundColor: Color(0xFFF3F3F3),
    body: Center(
      child: Column(
        children: [
          SizedBox(height: isSmallScreen ? 18 : 23),
          Container(
            padding: const EdgeInsets.all(16),
          ),
          Text(
            ":تَبوأ الذكاء الاصطناعي يستطيع تصنيف",
            style: GoogleFonts.balooBhaijaan2(
              fontSize: isSmallScreen ? 18.0 : 25.0,
              color: Color(0xFF363436),
            ),
          ),
          SizedBox(height: isSmallScreen ? 30 : 44),
          Wrap(
            spacing: isSmallScreen ? 12.0 : 19.0,
            runSpacing: isSmallScreen ? 12.0 : 16.0,
            alignment: WrapAlignment.start,
            children: wasteTypes
                .map((type) => WasteCategoryItem(
                      title: type,
                    ))
                .toList(),
          ),
          SizedBox(height: isSmallScreen ? 14 : 19),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/wasteType_model');
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              backgroundColor: Color(0xFF97B980),
              elevation: 0,
              padding: EdgeInsets.all(10),
              minimumSize: Size(300, isSmallScreen ? 10 : 40),
            ),
            child: Text(
              "صنف النفايات",
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
    bottomNavigationBar: BottomBar(),
  );
}
}
class WasteCategoryItem extends StatelessWidget {
  final String title;

  //waste title
   const WasteCategoryItem({
    Key? key,
    required this.title,
  }) : super(key: key);

Widget build(BuildContext context) {
  return Padding(
    padding: EdgeInsets.only(right:55),
    child: Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: 130.0,
        height: 90.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
               Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 8,
                    backgroundColor: Color(0xFF97B980),
                  ),
                   SizedBox(width: 8), 

                  Text(
                    title,
                    style: GoogleFonts.balooBhaijaan2(
                      fontSize: 16.0,
                      color: Color(0xFF363436),
                    ),
                  ),
                  SizedBox(width: 8), 
                  
                ],
              ),
            
          ],
        ),
      ),
    ),
  );
}


}

void main() {
  runApp(MaterialApp(
    home: waste_types(),
  ));
}

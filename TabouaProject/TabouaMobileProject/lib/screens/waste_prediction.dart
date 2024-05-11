import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taboua_app/screens/trash_waste_type.dart';
import 'package:taboua_app/screens/user_prediction.dart';
import 'bottom_bar.dart';
import 'correct_prediction.dart';

class waste_predicition extends StatelessWidget {
  File image;
  String type;
  String probability;


  waste_predicition({  Key? key,
    required this.image, required this.type, required this.probability, 
  }) : super(key: key);


  void wrongWastePrediction(BuildContext context){
  if(image == null) return;
   Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => user_prediction(image : image! , wrongType:type!)));            
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold (appBar: AppBar(
    iconTheme: IconThemeData(
    color: Colors.black,
  ),
      backgroundColor: Colors.white,
      title: Text("تصنيف النفايات",
      style: GoogleFonts.balooBhaijaan2(
        color: Colors.black,
        fontSize: 26,
      ),
      ),
),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
           crossAxisAlignment: CrossAxisAlignment.center, 
        
            children: [
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(5.0)

                ),
                child:
                    Image.file(
                        image!,
                        height: 300,
                        width: 300,
                        fit: BoxFit.cover,
                      )
              ),
            SizedBox(height: 25),
             Text("حسب تصنيف تَبوأ الذكاء الاصطناعي " ,
            style: GoogleFonts.balooBhaijaan2(
              fontSize: 25,
              color: Color(0xFF363436),
            
            ),
            textAlign: TextAlign.center,
             
             ),

               Text("تم تصنيفه كالأتي" ,
            style: GoogleFonts.balooBhaijaan2(
              fontSize: 25,
              color: Color(0xFF363436),
            
            ),
            textAlign: TextAlign.center,
             
             ),
             SizedBox(height: 15),

             Text(
                "( $type )",
                style: GoogleFonts.balooBhaijaan2(fontSize: 25),
              ),
             const SizedBox(height: 30),
             Row(
             mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton(
                  onPressed: () {
                  wrongWastePrediction(context);
                  },
                  //button of wrong prediction
                  child: const Text('خاطئ' ,
                  style: TextStyle(
                    fontSize: 19,
                    fontFamily: 'BalooBhaijaan2'
                  ),
                  ),
                  style:ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll<Color>(Color(0xFFFE5500)),
                  minimumSize: MaterialStateProperty.all<Size>(Size(100, 40)),
                  ),
                ),
                const SizedBox(width: 30),

              FilledButton(
                  onPressed: () {
          if(type == "نفايات لا يعاد تدويرها") {
             Navigator.of(context).push(
             MaterialPageRoute(
             builder: (context) => trash_waste_type(image: image!),
          ),
  );
          }
          else{
          Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => correct_prediction(wasteType : type!)));

          }

                  },
                  // button of correct predicition
                  child: const Text('صحيح',
                  style: TextStyle(
                    fontSize: 19 ,
                  fontFamily: 'BalooBhaijaan2'),
                  ),
                  style:ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll<Color>(Color(0xFF07512D)),
                  minimumSize: MaterialStateProperty.all<Size>(Size(100, 40)),
                  ),
                ),

             ],)
               
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomBar(),
      
    );
    
    
  }


}
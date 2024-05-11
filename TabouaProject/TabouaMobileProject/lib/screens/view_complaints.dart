// ignore_for_file: must_be_immutable, camel_case_types, prefer_const_constructors, unused_element, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taboua_app/Services/complaints_database.dart';
import 'package:taboua_app/models/complaints.dart';
import 'package:taboua_app/screens/complaint_details.dart';
import 'bottom_bar.dart';

class view_complaints extends StatefulWidget {
  String userId;
  view_complaints({required this.userId , super.key});

  @override
  State<view_complaints> createState() => _view_complaintsState();
}

class _view_complaintsState extends State<view_complaints> {

  final complaints_database complaintsDB = complaints_database();
  String selectedFilter = 'الكل';
  String selectedComplaintTypeFilter = "الكل" ;

  List<complaints> sortSubRequestsByDate(List<complaints> subRequests) {
  subRequests.sort((a, b) => b.complaintDate!.compareTo(a.complaintDate!));
  return subRequests;
}
// format complaint Date 
  String _formatDate(Timestamp? date) {
    return date != null
        ? '${date.toDate().year}-${date.toDate().month}-${date.toDate().day}'
        : '';
  }


// filter by complaint status
 Widget _buildFilterDropdown() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'تصفية حسب حالة البلاغ',
          labelStyle: TextStyle(fontSize: 20.0),
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 0),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            dropdownStyleData: DropdownStyleData(
            isOverButton: false,
            maxHeight: 200,
           decoration: BoxDecoration(
            
              borderRadius: BorderRadius.circular(6),
            ),
            
          ),
            value: selectedFilter,
            onChanged: (String? newValue) {
              setState(() {
                selectedFilter = newValue ?? 'الكل';
              });
            },
            items: <String>[
              'الكل',
              'جديد',
              'قيد التنفيذ',
              'تم التنفيذ',
              'مرفوض'
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                alignment: AlignmentDirectional.centerEnd,
                child: Text(
                  value,
                  style: TextStyle(fontSize: 20.0),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
              );
              
            }).toList(),

         
          ),
        ),
        
      ),
    );
  }



// Filter by complaint type
  Widget _buildComplaintTypeFilterDropdown() {
  List<String> complaintTypes = [
    'الكل',
    'موقع الحاوية',
    'نظافة الحاوية',
    'وقت تفريغ الحاوية',
    'حاوية ممتلئة',
    'مخلفات خطرة',
    'مخلفات مهملة',
    'أخرى',
  ];
 
  return Directionality(
    textDirection: TextDirection.rtl,
    child: Column(
   crossAxisAlignment: CrossAxisAlignment.start,

      children:[
         
         InputDecorator(
        decoration: InputDecoration(
          labelText: 'تصفية حسب نوع البلاغ',
          labelStyle: TextStyle(fontSize: 20.0), 
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 0),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            hint: Text(
              selectedComplaintTypeFilter, 
              style: TextStyle(
                fontSize: 20.0,
                color: Theme.of(context).hintColor,
              ),
            ),
            dropdownStyleData: DropdownStyleData(
              isOverButton: false,
              maxHeight: 200,
             decoration: BoxDecoration(
              
                borderRadius: BorderRadius.circular(6),
              ),
              
            ),
           
            value: selectedComplaintTypeFilter,
            onChanged: (String? newValue) {
              setState(() {
                selectedComplaintTypeFilter = newValue ?? 'الكل';
              });
            },
            items: complaintTypes.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                alignment: AlignmentDirectional.centerEnd,
                child: Text(
                  value,
                  style: TextStyle(fontSize: 20.0),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
              );
            }).toList(),
             
          ),
        ),
      ),
      ],
    ),
  );
}

//request card information
Widget _buildComplaintCard(complaints complaintInfo) {
  Color? statusColor = Colors.black;

  switch (complaintInfo.status) {
    case 'جديد':
      statusColor = Colors.blue[300];
      break;
    case 'قيد التنفيذ':
      statusColor = Colors.orange[300];
      break;
    case 'تم التنفيذ':
      statusColor = const Color(0xFF97B980);
      break;
    case 'مرفوض':
      statusColor = Colors.red[400];
      break;
    default:
      statusColor = Colors.black;
  }

  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Card(
      margin: const EdgeInsets.all(8.0),
      color: const Color(0xFFE9E9E9),
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(19.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FilledButton.tonal(
                      onPressed: () {
                        // Do nothing when the status button is pressed
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(statusColor!),
                             shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0), 
               ),
                 ),

                  minimumSize: MaterialStateProperty.all<Size>(
                Size(90.0, 40.0), 
               ),
                      ),
                      child: Text(
                        '${complaintInfo.status}',
                        style: GoogleFonts.balooBhaijaan2(color: Colors.white, fontSize: 14.0),
                      ),
                    ),

                    TextButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => complaint_details(complaint:complaintInfo , userId: widget.userId,),
                    ),
                  );
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  Colors.grey,
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0), 
               ),
                 ),

                  minimumSize: MaterialStateProperty.all<Size>(
                Size(90.0, 40.0), 
               ),
              ),
              child: Text(
                'تفاصيل',
                style: GoogleFonts.balooBhaijaan2(
                  color: Colors.white,
                  fontSize: 14.0
                ),
              ),
            ),
                  ],
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'رقم البلاغ: ${complaintInfo.complaintNo}',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 20.0,
                          fontFamily: GoogleFonts.balooBhaijaan2().fontFamily,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'تاريخ البلاغ: ${_formatDate(complaintInfo.complaintDate)}',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 20.0,
                          fontFamily: GoogleFonts.balooBhaijaan2().fontFamily,
                        ),
                      ),
                       Text(
                        'نوع البلاغ: ${complaintInfo.complaintType}',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 20.0,
                          fontFamily: GoogleFonts.balooBhaijaan2().fontFamily,
                        ),
                      ),
                       if(complaintInfo.complaintType == "أخرى")
                       Text(
                        'موضوع المشكلة: ${complaintInfo.complaintSubject}',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 20.0,
                          fontFamily: GoogleFonts.balooBhaijaan2().fontFamily,
                        ),
                      ),
                
                      SizedBox(height: 8.0),
                     
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.0)
          ],
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3F3F3),
      appBar: AppBar(
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
    backgroundColor: Color(0xFFF3F3F3),
    
    title: Text(
      "البلاغات",
      style: GoogleFonts.balooBhaijaan2(
        color: Colors.black,
        fontSize: 26,
      ),
    ),
  ),
      body: Column(
        children: [
         SizedBox(height: 40),
          
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.topCenter,
              child:Column(children: [
              _buildFilterDropdown(),
              SizedBox(height: 20),
              _buildComplaintTypeFilterDropdown()
              ],) ,
            ),
          ),
          SizedBox(height: 10,),
          Expanded(
            child: StreamBuilder<List<complaints>>(
              stream: complaintsDB.getComplaints(widget.userId, selectedFilter , selectedComplaintTypeFilter),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(
                         valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF97B980)), 

                  );
                } else if (snapshot.hasError) {
                  print("Error: ${snapshot.error}");
                  return const Center(
                    child: Text(
                      ' حدثت مشكلة أثناء تحميل البيانات',
                      
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'لا توجد بلاغات',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                  );
                } 
                else {
        // Sort the complaint by date before building the ListView
        List<complaints> sortedRequests =
            sortSubRequestsByDate(snapshot.data!);
        return ListView.builder(
          itemCount: sortedRequests.length,
          itemBuilder: (context, index) {
            return _buildComplaintCard(sortedRequests[index]);
          },
        );
      }
              },
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/raise_complaint');
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
                "بلاغ جديد",
                style: GoogleFonts.balooBhaijaan2(
                  textStyle: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
      bottomNavigationBar: BottomBar(),
    );
  }
}
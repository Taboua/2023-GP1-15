// ignore_for_file: camel_case_types, prefer_const_constructors, avoid_print

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taboua_app/Services/garbage_bin_requestDB.dart';
import 'package:taboua_app/messages/confirm.dart';
import 'package:taboua_app/messages/success.dart';
import 'package:taboua_app/models/garbage_bin_requests.dart';
import 'package:taboua_app/screens/bottom_bar.dart';
import 'package:taboua_app/screens/edit_request.dart';
import 'package:taboua_app/screens/requested_bin_details.dart';

class viewRequests extends StatefulWidget {
  final String userId;

  const viewRequests({Key? key, required this.userId}) : super(key: key);

  @override
  State<viewRequests> createState() => _viewRequestsState();
}

class _viewRequestsState extends State<viewRequests> {
  final garbage_bin_requestDB _db = garbage_bin_requestDB();
  String selectedFilter = 'الكل';

  List<garbage_bin_requests> sortSubRequestsByDate(List<garbage_bin_requests> subRequests) {
  subRequests.sort((a, b) => b.requestDate!.compareTo(a.requestDate!));
  return subRequests;
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
      "طلبات الحاويات",
      style: GoogleFonts.balooBhaijaan2(
        color: Colors.black,
        fontSize: 26,
      ),
    ),
  ),
      body: Column(
        children: [
          SizedBox(height: 30),
          
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.topCenter,
              child: _buildFilterDropdown(),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<garbage_bin_requests>>(
              stream: _db.getgarbage_bin_requests(widget.userId, selectedFilter),
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
                      'لا توجد طلبات',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                  );
                } 
                else {
        // Sort the requests by date before building the ListView
        List<garbage_bin_requests> sortedRequests =
            sortSubRequestsByDate(snapshot.data!);
        return ListView.builder(
          itemCount: sortedRequests.length,
          itemBuilder: (context, index) {
            return _buildRequestCard(sortedRequests[index]);
          },
        );
      }
              },
            ),
          ),
          SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/view_garbage_bins');
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
                "طلب حاوية",
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

  // filter by request status
 Widget _buildFilterDropdown() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'تصفية حسب حالة الطلب',
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
//request card information
Widget _buildRequestCard(garbage_bin_requests request) {
  Color? statusColor = Colors.black;

  switch (request.status) {
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
                        '${request.status}',
                        style: GoogleFonts.balooBhaijaan2(color: Colors.white, fontSize: 14.0),
                      ),
                    ),

                    TextButton(
              onPressed: () {
               // _showRequestDetailsPopup(request);
               Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => requested_bin_details(garbageBinRequest:request , userId: widget.userId,),
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


                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'رقم الطلب: ${request.requestNo}',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 20.0,
                        fontFamily: GoogleFonts.balooBhaijaan2().fontFamily,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'تاريخ الطلب: ${_formatDate(request.requestDate)}',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 20.0,
                        fontFamily: GoogleFonts.balooBhaijaan2().fontFamily,
                      ),
                    ),
                   
                  ],
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


void _showRequestDetailsPopup(garbage_bin_requests request) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 17),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'تفاصيل الطلب',
                    style: TextStyle(
                      color: Color(0xFF363436),
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: GoogleFonts.balooBhaijaan2().fontFamily,
                    ),
                  ),
                ),
     
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.close),
                  color: Colors.black,
                ),
              ],
            ),
            SizedBox(height: 10), 
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
             children: [
              Text('حالة الطلب: ${request.status}'),
              SizedBox(height: 5),
              Text('رقم الطلب: ${request.requestNo}'),
              SizedBox(height: 5),
              Text('تاريخ الطلب: ${_formatDate(request.requestDate)}'),
              SizedBox(height: 5),

              if (request.status == 'قيد التنفيذ') ...{
                Text('تاريخ بدء التنفيذ: ${_formatDate(request.inprogressDate)}'),
                SizedBox(height: 5),
              },

              if (request.status == 'تم التنفيذ' || request.status == 'مرفوض') ...{
                Text('تاريخ انهاء التنفيذ: ${_formatDate(request.responseDate)}'),
                SizedBox(height: 5),

              },
                
              Text('حجم الحاوية: ${request.garbageSize ?? 'غير محدد'}'),
              SizedBox(height: 5),
              Text('سبب الطلب: ${request.requestReason ?? 'غير محدد'}'),
              
              if (request.status == 'مرفوض' || request.status == 'تم التنفيذ')
                Directionality(
                  textDirection: TextDirection.rtl, 
                  child: Text(
                  'تعليق الموظف: ${request.staffComment ?? 'لا يوجد تعليق'}',
                  ),
                ),
            ],
          ),
        ),
        actions: [
          if (request.status == 'جديد') ...[
            Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showDeleteConfirmationDialog(request);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text(
                      'حذف ',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: GoogleFonts.balooBhaijaan2().fontFamily,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    },
  );
}

void _showDeleteConfirmationDialog(garbage_bin_requests request) {

    ConfirmationDialog.show(
      context,
      "حذف الطلب",
      "هل أنت متأكد أنك تريد حذف هذا الطلب؟",
      () async {
        await _db.deleteGarbageBinRequest(request);
        if (mounted) {
          SuccessMessageDialog.show(
            context,
            "تم حذف الطلب بنجاح",
            '/view_requests',
          );
        }
      },
    );
  }

// format request Date 
  String _formatDate(Timestamp? date) {
    return date != null
        ? '${date.toDate().year}-${date.toDate().month}-${date.toDate().day}'
        : '';
  }

}

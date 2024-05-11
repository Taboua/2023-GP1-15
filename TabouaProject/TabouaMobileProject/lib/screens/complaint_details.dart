// ignore_for_file: prefer_const_constructors, must_be_immutable, unnecessary_null_comparison, camel_case_types, sized_box_for_whitespace

//import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taboua_app/Services/complaints_database.dart';
import 'package:taboua_app/models/complaints.dart';
import 'package:taboua_app/screens/edit_complaint.dart';
import 'package:taboua_app/screens/view_location.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:transparent_image/transparent_image.dart';
import '../messages/confirm.dart';
import '../messages/success.dart';

class complaint_details extends StatefulWidget {
  complaints? complaint;
  String userId;
   complaint_details( { required this.userId, required this.complaint,super.key});

  @override
  State<complaint_details> createState() => _complaint_detailsState();
}

class _complaint_detailsState extends State<complaint_details> {
complaints_database complaintsDB = complaints_database();

// format complaint Date 
  String _formatDate(Timestamp? date) {
    return date != null
        ? '${date.toDate().year}-${date.toDate().month}-${date.toDate().day}'
        : '';
  }

 void _showDeleteConfirmationDialog(complaints complaint) {

    ConfirmationDialog.show(
      context,
      "تأكيد حذف البلاغ",
      "هل تريد حذف هذا البلاغ",
      () async {
        await complaintsDB.deleteComplaint(complaint);
        if (mounted) {
          SuccessMessageDialog.show(
            context,
            "تم حذف البلاغ بنجاح",
            '/view_complaints',
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
    backgroundColor: Colors.white,
    title: Text(
      "تفاصيل البلاغ",
      style: GoogleFonts.balooBhaijaan2(
        color: Colors.black,
        fontSize: 26,
      ),
    ),
  ),
   body: Padding(
        padding: EdgeInsets.all(20.0),
                 child: ListView(
                   children: [             
                    _buildTimelineTile(),

           //////// Constianer of complaint details         
          Container(
              decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
              alignment: Alignment.centerRight,
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Color(0xFF07512D),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'بيانات البلاغ',
                  style:  GoogleFonts.balooBhaijaan2(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
           
                 Padding(
                   padding: EdgeInsets.all(10.0),
                  child:Column(
                   crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                    _buildAttribute('رقم البلاغ', widget.complaint!.complaintNo , Colors.black),

                    _buildAttribute('نوع البلاغ', widget.complaint!.complaintType , Colors.black),

                    if(widget.complaint!.complaintType =="أخرى")
                         _buildAttribute('موضوع المشكلة', widget.complaint!.complaintSubject , Colors.black),
                        
                    _buildAttribute('وصف البلاغ', widget.complaint!.descrption , Colors.black),
                      
                    GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => view_location(location: LatLng(widget.complaint!.location!.latitude , widget.complaint!.location!.longitude),localArea :widget.complaint!.localArea.toString() , screenLable: "موقع البلاغ",)));
                       },
                    child: _buildAttribute('موقع البلاغ', widget.complaint!.localArea ,  Colors.blue,),
                      ),
                    
                    if(widget.complaint!.imagesOfUserComplaints !=null)
                     _buildImageList(widget.complaint!.imagesOfUserComplaints),
                                        
                     if(widget.complaint!.imagesOfUserComplaints.isEmpty)
                       _buildAttribute('المرفقات', "لا توجد مرفقات" , Colors.red),

                  ],)
               
                ),
                   
                        

            ]),

            ),
                  ////// Edit and Delete Button when complaint is new
                  SizedBox(height: 20),
                  if(widget.complaint!.status =="جديد")
                  ElevatedButton(
                      onPressed: () {
                        
                        double latitude = widget.complaint!.location!.latitude;
                        double longitude = widget.complaint!.location!.longitude;
                        
                          // Convert GeoPoint to LatLng
                         LatLng latLng = LatLng(latitude, longitude);
                        
                       Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => edit_complaint(complaint:widget.complaint! , userId:widget.userId , updatedLocation: latLng),
                            ));
                      },
                      
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ), 
                        backgroundColor: Color(0xFF97B980),
                        padding: EdgeInsets.all(10),
                        minimumSize: Size(100, 40),
                        elevation: 0,
                      ),
                      child: Text(
                        "تعديل البلاغ",
                        style: GoogleFonts.balooBhaijaan2(
                          textStyle: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                        
                   SizedBox(height: 20),
                    if(widget.complaint!.status =="جديد")
                     ElevatedButton(
                      onPressed: () {
                       _showDeleteConfirmationDialog(widget.complaint!);
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ), 
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.all(10),
                        minimumSize: Size(100, 40),
                        elevation: 0,
                      ),
                      child: Text(
                        "حذف البلاغ",
                        style: GoogleFonts.balooBhaijaan2(
                          textStyle: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  

            ////// show staff comment and image if responnse when the complaint is done or rejectd
            if(widget.complaint!.status == "تم التنفيذ" || widget.complaint!.status == "مرفوض")
             Container(
              decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            
            child: Column(     
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if(widget.complaint!.status == "تم التنفيذ")
                Container(
              alignment: Alignment.centerRight,
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Color(0xFF97B980),
                  borderRadius: BorderRadius.circular(10),
                ),
                
                child: Text(
                  "تفاصيل تنفيذ البلاغ",
                  style:  GoogleFonts.balooBhaijaan2(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              )
              else 
                Container(
              alignment: Alignment.centerRight,
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Color(0xFFFE5500),
                  borderRadius: BorderRadius.circular(10),
                ),
                
                child: Text(
                  "تفاصيل رفض البلاغ",
                  style:  GoogleFonts.balooBhaijaan2(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
          Padding(
         padding: EdgeInsets.all(10.0),
         child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [

         if(widget.complaint!.status == "تم التنفيذ" ||widget.complaint!.status == "مرفوض" )
                       _buildAttribute('تعليق الموظف', widget.complaint!.staffResponse , Colors.black),
                    
                       if((widget.complaint!.status == "تم التنفيذ"|| widget.complaint!.status == "مرفوض") && widget.complaint!.ImagesOfStaffResponse!=null)
                           _buildImageList(widget.complaint!.ImagesOfStaffResponse),
                       
                      if((widget.complaint!.status == "تم التنفيذ"|| widget.complaint!.status == "مرفوض") && widget.complaint!.ImagesOfStaffResponse.isEmpty)
                           _buildAttribute('المرفقات', "لا توجد مرفقات" , Colors.red),


         ]),
            
          ),
          
            ]),
            
            ),          
                  ],
                ),
        ),
    );
  }

///////// Timeline Widget
  Widget _buildTimelineTile() {
  return SizedBox(
    height: 100,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // last indicator
        if(widget.complaint!.status == "مرفوض" || widget.complaint!.status == "تم التنفيذ")
        Expanded(
          child: TimelineTile(
            axis: TimelineAxis.horizontal,
            alignment: TimelineAlign.manual,
            lineXY: 0.2,
            isFirst: true,
            isLast: false,
            indicatorStyle: IndicatorStyle(
              width: 30,
              height: 30,
              indicator: _buildIndicator(widget.complaint!.status.toString()), // circle indctor
            ),
            
            endChild: _buildStatus(widget.complaint!.status.toString()), // show status
          ),
        )
        else
         Expanded(
          child: TimelineTile(
            axis: TimelineAxis.horizontal,
            alignment: TimelineAlign.manual,
            lineXY: 0.2,
            isFirst: true,
            isLast: false,
            indicatorStyle: IndicatorStyle(
              width: 30,
              height: 30,
              indicator: _buildIndicator("انتهاء التنفيذ"),
            ),
            
            endChild: _buildStatus("انتهاء التنفيذ"),
          ),
        ),
       /// Middle Indictor
       if(widget.complaint!.inprogressDate !=null || widget.complaint!.status!="مرفوض")
        Expanded(
          child: TimelineTile(
            axis: TimelineAxis.horizontal,
            alignment: TimelineAlign.manual,
            lineXY: 0.2,
            isFirst: false,
            isLast: false,
            indicatorStyle: IndicatorStyle(
              width: 30,
              height: 30,
              indicator: _buildIndicator("قيد التنفيذ"),
            ),
            endChild: _buildStatus("قيد التنفيذ"),
          ),
        ),
        // First Indcitor on the right
         Expanded(
          child: TimelineTile(
            axis: TimelineAxis.horizontal,
            alignment: TimelineAlign.manual,
            lineXY: 0.2,
            isFirst: false,
            isLast: true,
            indicatorStyle: IndicatorStyle(
              width: 30,
              height: 30,
              indicator: _buildIndicator("جديد"),
            ),
            endChild: _buildStatus("جديد"),
          ),
        ),
      ],
    ),
  );
}
   /// Show color of indicator based on status
   
    Widget _buildIndicator(String status) {
    Color CurrentIndicatorColor = Colors.grey;

  ///// Color of Current Status
   if (status == widget.complaint!.status && widget.complaint!.status!="مرفوض") {
    CurrentIndicatorColor= Color(0xFF97B980); // Green color
  }
  /// Light grey color for next steps when current status is New
  if(status == "قيد التنفيذ" && widget.complaint!.status=="جديد") {
   CurrentIndicatorColor = Color(0xFFD6D6D6);
  }
  if(status == "انتهاء التنفيذ" && widget.complaint!.status=="جديد") {
   CurrentIndicatorColor = Color(0xFFD6D6D6);
  }

  if(status == "انتهاء التنفيذ" && widget.complaint!.status=="قيد التنفيذ") {
   CurrentIndicatorColor = Color(0xFFD6D6D6);
  }
  else if (status == "مرفوض") {
        CurrentIndicatorColor= Color(0xFFFE5500); // Green color
  }
   return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: CurrentIndicatorColor,
          ),
        );
  }

  /// Show dates based on cuurent status
  Widget _buildStatus(String status) {
  return Column(
    children:[
   Text( 
    status,
    style: GoogleFonts.balooBhaijaan2(
      fontSize: 14,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
    ),
    if(status == "جديد")
   Text( 
    _formatDate(widget.complaint!.complaintDate),
    style: TextStyle(
      fontSize: 12,
    ),
    ),

    if(status == "قيد التنفيذ")
   Text( 
    _formatDate(widget.complaint!.inprogressDate),
    style: TextStyle(
      fontSize: 12,
    ),
    ),
    if(status == "تم التنفيذ" ||status == "مرفوض")
   Text( 
    _formatDate(widget.complaint!.responseDate),
    style: TextStyle(
      fontSize: 12,
    ),
    ),
    ]
   
  );
}

///// Show list of complaint detailes
  Widget _buildAttribute(String label, var value , Color color) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.balooBhaijaan2(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: color,
              ),
            ),
          ],
          
        ),
      ),
    );
  }
  ///// Show list of images 
   Widget _buildImageList(List<String> imageUrls) {
    if(imageUrls !=null && imageUrls.isNotEmpty){
     return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'المرفقات',
              style: GoogleFonts.balooBhaijaan2(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Container(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) => _buildImageItem(imageUrls[index]),
                separatorBuilder: (context, index) => SizedBox(width: 8),
                itemCount: imageUrls.length,
              ),
            ),
          ],
        ),
      ),
    );
    }
    else{
      return Container();
    }
   
  }
  /// To create view image option on dialog by call _showImageDialog
  Widget _buildImageItem(String imageUrl) {
    return GestureDetector(
      onTap: () {
        _showImageDialog(imageUrl);
      },
      child: Container(
        width: 80,
        height: 80,
       child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: imageUrl,
              ),
       
      ),
    );
  }
///// Create Dialog for image view
void _showImageDialog(String imageUrl) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: Stack(
          children: [
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: Icon(
                  Icons.cancel,
                  size: 30,
                  
                  ),
                color: Colors.white,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
}

 
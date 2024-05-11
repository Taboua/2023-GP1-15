import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taboua_app/Services/garbage_bin_requestDB.dart';
import 'package:taboua_app/screens/view_location.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../messages/confirm.dart';
import '../messages/success.dart';
import '../models/garbage_bin_requests.dart';
import 'edit_request.dart';

class requested_bin_details extends StatefulWidget {
  garbage_bin_requests? garbageBinRequest;
    String userId;

  requested_bin_details({super.key , required this.garbageBinRequest , required this.userId});

  @override
  State<requested_bin_details> createState() => _requested_bin_detailsState();
}

class _requested_bin_detailsState extends State<requested_bin_details> {
garbage_bin_requestDB garbageBinDB = garbage_bin_requestDB();

// format complaint Date 
  String _formatDate(Timestamp? date) {
    return date != null
        ? '${date.toDate().year}-${date.toDate().month}-${date.toDate().day}'
        : '';
  }


   void _showDeleteConfirmationDialog(garbage_bin_requests request) {

    ConfirmationDialog.show(
      context,
      "تأكيد حذف الطلب",
      "هل تريد حذف هذا الطلب",
      () async {
        await garbageBinDB.deleteGarbageBinRequest(request);
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

  
   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
    backgroundColor: Colors.white,
    title: Text(
      "تفاصيل الطلب",
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

           //////// Constianer of request details         
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
                  'بيانات الطلب',
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
                    _buildAttribute('رقم الطلب', widget.garbageBinRequest!.requestNo , Colors.black),

                    _buildAttribute('حجم الحاوية', widget.garbageBinRequest!.garbageSize , Colors.black),

                        
                    _buildAttribute('سبب الطلب', widget.garbageBinRequest!.requestReason , Colors.black),
                      
                    GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => view_location(location: LatLng(widget.garbageBinRequest!.location!.latitude , widget.garbageBinRequest!.location!.longitude),localArea :widget.garbageBinRequest!.localArea.toString() , screenLable: "موقع الطلب",)));
                       },
                    child: _buildAttribute('موقع الطلب', widget.garbageBinRequest!.localArea ,  Colors.blue,),
                      ),
                  ],)
               
                ),
                   
                        

            ]),

            ),
                  ////// Edit and Delete Button when request is new
                  SizedBox(height: 20),
                  if(widget.garbageBinRequest!.status =="جديد")
                  ElevatedButton(
                      onPressed: () {
                        
                        double latitude = widget.garbageBinRequest!.location!.latitude;
                        double longitude = widget.garbageBinRequest!.location!.longitude;
                        
                          // Convert GeoPoint to LatLng
                         LatLng latLng = LatLng(latitude, longitude);
                        
                       Navigator.of(context).push(MaterialPageRoute(
                             builder: (context) => edit_request(userId: widget.userId,request:widget.garbageBinRequest! , updatedLocation: latLng,),
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
                        "تعديل الطلب",
                        style: GoogleFonts.balooBhaijaan2(
                          textStyle: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                        
                   SizedBox(height: 20),
                    if(widget.garbageBinRequest!.status =="جديد")
                     ElevatedButton(
                      onPressed: () {
                       _showDeleteConfirmationDialog(widget.garbageBinRequest!);
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
                        "حذف الطلب",
                        style: GoogleFonts.balooBhaijaan2(
                          textStyle: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  

            ////// show staff comment and image if responnse when the request is done or rejectd
            if(widget.garbageBinRequest!.status == "تم التنفيذ" || widget.garbageBinRequest!.status == "مرفوض")
             Container(
              decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            
            child: Column(     
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if(widget.garbageBinRequest!.status == "تم التنفيذ")
                Container(
              alignment: Alignment.centerRight,
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Color(0xFF97B980),
                  borderRadius: BorderRadius.circular(10),
                ),
                
                child: Text(
                  "تفاصيل تنفيذ الطلب",
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
                  "تفاصيل رفض الطلب",
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

         if(widget.garbageBinRequest!.status == "تم التنفيذ" ||widget.garbageBinRequest!.status == "مرفوض" )
            _buildAttribute('تعليق الموظف', widget.garbageBinRequest!.staffComment?? "", Colors.black), 

          if(widget.garbageBinRequest!.status == "تم التنفيذ")
             _buildAttribute('حجم الحاوية المنفذ', widget.garbageBinRequest!.SelectedGarbageSize?? "" , Colors.black),

          if(widget.garbageBinRequest!.status == "تم التنفيذ")
                GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => view_location(location: LatLng(widget.garbageBinRequest!.location!.latitude , widget.garbageBinRequest!.location!.longitude),localArea :widget.garbageBinRequest!.localArea.toString(), screenLable: "موقع الطلب",)));
                       },
                    child: _buildAttribute('موقع الحاوية المنفذ', widget.garbageBinRequest!.newlocalArea?? "" , Colors.blue) ,

                      ),

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
        if(widget.garbageBinRequest!.status == "مرفوض" || widget.garbageBinRequest!.status == "تم التنفيذ")
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
              indicator: _buildIndicator(widget.garbageBinRequest!.status.toString()), // circle indctor
            ),
            
            endChild: _buildStatus(widget.garbageBinRequest!.status.toString()), // show status
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
   if (status == widget.garbageBinRequest!.status && widget.garbageBinRequest!.status!="مرفوض") {
    CurrentIndicatorColor= Color(0xFF97B980); // Green color
  }
  /// Light grey color for next steps when current status is New
  if(status == "قيد التنفيذ" && widget.garbageBinRequest!.status=="جديد") {
   CurrentIndicatorColor = Color(0xFFD6D6D6);
  }
  if(status == "انتهاء التنفيذ" && widget.garbageBinRequest!.status=="جديد") {
   CurrentIndicatorColor = Color(0xFFD6D6D6);
  }

  if(status == "انتهاء التنفيذ" && widget.garbageBinRequest!.status=="قيد التنفيذ") {
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
    _formatDate(widget.garbageBinRequest!.requestDate),
    style: TextStyle(
      fontSize: 12,
    ),
    ),

    if(status == "قيد التنفيذ")
   Text( 
    _formatDate(widget.garbageBinRequest!.inprogressDate),
    style: TextStyle(
      fontSize: 12,
    ),
    ),
    if(status == "تم التنفيذ" ||status == "مرفوض")
   Text( 
    _formatDate(widget.garbageBinRequest!.responseDate),
    style: TextStyle(
      fontSize: 12,
    ),
    ),
    ]
   
  );
}
///// Show list of request detailes
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

}
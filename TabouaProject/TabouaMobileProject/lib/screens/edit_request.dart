// ignore_for_file: library_private_types_in_public_api, prefer_final_fields, use_build_context_synchronously, prefer_const_constructors, sized_box_for_whitespace, prefer_collection_literals, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taboua_app/Services/garbage_bin_requestDB.dart';
import 'package:taboua_app/messages/success.dart';
import 'package:taboua_app/models/garbage_bin_requests.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taboua_app/screens/edit_request_location.dart';
import '../Services/address_request.dart';

enum garbageBinSize {
  smallSize('حاوية صغيرة'),
  largeSize('حاوية كبيرة');

  const garbageBinSize(this.label);
  final String label;
}
class edit_request extends StatefulWidget {
  final garbage_bin_requests request;
    String userId;
   LatLng?updatedLocation;
   edit_request({required this.userId, Key? key, required this.request  ,  required this.updatedLocation}) : super(key: key);

  @override
  _edit_requestState createState() => _edit_requestState();
}

class _edit_requestState extends State<edit_request> {
  TextEditingController _reasonController = TextEditingController();
  LatLng? selectedLocation;
  String? address ;
  garbageBinSize? selectedType; // selected complaints type by user
  String?errorComplaintType;
  String? requestReason;
  String?errorRequestReason;
  bool? validated;  
final TextEditingController requestController = TextEditingController();
final TextEditingController requestReasonController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _reasonController.text = widget.request.requestReason ?? '';
    selectedLocation = widget.request.location != null
        ? LatLng(
            widget.request.location!.latitude,
            widget.request.location!.longitude,
          )
        : null;

         selectedType = fromString(widget.request.garbageSize);
    requestReasonController.text = widget.request.requestReason!;
     requestReason = widget.request.requestReason ;
     address = widget.request.localArea;
  }
   static garbageBinSize fromString(String? typeString) {
    switch (typeString) {
      case 'حاوية صغيرة':
        return garbageBinSize.smallSize;
      case 'حاوية كبيرة':
        return garbageBinSize.largeSize;
        default:
        return garbageBinSize.smallSize; // Default value  
  }
   }

   String _formatDate(Timestamp? date) {
    return date != null
        ? '${date.toDate().year}-${date.toDate().month}-${date.toDate().day}'
        : '';
  }

 Future<void> user_address (BuildContext context , LatLng position) async {
String current_address = await addressRequest.searchCoordinateAddress(position, context); // get address from address_request class
setState(() {
  address = current_address;
});
}

// function will validate user inputs
void _validateRequest() {
  
  if (requestReasonController == null  || requestReason!.isEmpty || requestReason!.trim().isEmpty) {
    setState(() {
    errorRequestReason = "يرجى إدخال تفاصيل الطلب";
    validated = false;

   });
  }
  else{
    setState(() {
   errorRequestReason = null;
   validated = true;

   });

  }
 
  }

  void updateRequest() async {
  _validateRequest();
setState(() {
   if(validated == true){
// Request instnace of garbage_bin_requestDB  class
garbage_bin_requestDB  requestDB = garbage_bin_requestDB();

String? requestId = widget.request.id;
// request data
final requestData = {
  'location': GeoPoint(
  widget.updatedLocation!.latitude,
  widget.updatedLocation!.longitude
),
'localArea': address,
'garbageSize' : selectedType!.label,
'requestReason': requestReason != null? requestReason : widget.request.requestReason
};

// update request on DB
requestDB.updateRequest(requestData , requestId!); // add to firebase

 if (mounted) {
          SuccessMessageDialog.show(
            context,
            "تم حفظ تغييرات الطلب بنجاح",
            '/view_requests',
          );
        }
  }
});
}
@override
  Widget build(BuildContext context) {
   double dropdownWidth = MediaQuery.of(context).size.width - 35;  // take the width of screen and the - 35

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
   body: GestureDetector(
     onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
     child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 17),
          child: ListView(
            children: [
              _buildAttribute('رقم الطلب', widget.request.status),
              _buildAttribute('تاريخ الطلب', _formatDate(widget.request.requestDate)),
              _buildAttribute('حالة الطلب', widget.request.status),
              
             _buildAttribute('حجم الحاوية',''),
   
        Directionality(
          textDirection: TextDirection.rtl,
            child: 
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 1),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
                 children: [ 
                DropdownMenu<garbageBinSize>(
                width:dropdownWidth ,
                  controller: requestController,
                  requestFocusOnTap: false,
                  label: Text('${widget.request.garbageSize}'),
                  onSelected: (garbageBinSize? type) {
                    setState(() {
                      selectedType = type;
                      errorComplaintType= null;
                    });
                  },
                  dropdownMenuEntries: garbageBinSize.values
                    .map<DropdownMenuEntry<garbageBinSize>>(
                      (garbageBinSize type) {
                        return DropdownMenuEntry<garbageBinSize>(
                          value: type,
                          label: type.label,
                          style: MenuItemButton.styleFrom(
                            foregroundColor: type == selectedType ? Color(0xFF97B980) : Colors.black,
                          fixedSize:Size.fromWidth(double.infinity),
                          ),
                        );
                      },
                    ).toList(),
                  menuHeight: 250,
                ),   
           ],
          ),
          ),
   
            ),
       
   
      _buildAttribute('سبب الطلب',''),
       
     Column(
      children:[
      Directionality(
      textDirection: TextDirection.rtl,
      child: TextField(
        controller: requestReasonController,
        onChanged: (text) {
          setState(() {
            requestReason = text ;
            _validateRequest();
          });
        },
        decoration: InputDecoration(
          labelText: 'سبب الطلب',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.multiline,
        maxLines: 2,
        maxLength: 70,
      ),
     ),
      Padding(
       padding: const EdgeInsets.only(top: 0 , right: 10),
       child: Align(
               alignment: Alignment.centerRight,
               child: Text(
               errorRequestReason?? '',
              style: TextStyle(color: Colors.red),
              ),
            ),
          ),
      ],
     ),
   
   
         _buildAttribute('موقع الطلب',address),
   
         Directionality(
          textDirection:TextDirection.rtl, 
          child:  GestureDetector(
                  onTap: () async {
                    
                  LatLng newLocation = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => edit_request_location(userId: widget.userId, request: widget.request , address: address,),
                      ),
                    );
                    user_address(context, LatLng(newLocation.latitude, newLocation.longitude));
                    widget.updatedLocation = newLocation;
                    
                  },
                  child: Text(
                    "تغيير الموقع",
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: 'BalooBhaijaan2',
                      color: Colors.blue,
                    ),
                  ),
                ),
           ),
   
       SizedBox(height: 20,) ,
   
     ElevatedButton(
                onPressed: () {
                    updateRequest();
                },
                
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ), 
                  backgroundColor: Color(0xFF07512D),
                  padding: EdgeInsets.all(10),
                  minimumSize: Size(100, 40),
                  elevation: 0,
                ),
                child: Text(
                  "حفظ التغييرات",
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
   ),

    );
  }
  /// Widget to  style the complaint info 
  Widget _buildAttribute(String label, var value) {
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
              value ?? "",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
}

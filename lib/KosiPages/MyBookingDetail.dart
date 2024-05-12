import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:kosiservice/KosiPages/TrackingKosiHelper.dart';
import 'package:kosiservice/Utils/Toast.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:order_tracker_zen/order_tracker_zen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../KosiWidget/DashedDivider.dart';
import '../Utils/AppColors.dart';
import '../Utils/CustomTracker.dart';
import '../Utils/KosiHelperModels.dart';
import 'dart:io';

import '../Utils/Pagerouter.dart';
import 'SubCateogoryServiceList.dart';
User? user = FirebaseAuth.instance.currentUser;
String? phoneNumber = user?.phoneNumber.toString().substring(3, 13);


class MyBookingDetailsScreen extends StatefulWidget {

  final String bookingkey;
  final String helperid;
  final String Status;
  final String name,address,phone,bookingid,bookingdate,bookingtime,paymentoption,transid,dues,location;

  MyBookingDetailsScreen({
    required this.bookingkey,
    required this.helperid,
    required this.Status,
    required this.name,
    required this.address,
    required this.phone, required this.bookingid, required this.bookingdate, required this.bookingtime, required this.paymentoption,
    required this.transid,
    required this.dues,
    required this.location,
  });

  @override
  State<MyBookingDetailsScreen> createState() => _MyBookingDetailsScreenState();
}


late DatabaseReference serviceref,additionalserviceref;
Helper? helpermodel;
int cartcontainerheight=0;
late  BookingStatus Status;


class _MyBookingDetailsScreenState extends State<MyBookingDetailsScreen> {
  late Map<String, dynamic> additionalservicedata = {};
  late Map<String, dynamic> servicedata;
  late List<TrackerData> generatedTrackerData;
  double totalservicevalue=0;
  double taxandvalue=0;
  double totalvisitingcharge=0;
  double additionalcharge=0;
  late List<String> servicereflist = [];


  Future<int> serviceitemlistcount() async {
    try {
      final snapshot = await serviceref.once();
      if (snapshot.snapshot.value != null) {
        if (snapshot.snapshot.value is Map<dynamic, dynamic>) {
          // Convert snapshot.snapshot.value to Map<String, dynamic>
          servicedata = Map<String, dynamic>.from(snapshot.snapshot.value as Map<dynamic, dynamic>);
          final data = snapshot.snapshot.children;
          int itemcount = data.length ?? 0;
          setState(() {
            cartcontainerheight = itemcount * 130;
          });
          print('$servicedata');
          return itemcount;
        } else {
          // Handle if the value is not of type Map<dynamic, dynamic>
          print('Value is not of type Map<dynamic, dynamic>');
          return 0;
        }
      } else {
        return 0;
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      return 0;
    }
  }

  Future<void> additionalserviceitemlist() async {
    try {
      additionalserviceref.onValue.listen((event) {
        additionalservicedata = {};
        additionalcharge = 0;
        if (event.snapshot.value != null) {
          if (event.snapshot.value is Map<dynamic, dynamic>) {
            Map<String, dynamic> data = Map<String, dynamic>.from(event.snapshot.value as Map<dynamic, dynamic>);
            additionalservicedata = data;

            // Calculate total additional charge
            data.forEach((key, value) {
              additionalcharge += double.parse(value['itemprice'].toString());
            });

            setState(() {
              // Update UI if necessary
            });

            print(additionalcharge);
            print(additionalservicedata);
          } else {
            print('Value is not of type Map<dynamic, dynamic>');
          }
        }
      });
    } catch (e) {
      debugPrint('Error fetching additional services data: $e');
    }
  }


  void getKosiHelper(String helperid) {
    DatabaseReference userRef = FirebaseDatabase.instance.reference().child('KosiService/KosiHelper/$helperid');
    userRef.onValue.listen((event) {
      final udata = event.snapshot.value;
      if (udata != null) {
        Map<dynamic, dynamic> value = udata as Map<dynamic, dynamic>;
        setState(() {

          helpermodel = Helper(
            accountType: value['accountype'],
            helperAge: value['helperage'],
            helperDeviceId: value['helperdeviceid'],
            helperId: value['helperid'],
            helperLatitude: value['helperlatitiude'],
            helperLongitude: value['helperlongitude'],
            helperName: value['helpername'],
            helperPhone: value['helperphone'],
            helperPic: value['helperpic'],
            helperUid: value['helperuid'],
            helperWorkCount: value['helperworkcount'],
            helperJoinDate: value['helperjoindate'],
          );
          print(value['helperlongitude']);
        });
      }
    }
    );

  }

  @override
  void initState() {
    serviceref = FirebaseDatabase.instance.ref('KosiService/User/$phoneNumber/mybooking').child(widget.bookingkey).child('Services');
    additionalserviceref=FirebaseDatabase.instance.ref('KosiService/User/$phoneNumber/mybooking').child(widget.bookingkey).child('additionalServices');

    serviceitemlistcount().then((value) {
      servicedata = Map<String, dynamic>.from(servicedata);
    });
    additionalserviceitemlist();
    getPaymentSummary();
    switch (widget.Status) {
      case "Pending":
        Status = BookingStatus.pending;
        generatedTrackerData =TrackerGenerator.generateTrackerData(BookingStatus.pending);
        break;
      case "Confirm":
        Status = BookingStatus.confirm;
        generatedTrackerData =TrackerGenerator.generateTrackerData(BookingStatus.confirm);
        break;
      case "Out for Service":
        Status = BookingStatus.outForService;
        generatedTrackerData =TrackerGenerator.generateTrackerData(BookingStatus.outForService);
        break;

      case "Started":
        Status = BookingStatus.started;
        generatedTrackerData = TrackerGenerator.generateTrackerData(BookingStatus.started);
        break;

      case "Service Done":
        Status = BookingStatus.serviceDone;
        generatedTrackerData = TrackerGenerator.generateTrackerData(BookingStatus.serviceDone);
        break;

      case "Canceled":
        Status = BookingStatus.canceled;
        generatedTrackerData = TrackerGenerator.generateTrackerData(BookingStatus.canceled);
        break;
    }


    generatedTrackerData = TrackerGenerator.generateTrackerData(Status);
    super.initState();

    helpermodel=null;
    getKosiHelper(widget.helperid);

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text('My Booking Details',style: TextStyle(color: Colors.white),),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10,top: 4),
              child: Text('Services',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 15),),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10,right: 10,top: 5),
              child:  Container(height:cartcontainerheight.toDouble(), child: ServiceList()),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 4),
              child: additionalservicedata.isNotEmpty
                  ? Text(
                'Additional',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              )
                  : SizedBox(),
            ),
            // Show additional services
            if (additionalservicedata.isNotEmpty)
              Column(
                children: additionalservicedata.entries.map((entry) {
                  String itemName = entry.value['itemname'];
                  dynamic itemPrice = entry.value['itemprice'];

                  return Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15,right: 15,top: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(itemName,style: TextStyle(fontSize: 14,color: Colors.black54,fontWeight: FontWeight.bold),),
                          Text('₹$itemPrice',style: TextStyle(fontSize: 13,color: Colors.black,fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),


            PaymentSummary(),
            Card(
              surfaceTintColor: Colors.white,
              elevation: 1,
              margin: EdgeInsets.all(8),
              child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Booking Status',style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold,fontSize: 15),),
                      SizedBox(height: 8,),
                      OrderTrackerZen(
                        tracker_data: generatedTrackerData,
                      ),
                    ],
                  )
              ),
            ),


            Card(
              elevation: 1,
              margin: EdgeInsets.all(8),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kosi Partner',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                    Row(
                      children: [
                        Image.network(helpermodel?.helperPic??'https://firebasestorage.googleapis.com/v0/b/firstandfast-781dd.appspot.com/o/kosihero.png?alt=media&token=93564811-6e0d-410d-8f11-db4749df0081', width: 90,
                            height: 90),
                        SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(helpermodel?.helperName ?? 'No helper Assign',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: AppColors.primaryColor)),
                              Text(helpermodel?.accountType ?? 'No helper Assign',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                      color: Colors.indigo)),
                              Text("Age:-"+(helpermodel?.helperAge ?? 'N/A'),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                      color: Colors.indigo)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextButton(
                            onPressed: () {

                              if (widget.Status != 'Service Done') {

                                if(widget.Status=='Out for Service'){
                                  if (helpermodel != null) {
                                    List<String> locationParts = widget.location.split(',');
                                    double latitude = double.parse(locationParts[0]);
                                    double longitude = double.parse(locationParts[1]);
                                    LatLng destination = LatLng(latitude, longitude);

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TrackingKosiHelper(
                                          helperid: widget.helperid,
                                          destination: destination,
                                        ),
                                      ),
                                    );
                                  } else {
                                    ToastWidget.showToast(context, 'No Partner assigned');
                                  }
                                }else{
                                  ToastWidget.showToast(context, 'Kosi Partner not out for service');
                                }

                              } else {
                                ToastWidget.showToast(context, 'Not allowed after service done');
                              }
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: AppColors.primaryColor,
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            ),
                            child: Text(
                              'Track',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {

                            _makePhoneCall(helpermodel!.helperPhone);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white, backgroundColor: AppColors.primaryColor,
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                          ),
                          child: Text(
                            'call',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            BookingAddrerss(),
            review(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () async {
                   showLoadingAlert(context, 'Wait, bill is generating');
                      final pdfBytes = await generatePDF(
                        bookingdate: widget.bookingdate,
                        paymentoption: widget.paymentoption,
                        bookingtime: widget.bookingtime,
                        bookingid: widget.bookingid,
                        bookingaddress: widget.address,
                        username: widget.name,
                        userphone: widget.phone,
                        transcationid: widget.transid,
                        bookingtotalprice:' ${(totalvisitingcharge+taxandvalue+totalservicevalue +additionalcharge).toStringAsFixed(2)}',
                         servicedata: servicedata,
                      );

                      if (kIsWeb) {
                        ToastWidget.showToast(context, 'Invoice generation only available on App');
                      } else {
                        savePdf(pdfBytes,'file' );
                      }
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: AppColors.primaryColor,
                      padding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                    ),
                    child: Text(
                      'Generate Invoice',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ToastWidget.showToast(context, 'contact to kosi service');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black, backgroundColor: Colors.grey,
                    padding: EdgeInsets.all(10),
                  ),
                  child: Text(
                    'Cancel Booking',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10,)
          ],
        ),
      ),
    );
  }
  Widget review() {
    TextEditingController reviewController = TextEditingController();
    String ratingCount = '5.0'; // Default rating count
    DateTime currentDate = DateTime.now();
    String formattedDate = DateFormat('dd/MMM/yyyy').format(currentDate);
    bool isLoading = false; // State variable to track loading state

    return Card(
      elevation: 1,
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Write Review', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            TextField(
              controller: reviewController, // Set the text controller
              decoration: InputDecoration(
                hintText: 'I highly recommend this app for anyone in need of reliable and high-quality service providers.',
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              maxLength: 50,
              minLines: 2,
              maxLines: null,
            ),
            Text('Note - Review can only be posted if service is done.', style: TextStyle(fontSize: 10, color: Colors.grey)),
            RatingBar(
              onRatingChanged: (double rating) {
                ratingCount = rating.toString(); // Update the rating count when it changes
              },
              filledIcon: Icons.star,
              emptyIcon: Icons.star_border,
              halfFilledIcon: Icons.star_half,
              isHalfAllowed: true,
              filledColor: Colors.yellow,
              emptyColor: Colors.grey,
              halfFilledColor: Colors.yellow,
              size: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () async {
                    // Show loading indicator
                    setState(() {
                      isLoading = true;
                    });

                    if (reviewController.text.isNotEmpty) {
                      // Iterate through the servicereflist and post the review for each service
                      for (int i = 0; i < servicereflist.length; i++) {
                        DatabaseReference serviceRef = FirebaseDatabase.instance.ref(servicereflist[i]);
                        await serviceRef.child('reviews').push().set({
                          "rating": ratingCount,
                          "reviewdate": formattedDate,
                          "reviewmsg": reviewController.text, // Use the text from the controller
                          "uid": user!.uid.toString(),
                          "username": widget.name,
                          "userphone": phoneNumber,
                        });
                      }

                      // Clear the text field
                      reviewController.clear();
                      ratingCount = '5.0';

                      // Dismiss loading indicator
                      setState(() {
                        isLoading = false;
                      });

                      // Show toast
                      ToastWidget.showToast(context, 'Review posted');
                    } else {
                      // Dismiss loading indicator
                      setState(() {
                        isLoading = false;
                      });

                      // Show error toast
                      ToastWidget.showToast(context, 'Review message cannot be empty');
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: AppColors.primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  ),
                  child: isLoading ? CircularProgressIndicator() : Text(
                    'Post',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }



  Widget ServiceList() {
    servicereflist.clear();
    return FirebaseAnimatedList(
      scrollDirection: Axis.vertical,
      query:serviceref,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, snapshot, animation, index) {
        String Servicetitle = snapshot.child('Servicetitle').value.toString();
        String Servicevisitingcharge = snapshot.child('Servicevisitingcharge').value.toString();
        String Serviceslot = snapshot.child('Serviceslot').value.toString();
        int quantity = int.parse(snapshot.child('Serviceqty').value.toString());
        String Serviceimg = snapshot.child('Serviceimg').value.toString();
        String Serviceid = snapshot.child('Serviceid').value.toString();
        String Servicegstcharge = snapshot.child('Servicegstcharge').value.toString();
        String Servicecharge = snapshot.child('Servicecharge').value.toString();
        String serviceref=snapshot.child('serviceref').value.toString();

        servicereflist.add('$serviceref/$Serviceid');
        return Container(
          height: 130,
          child: Card(
            margin: EdgeInsets.all(1),
            elevation: 0,
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Image.network(Serviceimg, width: 90, height: 90,),
                          SizedBox(width: 4,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Servicetitle.length <= 30 ? Servicetitle : '${Servicetitle.substring(0, 30)}...',
                                style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 2,),
                              Text('Slot- $Serviceslot', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 10),),
                              SizedBox(height: 4,),
                              Text('Service charges- ₹$Servicecharge', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black54, fontSize: 10)),
                              Text('Service qty- $quantity', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black54, fontSize: 10)),
                              Text('Service slot- $Serviceslot', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black54, fontSize: 10)),
                            ],
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  Widget PaymentSummary(){
    return Card(
      surfaceTintColor: Colors.white,
      elevation: 0.3,
      margin: EdgeInsets.all(4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payment Summary',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.black87),),
            SizedBox(height: 8,),
            Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children: [
              Text('Item total',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 14,color: Colors.black54),),
              Text('₹${totalservicevalue.toStringAsFixed(2)}'),
            ],),
            SizedBox(height: 8,),
            Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children: [
              Text('Visiting Charges',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 14,color: Colors.black54),),
              Text('₹${totalvisitingcharge.toStringAsFixed(2)}')

            ],),
            SizedBox(height: 8,),
            Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children: [
              Text('gst',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 14,color: Colors.black54),),
              Text('₹${taxandvalue.toStringAsFixed(2)}')

            ],),
            SizedBox(height: 10,),
            DashedDivider(),
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '₹${(totalvisitingcharge + totalservicevalue + taxandvalue+additionalcharge).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dues',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '-₹${double.parse(widget.dues)+additionalcharge}',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    color: Colors.red,
                  ),
                ),
              ],
            )


          ],
        ),
      ),
    );
  }
  getPaymentSummary() async {
    totalservicevalue=0;
    totalvisitingcharge=0;
    taxandvalue=0;
    final datasnap= await serviceref.get();
    Map<dynamic, dynamic> serviceitem = datasnap.value as Map<dynamic, dynamic>;
    String Servicecharge;
    String Servicegstcharge;
    String Serviceqty;
    String Servicevisitingcharge;

    serviceitem.forEach((key, value) async {
      Servicecharge = value['Servicecharge'].toString();
      Serviceqty = value['Serviceqty'].toString();
      Servicegstcharge = value['Servicegstcharge'].toString();
      Servicevisitingcharge = value['Servicevisitingcharge'].toString();
      double gstchargeoneach=((double.parse(Servicecharge)*double.parse(Servicegstcharge))/100)*int.parse(Serviceqty);
      setState(() {
        totalservicevalue+=(double.parse(Servicecharge)*int.parse(Serviceqty));
        totalvisitingcharge+=double.parse(Servicevisitingcharge);
        taxandvalue+=gstchargeoneach;

      });
    });
  }
  Widget BookingAddrerss(){
    return Container(
      width: double.infinity,
      child: Card(
        elevation: 0.3,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Service Address',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.black87),),
              SizedBox(height: 6,),
              Text('Name-${widget.name}',style: TextStyle(fontWeight: FontWeight.w400,fontSize: 14,color: Colors.black87),),
              SizedBox(height: 2,),
              Text('Mob-${widget.phone}',style: TextStyle(fontWeight: FontWeight.w400,fontSize: 13,color: Colors.black87),),
              SizedBox(height: 2,),

              Text(widget.address,style: TextStyle(fontWeight: FontWeight.w400,fontSize: 13,color: Colors.black87),),
              SizedBox(height: 8,),
            ],
          ),
        ),
      ),
    );
  }
  void _makePhoneCall(String phone) {
    final String phoneNumber = '$phone';
    if (widget.Status == 'Service Done') {
      final Uri phoneUri = Uri(scheme: 'tel', path: '7667538694');
      launch(phoneUri.toString());
    }else{
      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
      launch(phoneUri.toString());
    }


  }


  Future<Uint8List> fetchImageFromUrl(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load image');
    }
  }

  pw.Widget _buildInvoicePage(Uint8List imageBytes, {
    required String bookingdate,
    required String paymentoption,
    required String bookingtime,
    required String bookingid,
    required String bookingaddress,
    required String username,
    required String userphone,
    required String transcationid,
    required String bookingtotalprice,
    required  Map<String, Map<String, dynamic>> servicedata,
  }) {
    List<pw.Widget> serviceItems = [];
    List<pw.Widget> additionalserviceItems = [];
    final PdfColor lightGreen = PdfColor.fromInt(0xFF90EE90);
    servicedata.forEach((key, value) {
      String serviceTitle = value['Servicetitle'];
      String serviceQty = value['Serviceqty'].toString();
      String serviceCharge = value['Servicecharge'].toString();

      serviceItems.add(
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Container(

              width: 150, // Set the width of the container
              child: pw.Text(
                serviceTitle,
                style:  pw.TextStyle(fontSize: 10),
              ),
            ),

            pw.Container(

                width: 150, // Specify the desired width
                child: pw.Align(
                  alignment: pw.Alignment.center,
                  child:
                pw.Text(serviceQty, style: pw.TextStyle(fontSize: 10)),
                ),
              ),

             pw.Container(

                width: 150, // Specify the desired width
                child:
                pw.Align(
                  alignment: pw.Alignment.centerRight,child:pw.Text('$serviceCharge', style: pw.TextStyle(fontSize: 10)),
              ),
            ),



            pw.SizedBox(height: 3)
          ],
        ),
      );
    });
    additionalservicedata.forEach((key, value) {
      String itemTitle = value['itemname'];
      String itemprice = value['itemprice'].toString();

      additionalserviceItems.add(
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Container(
              width: 150, // Set the width of the container
              child: pw.Text(
                itemTitle,
                style:  pw.TextStyle(fontSize: 10),
              ),
            ),



            pw.Container(

              width: 150, // Specify the desired width
              child: pw.Align(
                alignment: pw.Alignment.center,
                child:
                pw.Text('1', style: pw.TextStyle(fontSize: 10)),
              ),
            ),
            pw.Container(
              width: 150, // Specify the desired width
              child:
              pw.Align(
                alignment: pw.Alignment.centerRight,child:pw.Text('$itemprice', style: pw.TextStyle(fontSize: 10)),
              ),
            ),

            pw.SizedBox(height: 3)
          ],
        ),
      );
    });

    return pw.Container(
      color: PdfColors.white,
      child: pw.ListView(
        children: [
          pw.Container(
            color:lightGreen ,
            child:pw.Padding(
              padding: pw.EdgeInsets.all(20),
                  child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                  pw.Text('INDPE KOSI SERVICE PRIVATE LIMITED \n U41002BR2024PTC066919', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Adarsh, Colony,Rd #01,khemnichak, Ram Krishna Nagar,\n Patna, Sampatchak, Bihar, India, 800027\n Mob-7667538694 \n www.kosiservice.com', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),

                ],

                ),
                pw.Container(
                  width: 50,
                  height: 50,
                  child: pw.Image(pw.MemoryImage(imageBytes)),
                ),

                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Order id: $bookingid', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Name: $username', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Mob: $userphone', style: pw.TextStyle(fontSize: 10)),
                    pw.Container(
                      width: 200,
                      child:  pw.Text(' ${widget.address}', style: pw.TextStyle(fontSize: 9)),
                    ),

                  ],
                ),
                pw.Divider()
              ],
            ),
            )


          ),



          pw.SizedBox(height: 25),
          pw.Text('Service Details:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Service Name', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('Quantity', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('Charges', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.Divider(),

          for (var item in serviceItems) item,
          pw.Divider(),
          pw.Align(
            alignment: pw.Alignment.topLeft,
            child: pw.Text('Additional:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          ),

          for (var item in additionalserviceItems) item,
          pw.Divider(),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text('Visiting Charges- Rs$totalvisitingcharge', style: pw.TextStyle(fontSize: 10)),
          ),
          pw.SizedBox(height: 6),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text('Taxes- Rs$taxandvalue', style: pw.TextStyle(fontSize: 10)),
          ),
          pw.SizedBox(height: 6),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text('Total Amount:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 12)),
              pw.SizedBox(width: 6),
              pw.Text('Rs ${(double.parse(bookingtotalprice)).toStringAsFixed(2)}', style: pw.TextStyle(color: PdfColors.black,fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text('dues:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 12)),
              pw.SizedBox(width: 6),
              pw.Text('Rs -${double.parse(widget.dues)+additionalcharge}', style: pw.TextStyle(color: PdfColors.black,fontWeight: pw.FontWeight.bold)),
            ],
          ),


          pw.SizedBox(height: 6),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('Payment Method: $paymentoption', style: pw.TextStyle(fontSize: 10)),
                pw.Text('Transaction ID: $transcationid', style: pw.TextStyle(fontSize: 10)),
              ],
            ),
          ),
          pw.SizedBox(height: 150),
          pw.Divider(),
          pw.Text('Terms and Conditions:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
          pw.Link(
            child: pw.Bullet(
              text: 'https://kosiservice.com/terms-condition.html',
              style: pw.TextStyle(fontSize: 8, color: PdfColors.blue),
            ),
            destination: 'https://kosiservice.com/terms-condition.html',
          ),
          pw.Link(
            child: pw.Bullet(
              text: 'https://kosiservice.com/Cancel-refund.html',
              style: pw.TextStyle(fontSize: 8, color: PdfColors.blue),
            ),
            destination: 'https://kosiservice.com/Cancel-refund.html',
          ),

          pw.SizedBox(height: 20),
          pw.Align(
            alignment: pw.Alignment.bottomRight,
            child: pw.Text('Kosiservice', style: pw.TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }


  Future<Uint8List> generatePDF(
      {required String bookingdate, required String paymentoption, required String bookingtime,
          required String bookingid, required String bookingaddress,
        required String username, required String userphone, required String transcationid, required
      String bookingtotalprice,required Map<String, dynamic> servicedata, // Change the parameter type
      }) async {
    // Convert servicedata to the required format
    Map<String, Map<String, dynamic>> convertedServicedata = {};
    servicedata.forEach((key, value) {
      convertedServicedata[key] = Map<String, dynamic>.from(value);
    });

    final pdf = pw.Document();

    final imageUrl = 'https://firebasestorage.googleapis.com/v0/b/firstandfast-781dd.appspot.com/o/logofirst.png?alt=media&token=6fc4ad08-0a6d-4c11-b9bd-2c425b4dd72a';
    final imageBytes = await fetchImageFromUrl(imageUrl);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.copyWith(
          marginBottom: 10,
          marginLeft: 30,
          marginRight: 30,
          marginTop: 10,
        ),
        build: (pw.Context context) {
          return _buildInvoicePage(
            imageBytes,
            bookingdate: bookingdate,
            paymentoption: paymentoption,
            bookingtime: bookingtime,
            bookingid: bookingid,
            bookingaddress: bookingaddress,
            username: username,
            userphone: userphone,
            transcationid: transcationid,
            bookingtotalprice: bookingtotalprice,
            servicedata: convertedServicedata, // Pass the converted servicedata
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<void> savePdf(Uint8List pdfBytes, String bookingid) async {

    final directory = await getDownloadsDirectory();
    final file = File(
        '${directory?.path}/invoice$bookingid.pdf'); // Specify the file path
    await file.writeAsBytes(pdfBytes);
    print('PDF saved to: ${file.path}');

    // Open the saved PDF file
    await OpenFile.open(file.path);
  }

  void showLoadingAlert(BuildContext context, String message,
      {Duration duration = const Duration(seconds: 3)}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text(message),
            ],
          ),
        );
      },
    );

    Future.delayed(duration, () {
      Navigator.pop(context);
    });
  }




}

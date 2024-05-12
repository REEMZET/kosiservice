
import 'package:flutter/foundation.dart';
import 'package:kosiservice/KosiPages/MyBookingDetail.dart';
import 'package:kosiservice/Utils/Toast.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'SignInScreen.dart';
import '../Utils/AppColors.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
User? user = FirebaseAuth.instance.currentUser;
String? phoneNumber = user?.phoneNumber.toString().substring(3, 13);
String kosihelper_name="NO helper Assign";
String? kosihelperid;
String? kosihelperphone,kosihelpercat;


class MyBookingPage extends StatefulWidget {
  @override
  State<MyBookingPage> createState() => _MyBookingPageState();
}

class _MyBookingPageState extends State<MyBookingPage> {


  @override
  initState() {
    super.initState();
  }


  Widget bookingList() {
    final ref = FirebaseDatabase.instance.ref(
        'KosiService/User/$phoneNumber/mybooking');


    return Expanded(
      child: FirebaseAnimatedList(
        query: ref,
        sort: (a, b) {
          String bookingDateStrA = a.child('bookingdate').value.toString();
          String bookingDateStrB = b.child('bookingdate').value.toString();

          List<String>? partsA = bookingDateStrA.split('/');
          List<String>? partsB = bookingDateStrB.split('/');

          if (partsA == null || partsB == null) {
            // Handle null case here, you can choose to put these entries at the end or beginning
            return 0;
          }

          int dayA = int.parse(partsA[0]);
          int monthA = int.parse(partsA[1]);
          int yearA = int.parse(partsA[2]);

          int dayB = int.parse(partsB[0]);
          int monthB = int.parse(partsB[1]);
          int yearB = int.parse(partsB[2]);

          DateTime dateA = DateTime(yearA, monthA, dayA);
          DateTime dateB = DateTime(yearB, monthB, dayB);

          return dateB.compareTo(dateA); // Sorting in descending order (newer date first)
        },
        itemBuilder: (context, snapshot, animation, index) {
          String bookingdate = snapshot.child('bookingdate').value.toString();
          String paymentoption = snapshot.child('paymentoption').value.toString();
          String bookingtime = snapshot.child('bookingtime').value.toString();
          String bookingtotalprice = snapshot.child('bookingtotalprice').value.toString();
          String bookingid = snapshot.child('bookingid').value.toString();
          String bookingpin = snapshot.child('bookingpin').value.toString();
          String bookingstatus = snapshot.child('bookingstatus').value.toString();
          String Address = snapshot.child('Address').value.toString();
          String location = snapshot.child('location').value.toString();
          String Name = snapshot.child('Name').value.toString();
          String phone = snapshot.child('phone').value.toString();
          String bookingkey = snapshot.child('bookingkey').value.toString();
          String transcationid = snapshot.child('transcationid').value.toString();
          String serviceboy = snapshot.child('serviceboy').value.toString();
          String dues=snapshot.child('dues').value.toString();
          String additionalcharge = snapshot.child('additionalcharges').exists ? snapshot.child('additionalcharges').value.toString() : "0.00";

          return Card(
            elevation: 0,
            margin: EdgeInsets.all(10),
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => MyBookingDetailsScreen(
                        bookingkey: bookingkey,
                  helperid: serviceboy,Status: bookingstatus,name: Name,address: Address,phone: phone, bookingid: bookingid,
                  bookingdate: bookingdate, bookingtime: bookingtime, paymentoption:paymentoption,transid: transcationid,
                  dues:dues,location:location
                      ),));
              },
              child: Padding(
                padding: EdgeInsets.all(4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [


                    Row(
                      children: [
                        // Choose appropriate icon for order status
                        _buildIconForStatus(bookingstatus),
                        SizedBox(width: 4,),// Use a function to build the icon
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$bookingstatus',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold)),
                            Text('Date-$bookingdate', style: TextStyle(fontSize: 12)),
                          ],
                        )
                      ],
                    ),

                    Card(
                      elevation: 0,
                      surfaceTintColor: AppColors.primaryColor,
                      margin: EdgeInsets.all(4),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            SizedBox(width: 4),
                            Image.asset('assets/images/booking.png',height: 90,width: 80,),
                            SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(height: 3,),
                                      Text(
                                        'Booking Id :-',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 13,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        bookingid,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        'Payment Option :-',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 13,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        paymentoption,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        'Booking Value',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 13,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        ':- ₹' + bookingtotalprice,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),


                                  Row(
                                    children: [
                                      Text(
                                        'Booking Pin',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 13,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        bookingpin,
                                        style: TextStyle(
                                          color: AppColors.primaryColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(
                      color: Colors.black12,
                      height: 0.5,
                    ),

                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    if (user == null) {
      return SignInScreen();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text('My Booking',style: TextStyle(color: Colors.white),),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          bookingList(),
        ],
      ),
    );
  }



  Icon _buildIconForStatus(String status) {
    IconData iconData;
    Color iconColor;

    switch (status) {
      case 'Pending':
        iconData = Icons.pending;
        iconColor = Colors.orange;

        break;
      case 'Confirm':
        iconData = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case 'Out for Service':
        iconData = Icons.directions_walk;
        iconColor = Colors.blue;
        break;
      case 'Started':
        iconData = Icons.tire_repair_sharp;
        iconColor = Colors.blue;
        break;
      case 'Service Done':
        iconData = Icons.done;
        iconColor = Colors.green;
        break;
      case 'Canceled':
        iconData = Icons.cancel;
        iconColor = Colors.red;
        break;
      default:
        iconData = Icons.error;
        iconColor = Colors.black;
        break;
    }

    return Icon(
      iconData,
      size: 35,
      color: iconColor,
    );
  }



}

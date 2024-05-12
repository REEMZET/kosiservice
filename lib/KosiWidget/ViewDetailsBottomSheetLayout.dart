import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:kosiservice/KosiPages/SubcateogoryDetailPage.dart';
import 'package:kosiservice/KosiWidget/ReviewWidget.dart';

import '../KosiPages/SignInScreen.dart';
import '../Models/KosiUserModel.dart';
import '../Utils/AppColors.dart';
import '../Utils/Pagerouter.dart';
import 'AddtoCartSheet.dart';
import 'CarouselWidget.dart';
import 'SigninBottomSheetWidget.dart';
User? user = FirebaseAuth.instance.currentUser;
class ViewDetailsBottomSheet extends StatefulWidget {
  final List<String>?imageurl;
  final String servicename;
  final String sercharge;
  final String sermrp;
  final String quotation;
  final String serref;
  final String subcatkey;
  final String serdesc;
 final String serviceid,serviceqty,visitingcharge,servicegstcharge;

  ViewDetailsBottomSheet({ required this.imageurl, required this.servicename,required this.quotation ,required this.serref,
    required this.subcatkey, required this.sercharge, required this.sermrp,required this.serdesc, required this.serviceid, required this.serviceqty, required this.visitingcharge, required this.servicegstcharge});



  @override
  State<ViewDetailsBottomSheet> createState() => _ViewDetailsBottomSheetState();
}

class _ViewDetailsBottomSheetState extends State<ViewDetailsBottomSheet> {
  List<String>? serimglist;
  double reviewcontainerheight=0;
  late DatabaseReference reviewref,serimgref;
  KosiUserModel? userModel;
  String? phoneNumber = user?.phoneNumber.toString().substring(3, 13);

  Future<int> reviewitemlistcount() async {
    try {
      final snapshot = await reviewref.once();
      if (snapshot.snapshot.value != null) {

        final data= snapshot.snapshot.children;
        int itemcount = data.length ?? 0;
        setState(() {
          reviewcontainerheight=itemcount*110;
        });
        return itemcount;
      } else {
        return 0;
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      return 0;
    }

  }
  Future getserimglist() async {
    try {
      final snapshot = await serimgref.once();
      if (snapshot.snapshot.value != null) {
        final data= snapshot.snapshot.value;
        setState(() {
          dynamic photosUrlValue = data;
          if (photosUrlValue is List<dynamic>) {
            serimglist = List<String>.from(
                photosUrlValue.map((dynamic item) => item.toString()));
          }
        });

      } else {

      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      return 0;
    }

  }
  Future<void> getUserDetails() async {
    Completer<void> completer = Completer<void>();
    DatabaseReference userRef = FirebaseDatabase.instance
        .reference()
        .child('KosiService/User/$phoneNumber');
    userRef.onValue.listen((event) {
      final udata = event.snapshot.value;
      if (udata != null) {
        Map<dynamic, dynamic> data = udata as Map<dynamic, dynamic>;
        userModel = KosiUserModel(
            name: data['name'] ?? '',
            userPhone: data['userphone'] ?? '',
            uid: data['uid'] ?? '',
            regDate: data['regdate'] ?? '',
            accountType: data['accounttype'] ?? '',
            balance: data['balance'] ?? '',
            referalcode: data['referalcode'],
            userLatitude: '',
            userLongitude: '',
            deviceId: '',
            address: '');
        setState(() {
          completer.complete(); // Signal that the operation is complete
        });
      }
    });

    return completer.future; // Return the future for external awaiters
  }


@override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserDetails();
    print('serkey-${widget.serref}');
    reviewref=FirebaseDatabase.instance.ref(widget.serref).child('reviews');
    serimgref=FirebaseDatabase.instance.ref(widget.serref).child('serimg');

    reviewitemlistcount();
    getserimglist();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

           Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 220,
                child: CarouselWidget(
                  imgvideolist: serimglist,
                ),
              ),
            ),
            Align(alignment:Alignment.topLeft,child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(widget.servicename,style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold),),
            )),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.arrow_downward,
                        color: Colors.green,
                        size: 14,
                      ),
                      //Text('off',style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold),),
                      Text(
                        '${calculatePercentage(widget.sermrp, widget.sercharge).toStringAsFixed(2)}%',
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.green,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  Container(
                    child: Text(
                      '${widget.sermrp}',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.lineThrough,
                          // Add this line
                          decorationColor: Colors
                              .blueGrey,
                          decorationThickness: 3// Add this line if you want the strike-through color to be pink
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Container(
                    child: Text(
                      '₹${widget.sercharge}',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.pink,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 80,right: 10),
                      child: OutlinedButton(
                        onPressed: () {
                          User? user = FirebaseAuth.instance.currentUser;
                          if(user!=null){
                            addservicetocartwidget(widget.serref.toString()
                                ,widget.servicename,widget.serviceid,'1',widget.sercharge,widget.visitingcharge,widget.servicegstcharge,widget.imageurl!.first);
                          }
                          else
                          {
                            showModalBottomSheet<void>(
                                           context: context,
                                           useSafeArea: true,
                                           elevation: 4,
                                           isScrollControlled: true,
                                           enableDrag: true,
                                           showDragHandle:true,
                                           shape: RoundedRectangleBorder(
                                             borderRadius: BorderRadius.vertical(
                                               top: Radius.circular(40.0), // Adjust the radius as needed
                                             ),
                                           ),
                                           builder: (BuildContext context) {
                                             return Container(
                                               color: Colors.greenAccent,
                                               child: SingleChildScrollView(
                                                 child: Column(
                                                   mainAxisAlignment: MainAxisAlignment.center,
                                                   children: <Widget>[
                                                     SignInBottomSheet()
                                                   ],
                                                 ),
                                               ),
                                             );
                                           },
                                         );
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Add to Cart',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: 2,
                            ),
                            Icon(
                              CupertinoIcons.cart_fill_badge_plus,
                              size: 20,
                              color: Colors.white,
                            )
                          ],
                        ),
                        style: ButtonStyle(
                          backgroundColor:
                          MaterialStateProperty.all<Color>(
                              AppColors.primaryColor),
                          shape: MaterialStateProperty.all<
                              OutlinedBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  5.0), // Adjust the radius as needed
                            ),
                          ),
                          side: MaterialStateProperty.all<
                              BorderSide>(
                            BorderSide(
                              color: AppColors.primaryColor,
                              // Adjust the color as needed
                              width: 0, // Adjust the width as needed
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),

            SizedBox(height: 10,),
            Container(
              margin: EdgeInsets.only(left: 10,right: 15),
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: widget.serdesc.split(r'\n').length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Text(
                            '\u2022', // Bullet point Unicode character
                            style:
                            TextStyle(fontSize: 16.0, color: Colors.black87),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            widget.serdesc.split(r'\n')[index],
                            style:
                            TextStyle(fontSize: 14.0, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: HtmlWidget( widget.quotation
              ),
            ),
           Align(alignment:Alignment.topLeft,child: Padding(
             padding: const EdgeInsets.all(15.0),
             child: Text('Reviews',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20),),
           )),
           Container(height:reviewcontainerheight,margin:EdgeInsets.all(8),child: ReviewWidget(reviewref: widget.serref,)),


          ],
        ),
      ),
    );
  }
  double calculatePercentage(String mrpString, String discountedPriceString) {
    try {
      double mrp = double.parse(mrpString);
      double discountedPrice = double.parse(discountedPriceString);

      if (mrp <= 0 || discountedPrice < 0 || discountedPrice > mrp) {
        throw ArgumentError(
            "Invalid input values. Make sure MRP > 0, discountedPrice >= 0, and discountedPrice <= MRP.");
      }

      double percentageOff = ((mrp - discountedPrice) / mrp) * 100;
      return percentageOff;
    } catch (e) {
      throw ArgumentError(
          "Invalid input values. Please provide valid numeric values for MRP and discountedPrice.");
    }
  }

  Future<void> addservicetocartwidget(String serviceref,String servicetitle,String serviceid,String serviceqty,String charge,String visitingcharge,String servicegstcharge,String serimg){
    return  showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      elevation: 4,
      isScrollControlled: true,
      enableDrag: true,
      showDragHandle:true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(40.0), // Adjust the radius as needed
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          color: Colors.greenAccent,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AddtoCartSheet(serviceref:serviceref, servicetitle: servicetitle, serviceid: serviceid,
                    charge: charge, visitingcharge: visitingcharge, servicegstcharge: servicegstcharge, serimg: serimg)
              ],
            ),
          ),
        );
      },
    );
  }
}

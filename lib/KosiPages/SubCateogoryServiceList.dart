import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

import '../KosiWidget/AddtoCartSheet.dart';
import '../KosiWidget/DashedDivider.dart';
import '../KosiWidget/SigninBottomSheetWidget.dart';
import '../KosiWidget/ViewDetailsBottomSheetLayout.dart';
import '../Models/KosiUserModel.dart';
import '../Utils/Toast.dart';
import 'SignInScreen.dart';
import '../Utils/AppColors.dart';
import '../Utils/Pagerouter.dart';
import 'CartPage.dart';

class SubCateogoryServiceList extends StatefulWidget {
  final String subcatlistref;
  final String title;


   SubCateogoryServiceList({required this.subcatlistref, required this.title});

  @override
  State<SubCateogoryServiceList> createState() => _SubCateogoryServiceListState();
}

late bool checkcart = false;
late DatabaseReference cartref;
late DatabaseReference catref;
String? phoneNumber;
class _SubCateogoryServiceListState extends State<SubCateogoryServiceList> {
  User? user = FirebaseAuth.instance.currentUser;


  void launchEnquiryWhatsApp() async {
    String enquirymsg = '''
  *Enquiry for Kosi Service*

Hello Kosi Service team,

I'm interested in learning more about your repair services. 
Could you please provide me with information regarding availability, 
pricing, and any current offer? 
\nThank you!

''';

    final link = WhatsAppUnilink(
      phoneNumber: '+91-7667538694', // Replace with the appropriate phone number
      text: enquirymsg,
    );

    await launch('$link');
  }
  void _makePhoneCall() {
    final String phoneNumber = '7667538694';
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    launch(phoneUri.toString());
  }

  Future<bool> checkCartExists() async {
    Completer<bool> completer = Completer<bool>();
    cartref.onValue.listen((event) {

      final data = event.snapshot.value;
      if (data != null) {
        completer.complete(true);
        setState(() {
          checkcart=true;
        });

      } else {
        setState(() {
          checkcart=false;
        });
        completer.complete(false);

      }
    });
    return completer.future;
  }





  @override
  void initState() {
     catref= FirebaseDatabase.instance.ref('${widget.subcatlistref}');
    if (user != null) {
      phoneNumber = user?.phoneNumber.toString().substring(3, 13);
      cartref = FirebaseDatabase.instance.ref('KosiService/User/$phoneNumber/cart');
      checkCartExists().then((exists) {
        setState(() {
          checkcart = exists;
        });
      });
    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          elevation: 1,
          backgroundColor: AppColors.primaryColor,
          title: Text(widget.title,style: TextStyle(color: Colors.white),),
          actions: [
            InkWell(
              onTap: () {
                if (user != null) {
                  Navigator.push(context, customPageRoute(CartPage()));
                } else {
                  ToastWidget.showToast(context,'Please login');
                }
              },
              child: Container(
                margin: EdgeInsets.only(top: 8, right: 12),
                child: Column(
                  children: [
                    user!=null?Icon(Icons.shopping_cart_checkout,color: Colors.yellow,):Icon(Icons.login,color: Colors.yellow,),
                    Text(
                      user!=null?'Cart':'Login',
                      style: TextStyle(
                          color: Colors.yellow,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ServiceList(),
        ),



      floatingActionButton: SpeedDial(
        backgroundColor: AppColors.blueColor,
        activeIcon: Icons.support_agent ,
        icon: Icons.call,
        iconTheme: IconThemeData(color: Colors.white),
        label: Text('Call US',style: TextStyle(color: Colors.white),),
        children: [
          SpeedDialChild(
            onTap: () {
              _makePhoneCall();
            },
            child: Icon(FontAwesomeIcons.phone),
            label: 'Call', // Help text for making a phone call
          ),
          SpeedDialChild(
            onTap: () {
              launchEnquiryWhatsApp();
            },
            child: Icon(FontAwesomeIcons.whatsapp),
            label: 'WhatsApp', // Help text for launching WhatsApp
          ),
          // Add more SpeedDialChild widgets as needed
        ],
      ),
    );

  }
  Widget ServiceList() {
    List<String>? serimglist;
    return FirebaseAnimatedList(
      scrollDirection: Axis.vertical,
      query: catref,
      itemBuilder: (context, snapshot, animation, index) {
        String sertitle = snapshot.child('sertitle').value.toString();
        String sercharge = snapshot.child('sercharge').value.toString();
        String sermrp = snapshot.child('sermrp').value.toString();
        String sermsghead = snapshot.child('serheadmsg').value.toString();
        String serdesc = snapshot.child('serdesc').value.toString();
        String quotationhtml = snapshot.child('quotation').value.toString();
        String serid=snapshot.child('serid').value.toString();
        String servisitingcharge=snapshot.child('servisitingcharge').value.toString();
        String sergstcharge =snapshot.child('sergstcharge').value.toString();
        String serrating=snapshot.child('serrating').value.toString();
        dynamic photosUrlValue = snapshot.child('serimg').value;
        if (photosUrlValue is List<dynamic>) {
          serimglist = List<String>.from(
              photosUrlValue.map((dynamic item) => item.toString()));
        }

        return InkWell(
          onTap: () {
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
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: ViewDetailsBottomSheet(imageurl:serimglist,servicename: sertitle,
                    quotation:quotationhtml, serref: '${widget.subcatlistref}/$serid',
                    subcatkey: 'subcatkey',
                    sercharge: sercharge,
                    sermrp: sermrp, serdesc: serdesc, serviceid: serid, serviceqty: '1',
                    visitingcharge: servisitingcharge, servicegstcharge: sergstcharge,
                  ),
                );
              },
            );
          },
          child: Container(
              height: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(
                            height: 120,
                            margin: EdgeInsets.all(4),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        sermsghead.toUpperCase(),
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.teal,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.left,
                                      )),
                                ),
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    sertitle,
                                    maxLines: 3,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Row(
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
                                          '${calculatePercentage(sermrp, sercharge).toStringAsFixed(2)}%',
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
                                        '$sermrp',
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
                                        '₹$sercharge',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.pink,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8,),
                                Row(
                                  children: [
                                    Icon(Icons.star,size: 15,color: Colors.blue,),
                                    Text(serrating,style: TextStyle(color: Colors.blue,fontSize: 13),)
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 0, ),
                              width: 150,
                              height: 160,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    // Adjust the border radius as needed
                                    child: Image.network(
                                      serimglist != null && serimglist!.isNotEmpty
                                          ? serimglist![Random().nextInt(serimglist!.length)]
                                          : 'https://firebasestorage.googleapis.com/v0/b/onlinemedis-f9e0a.appspot.com/o/image%20(2).png?alt=media&token=6733e85f-7213-45fa-a24d-b7420ee09b33', // Replace with your placeholder image URL
                                      width: 120,
                                      height: 110,
                                      fit: BoxFit.cover,
                                    ),

                                  ),
                                  Positioned(
                                      bottom: -6,
                                      // Adjust this value to control the overlap
                                      left: 0,
                                      right: 0,
                                      child: Padding(
                                          padding: const EdgeInsets.only(left: 20,bottom: 8,right: 20),
                                          // Adjust the padding as needed
                                          child: OutlinedButton(
                                            onPressed: () {
                                              User? user = FirebaseAuth.instance.currentUser;
                                              if(user!=null){
                                                addservicetocartwidget(widget.subcatlistref,sertitle,serid,'1',sercharge,servisitingcharge,sergstcharge,serimglist!.first);
                                              }else{
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
                                                      fontSize: 10,
                                                      color: Colors.white,fontWeight: FontWeight.bold),
                                                ),
                                                SizedBox(
                                                  width: 2,
                                                ),
                                                Icon(
                                                  CupertinoIcons.cart_fill_badge_plus,
                                                  size: 15,
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
                                          )))
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DashedDivider(
                      height: 1.0,
                      color: Colors.black12,
                      dashWidth: 3.0,
                      dashGap: 3.0,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10,right: 15),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: serdesc.split(r'\n').length,
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
                                  TextStyle(fontSize: 15.0, color: Colors.black87),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  serdesc.split(r'\n')[index],
                                  style:
                                  TextStyle(fontSize: 13.0, color: Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  TextButton(
                    onPressed: () {
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
                          return Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: ViewDetailsBottomSheet(imageurl:serimglist,servicename: sertitle,
                              quotation:quotationhtml, serref: '${widget.subcatlistref}/$serid',
                              subcatkey: 'subcatkey',
                              sercharge: sercharge,
                              sermrp: sermrp, serdesc: serdesc, serviceid: serid, serviceqty: '1',
                              visitingcharge: servisitingcharge, servicegstcharge: sergstcharge,
                            ),
                          );
                        },
                      );
                    },
                    child: Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.blue, // You can customize the text color
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 20,right: 10),
                    child: DashedDivider(
                      height: 1.0,
                      color: Colors.black54,
                      dashWidth: 10.0,
                      dashGap: 0.0,
                    ),
                  ),
                ],
              )),
        );
      },
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
  Future<void> addservicetocartwidget(String serviceref,String servicetitle,String serviceid,String serviceqty,
      String charge,String visitingcharge,String servicegstcharge,String serimg){
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
                AddtoCartSheet(servicetitle: servicetitle, serviceid: serviceid,
                    charge: charge, visitingcharge: visitingcharge, servicegstcharge: servicegstcharge,
                    serimg: serimg, serviceref: serviceref,)
              ],
            ),
          ),
        );
      },
    );
  }

}

import 'dart:async';
import 'dart:developer';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kosiservice/KosiPages/CartPage.dart';
import 'package:kosiservice/KosiWidget/AddtoCartSheet.dart';
import 'package:kosiservice/KosiWidget/CarouselWidget.dart';
import 'package:kosiservice/KosiPages/SignInScreen.dart';
import 'package:kosiservice/Utils/Toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

import '../KosiWidget/SigninBottomSheetWidget.dart';
import '../KosiWidget/ViewDetailsBottomSheetLayout.dart';
import '../KosiWidget/DashedDivider.dart';
import '../Models/KosiUserModel.dart';
import '../Utils/AppColors.dart';
import '../Utils/Pagerouter.dart';
import 'SubCateogoryServiceList.dart';
import 'SignInScreen.dart';

class SubCateogoryDetailPage extends StatefulWidget {
  final String cateogory;
  final String serkey;
  final String quotes;
  final List<String>? imgvideolist;

  SubCateogoryDetailPage(
      {required this.cateogory,
         required this.imgvideolist,
        required this.quotes,
      required this.serkey});

  @override
  State<SubCateogoryDetailPage> createState() => _SubCateogoryDetailPageState();
}

late List<String> photosUrl;
String? phoneNumber;
final catref = FirebaseDatabase.instance.ref('KosiService/ServiceFolder');


late bool checkcart = false;
late DatabaseReference cartref;
int subcatheight=0;
KosiUserModel? userData;
class _SubCateogoryDetailPageState extends State<SubCateogoryDetailPage> {
  User? user = FirebaseAuth.instance.currentUser;
  ScrollController _scrollController=ScrollController();

  int serviceitemcount=0;
  Future<void> getCat() async {
    catref.child(widget.serkey).child('subcateogory').onValue.listen((event) {
      for(int i=0;i<event.snapshot.children.length;i++){
        serviceitemcount+=event.snapshot.child(event.snapshot.children.elementAt(i).key.toString()).child('servicelist').children.length;
      }
      setState(() {
        subcatheight=420*serviceitemcount;
      });
    });
  }
  Future<int> servicelistcount(String subservicekey) async {
    try {
      final snapshot = await catref
          .child(widget.serkey)
          .child('subcateogory')
          .child(subservicekey)
          .child('servicelist')
          .once();

      if (snapshot.snapshot.value != null) {
        final data = snapshot.snapshot.children;
        int itemcount = data.length ?? 0;

        print(subcatheight);
        return itemcount;
      } else {
        return 0; // Return a default value or handle it based on your requirement
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      // Handle the error
      return 0; // Return a default value or handle it based on your requirement
    }

  }

  void getCatdetails() {
    getCat();
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
  void _makePhoneCall() {
    final String phoneNumber = '7667538694';
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    launch(phoneUri.toString());
  }
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

  @override
  void initState() {
    phoneNumber = user?.phoneNumber.toString().substring(3, 13);

    if (user != null) {
      cartref = FirebaseDatabase.instance.ref('KosiService/User/$phoneNumber/cart');
      print('testing cart ref \n${cartref.path}');
      checkCartExists().then((exists) {
        setState(() {
          checkcart = exists;
        });
      });

    }
    getCatdetails();
    super.initState();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          elevation: 1,
          backgroundColor: AppColors.primaryColor,
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(widget.cateogory,style: TextStyle(color: Colors.white),),
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
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Container(
            margin:MediaQuery.of(context).size.width > 600? EdgeInsets.only(left: 150,right: 150):EdgeInsets.all(0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: CarouselWidget(
                    imgvideolist: widget.imgvideolist,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        widget.cateogory,
                        style: TextStyle(
                            fontSize: 26,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      )),
                ),
                InkWell(
                  onTap: (){

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


                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                          Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: HtmlWidget( widget.quotes
                          ),)
                            ],
                          ),
                        ),
                      );

                  },
                    );

                  },
                  child: Card(
                    margin: EdgeInsets.all(10),
                    elevation: 0.3,

                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Kosi Service\nQuotes and Warranty'),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.black12,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(height:120,child: ServiceCateogoryHorizontalList()),
                ),
                Container(height:subcatheight.toDouble(), child: ServicesubCatList()),

              ],
            ),
          ),
        ),
      //  floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
       /* floatingActionButton:
        checkcart?Container(
          height: 50,
          width: 170,
          margin: EdgeInsets.all(20),
          child: ElevatedButton(onPressed: (){
            Navigator.push(
                context,
                customPageRoute(
                    CartPage()
                ));
          },

              style: ElevatedButton.styleFrom(primary: AppColors.primaryColor),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_checkout,color: Colors.white,),
                  SizedBox(width: 12,),
                  Text('View Cart',style: TextStyle(color: Colors.white),),
                  SizedBox(width: 8,),
                  Icon(CupertinoIcons.arrow_right,size: 20,color: Colors.white70,)
                ],
              )
          ),
        ):null,*/
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
  
  
  
  
  

  Widget ServicesubCatList() {
    return FirebaseAnimatedList(
      scrollDirection: Axis.vertical,
      physics: NeverScrollableScrollPhysics(),
      query: catref.child(widget.serkey).child('subcateogory'),
      itemBuilder: (context, snapshot, animation, index) {

        return FutureBuilder<int>(
          future: servicelistcount(snapshot.key.toString()),
          builder: (context, countSnapshot) {
            if (countSnapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // or any other loading indicator
            } else if (countSnapshot.hasError) {
              return Text('Error: ${countSnapshot.error}');
            } else {
              int count = countSnapshot.data ?? 0;
              return Container(
                child: Card(
                  surfaceTintColor: Colors.white,
                  elevation: 0.4,
                   child: Container(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15, top: 18, bottom: 10),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              snapshot.child('subcattitle').value.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                fontSize: 22,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Container(
                            height:  400 * count.toDouble(),
                            child: ServiceList(snapshot.key.toString()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }
  Widget ServiceCateogoryHorizontalList() {
   // List<String>? sercatimge;
    return FirebaseAnimatedList(
      scrollDirection: Axis.horizontal,
      query: catref
          .child(widget.serkey)
          .child('subcateogory'),
       itemBuilder: (context, snapshot, animation, index) {
        String subcattitle = snapshot.child('subcattitle').value.toString();
        List<String> subcatphotosUrl = [];
        dynamic photosUrlValue = snapshot.child('subcatimage').value;
        if (photosUrlValue is List<dynamic>) {
          subcatphotosUrl = List<String>.from(
              photosUrlValue.map((dynamic item) => item.toString()));
        }

        return InkWell(
          onTap: (){
            Navigator.push(context, customPageRoute(SubCateogoryServiceList(subcatlistref: 'KosiService/ServiceFolder/${widget.serkey}/subcateogory/${snapshot.key}/servicelist',title: subcattitle,))
            );
            },
          child: Card(
            elevation: 0.5,
            color: Colors.white,
            surfaceTintColor: Colors.white,
            child: Container(
              margin: EdgeInsets.all(4),
                height: 150,
                width: 105,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(width: 105,child: Image.network(subcatphotosUrl != null && subcatphotosUrl.isNotEmpty
                    ? subcatphotosUrl[Random().nextInt(subcatphotosUrl.length)]
                    : 'https://firebasestorage.googleapis.com/v0/b/onlinemedis-f9e0a.appspot.com/o/image%20(2).png?alt=media&token=6733e85f-7213-45fa-a24d-b7420ee09b33',
                      height: 80,width: 80,fit: BoxFit.cover,)),
                   SizedBox(height: 4,),
                    Text(subcattitle,style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold,color: Colors.green),),
                  ],
                )),
          ),
        );
      },
    );
  }

  Widget ServiceList(String subcatkey) {
    List<String>? serimglist;
    return FirebaseAnimatedList(
      scrollDirection: Axis.vertical,
      physics: NeverScrollableScrollPhysics(),
      query: catref
          .child(widget.serkey)
          .child('subcateogory')
          .child(subcatkey)
          .child('servicelist'),
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
                    quotation:quotationhtml, serref:'/KosiService/ServiceFolder/${widget.serkey}/subcateogory/$subcatkey/servicelist/$serid'
                    ,subcatkey: subcatkey,
                    sercharge: sercharge,
                    sermrp: sermrp, serdesc: serdesc, serviceid: serid, serviceqty: '1', visitingcharge: servisitingcharge, servicegstcharge: sergstcharge,),
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
                        height: 130,
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
                                              addservicetocartwidget('KosiService/ServiceFolder/${widget.serkey}/subcateogory/subcatkey/servicelist'
                                                  ,sertitle,serid,'1',sercharge,servisitingcharge,sergstcharge,serimglist!.first);
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
                          quotation:quotationhtml, serref:'/KosiService/ServiceFolder/${widget.serkey}/subcateogory/$subcatkey/servicelist/$serid',
                          subcatkey: subcatkey,
                          sercharge: sercharge,
                          sermrp: sermrp, serdesc: serdesc, serviceid: serid, serviceqty: '1', visitingcharge: servisitingcharge, servicegstcharge: sergstcharge,),
                      );
                    },
                  );
                },
                child: Text(
                  'View Details',
                  style: TextStyle(
                    fontSize: 15.0,
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
  Future<void> addservicetocartwidget(String serviceref,String servicetitle,String serviceid,String serviceqty,String charge,
      String visitingcharge,String servicegstcharge,String serimg){
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
                   charge: charge, visitingcharge: visitingcharge, servicegstcharge: servicegstcharge,
                   serimg: serimg)
              ],
            ),
          ),
        );
      },
    );
  }
}

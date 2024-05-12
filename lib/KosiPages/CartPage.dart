import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:kosiservice/KosiPages/Onlinepay.dart';
import 'package:kosiservice/KosiWidget/LocationPicker.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';

import 'package:crypto/crypto.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:kosiservice/KosiPages/MyBookingPAge.dart';
import 'package:kosiservice/Utils/Toast.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
import '../KosiWidget/DashedDivider.dart';
import '../KosiWidget/NotificationWidget/OneSignalNotificationwithoutimage.dart';
import '../Models/KosiUserModel.dart';
import '../Models/UserModel.dart';
import '../Utils/AppColors.dart';
import '../Utils/Pagerouter.dart';
import '../Utils/upi_app.dart';
import 'KosiHomePage.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});
  @override
  State<CartPage> createState() => _CartPageState();
}


User? user = FirebaseAuth.instance.currentUser;
String? phoneNumber = user?.phoneNumber.toString().substring(3, 13);
final cartref = FirebaseDatabase.instance.ref('KosiService/User/$phoneNumber/cart');
final mybookingref = FirebaseDatabase.instance.ref('KosiService/User/$phoneNumber/mybooking');
final DatabaseReference adminbookref = FirebaseDatabase.instance.reference().child('KosiService').child('Admin/booking');
final cancelpolicyref = FirebaseDatabase.instance.ref('KosiService/Admin/cancelpolicy');
dynamic Cartdata;

class _CartPageState extends State<CartPage> {
  //Merchant ID-M22WHJF4P68DR
  //API Key-41973071-49f8-40c9-b88c-d5ca95d1b3ed
  String apiEndPoint = "/pg/v1/pay";
  String environment="PRODUCTION";
      String appId="";
    String merchantId="M22WHJF4P68DR";
    bool enableLogging=true;
    String checksum="";
    String saltkey="41973071-49f8-40c9-b88c-d5ca95d1b3ed";
    String saltIndex="1";
    String Packagename="";
 String callbackUrl="https://webhook.site/24f62d42-b0fa-42ad-850b-044ef39d9c42";
 String body="";
 Object? result;


  KosiUserModel? userModel;
  int cartcontainerheight=0;
  double totalservicevalue=0;
  double taxandvalue=0;
  double totalvisitingcharge=0;
  String? cancelmsg='';
  String? htmllayout='';
  String? _currentAddress;
  Position? _currentPosition;
  String? phoneNumber;
  bool isloading=true;
  User? user = FirebaseAuth.instance.currentUser;
  late List<String> adminphone;

  getChecksum() {
    DateTime now = DateTime.now();
    int milliseconds = now.millisecondsSinceEpoch;

    final requestData = {
      "merchantId": merchantId,
      "merchantTransactionId": "$milliseconds",
      "merchantUserId": "MUID9022",
      "amount": 100,
      "mobileNumber": "9525581574",
      "callbackUrl": "https://webhook.site/24f62d42-b0fa-42ad-850b-044ef39d9c42",
      "paymentInstrument": {"type": "PAY_PAGE"}
    };


    String base64Body = base64.encode(utf8.encode(json.encode(requestData)));
    checksum = '${sha256.convert(utf8.encode(base64Body+apiEndPoint+saltkey)).toString()}###$saltIndex';
    return base64Body;
  }

  void startPgTranscation() async{
    PhonePePaymentSdk.startTransaction(body, callbackUrl, checksum, 'com.kosi.kosiservice').then((response) => {
      setState(() {
        if (response != null)
        {
          String status = response['status'].toString();
          String error = response['error'].toString();
          if (status == 'SUCCESS')
          {
            result="Flow Complete- status :SUCCESS";
            // "Flow Completed - Status: Success!";
            ToastWidget.showToast(context, 'Sucess');
          }
          else {
            result="Flow Completed - Status: $status and Error: $error";
            ToastWidget.showToast(context,"Flow Completed - Status: $status and Error: $error");

          }
        }
        else {
          result="Flow Incomplete";
          // "Flow Incomplete";
        }
      })
    }).catchError((error) {
      // handleError(error)
      return <dynamic>{};
    });










  }
  void phonepeInit() {

    PhonePePaymentSdk.init(environment, appId, merchantId, enableLogging)
        .then((val) => {
      setState(() {
        result = 'PhonePe SDK Initialized - $val';
      })
    }).catchError((error) {
      handleError(error);
      return <dynamic>{};
    });
  }
  void handleError(error) {
    setState(() {
      result= {"error":error};
    });
  }







  void getcancelpolicy(){
    cancelpolicyref.onValue.listen((event) {
      setState(() {
        cancelmsg=event.snapshot.child('msg').value.toString();
        htmllayout=event.snapshot.child('layout').value.toString();
      });
    });
  }
  Future<int> cartitemlistcount() async {
    try {
      final snapshot = await cartref.once();
      if (snapshot.snapshot.value != null) {
        final data= snapshot.snapshot.children;
        int itemcount = data.length ?? 0;
        print(Cartdata);
        Cartdata=snapshot.snapshot.value;
        setState(() {
          cartcontainerheight=itemcount*130;
        });
        print('height=$cartcontainerheight');
        return itemcount;
      } else {
        return 0;
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      return 0;
    }

  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }
  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      getAddressFromLatLng(context,position.latitude,position.longitude);
     setState(() {
       _currentPosition = position;
     });
    }).catchError((e) {
      debugPrint(e);
    });
  }
  getAddressFromLatLng(context, double lat, double lng) async {
    String _host = 'https://maps.google.com/maps/api/geocode/json';
    final url = '$_host?key=AIzaSyAAQzj4K4H8RARgq-YNHh6G-YaKFdq3WgY&language=en&latlng=$lat,$lng';
    if(lat != null && lng != null){
      var response = await http.get(Uri.parse(url));
      if(response.statusCode == 200) {
        Map data = jsonDecode(response.body);
        setState(() {
          _currentAddress = data["results"][0]["formatted_address"];
        });

      } else return null;
    } else return null;
  }
  Future<void> getAdminphone() async {
    DatabaseReference adminphoneref = FirebaseDatabase.instance.ref('KosiService/Admin/adminphone');
    adminphoneref.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      if (data is String) {
        adminphone = data.split(',');
          print(adminphone.first);
      } else {
        print('Invalid data format');
      }
    });
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
    phoneNumber = user?.phoneNumber.toString().substring(3, 13);
    getUserDetails();
    getPaymentSummary();
    cartitemlistcount();
    getcancelpolicy();
    _getCurrentPosition();
    getAdminphone();
    phonepeInit();
    body=getChecksum().toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('My Cart',style: TextStyle(color: Colors.white),),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child:  Container(height:cartcontainerheight.toDouble(), child: CartList()),
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Card(
                elevation: 0.1,
                margin: EdgeInsets.all(4),
                child: Container(
                  margin: EdgeInsets.all(4),
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10,bottom: 10,left: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset('assets/images/offer.png',width: 30,height: 30,),
                            SizedBox(width: 10,),
                            Text('Coupons and offers',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text('explore',style: TextStyle(fontSize: 15,color: Colors.black54),),
                              ),
                              Icon(Icons.arrow_forward_ios,color: Colors.black54,size: 15,),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 2,right: 2,top: 8),
              child: PaymentSummary(),
            ),
           Padding(
              padding: const EdgeInsets.only(left: 2,right: 2,top: 8),
              child: BookingAddrerss(),
            ),
            SizedBox(height: 10,),
            Container(
              margin: EdgeInsets.all(8),
              width: double.infinity,
              height: 50,
              child:ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor, // Change the background color to green
                ),
                onPressed: () async {
                  final cartitem = AnalyticsEventItem(
                    itemId: '',
                    itemName: 'Checkout',
                    itemCategory: '',
                    itemVariant: '',
                    itemBrand: 'Kosi Service',
                    price: totalservicevalue.toDouble(),
                    quantity: 1,
                  );
                  await FirebaseAnalytics.instance.logBeginCheckout(
                    currency: 'INR',
                    value: totalservicevalue,  // Discount applied.
                    coupon: "Checkout",
                    items: [cartitem],
                  );
                  PaymentDialog(context);
                },
                child: Text(
                  'Proceed to book', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 18),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 2,right: 2,top: 8),
              child: CancelPolicy(),
            ),

            SizedBox(height: 10,),
          ],
        ),
      ),
    );
  }
  Widget CartList() {
    return FirebaseAnimatedList(
      scrollDirection: Axis.vertical,
      query: cartref,
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


        return Dismissible(
          key: Key(snapshot.key.toString()),
          onDismissed: (direction) {
            DatabaseReference itemRef = cartref.child(snapshot.key.toString());
            itemRef.remove().then((_) {
              print('Item removed: ${snapshot.key.toString()}');
              getPaymentSummary();
            }).catchError((error) {
              print('Error removing item: $error');
            });
          },
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20),
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          child: Container(
            height: 130,
            child: Card(
              margin: EdgeInsets.all(1.5),
              elevation: 0,
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Row(
                          children: [
                            Image.network(Serviceimg, width: 70, height: 100,),
                            SizedBox(width: 2,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  Servicetitle.length <= 30 ? Servicetitle : '${Servicetitle.substring(0, 30)}...',
                                  style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 2,),
                                Text('Slot- $Serviceslot', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 12),),
                                SizedBox(height: 4,),
                                Text('Service charges- ₹$Servicecharge', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black54, fontSize: 12)),
                                 Text('Service GST- $Servicegstcharge%', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black54, fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(children: [

                              IconButton(
                                icon: Icon(Icons.remove_circle, size: 22, color: Colors.black54,),
                                onPressed: () => decreaseQuantity(snapshot.key.toString(), quantity),
                              ),
                              Text('$quantity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.indigo)),
                              IconButton(
                                icon: Icon(Icons.add_circle, size: 22, color: Colors.green,),
                                onPressed: () => increaseQuantity(snapshot.key.toString(), quantity),
                              ),
                            ],),
                          IconButton(
                            icon: Icon(Icons.delete, size: 25, color: Colors.red,),
                            onPressed: () {
                              DatabaseReference itemRef = cartref.child(snapshot.key.toString());
                              itemRef.remove().then((_) {

                                getPaymentSummary();
                              }).catchError((error) {
                                print('Error removing item: $error');
                              });
                            }
                          ),

                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  Widget PaymentSummary(){
    return Card(
      elevation: 0.3,
      margin: EdgeInsets.all(4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payment Summary',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.black87),),
           SizedBox(height: 8,),
            Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children: [
              Text('Item total',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 14,color: Colors.black54),),
              Text('${totalservicevalue.toStringAsFixed(2)}'),
            ],),
            SizedBox(height: 8,),
            Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children: [
              Text('Visiting Charges',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 14,color: Colors.black54),),
              Text('${totalvisitingcharge.toStringAsFixed(2)}')

            ],),
            SizedBox(height: 8,),
            Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children: [
              Text('gst',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 14,color: Colors.black54),),
              Text('${taxandvalue.toStringAsFixed(2)}')

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
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '${(totalvisitingcharge + totalservicevalue + taxandvalue).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
              ],
            )


          ],
        ),
      ),
    );
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
              Text('Name-${userModel!.name}',style: TextStyle(fontWeight: FontWeight.w400,fontSize: 16,color: Colors.black87),),
              SizedBox(height: 2,),
              Text('Mob-$phoneNumber',style: TextStyle(fontWeight: FontWeight.w400,fontSize: 16,color: Colors.black87),),
              SizedBox(height: 2,),
              _currentAddress != null?
          Text(_currentAddress!,style: TextStyle(fontWeight: FontWeight.w400,fontSize: 16,color: Colors.black87),)
              :Text('Address not available', style: TextStyle(fontWeight: FontWeight.w400,fontSize: 16,color: Colors.black87),),
                SizedBox(height: 8,),
    ],
    ),
    ),
    ),
    );
  }

  Widget CancelPolicy()  {
    return Card(
      elevation: 0.4,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cancellation policy',style: TextStyle(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 18),),
            SizedBox(height: 6,),
            Text(cancelmsg!),
            SizedBox(height: 3,),
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
                              child: HtmlWidget( htmllayout!
                              ),)
                          ],
                        ),
                      ),
                    );

                  },
                );
              },
                child: Text('learn more',style: TextStyle(fontWeight:FontWeight.bold,color:Colors.indigo,fontSize: 15,decoration: TextDecoration.underline),))
          ],
        ),
      ),
    );
  }
  PaymentDialog(BuildContext context){
  /*  if (_currentPosition == null || _currentAddress == null) {
      // Show a dialog or snackbar prompting the user to enable location
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Location Required"),
            content: Text("Please enable your location to proceed"),
            actions: <Widget>[
              ElevatedButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                  _getCurrentPosition(); // Attempt to get the location again
                },
              ),
            ],
          );
        },
      );
      return;
    }*/

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
          width: double.infinity,
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Choose Payment Method',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
           /* Navigator.push(
                      context,
                      customPageRoute(
                          PaymentPage()

                      ));*/
                  ToastWidget.showToast(context, 'Sorry only COD');
                  startPgTranscation();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Set the background color to green
                ),
                child: Text('Online Payment',style: TextStyle(color: Colors.white),),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final cartitem = AnalyticsEventItem(
                    itemId: '',
                    itemName: 'Booked',
                    itemCategory: '',
                    itemVariant: '',
                    itemBrand: 'Kosi Service',
                    price: totalvisitingcharge + totalservicevalue + taxandvalue,
                    quantity: 1,
                  );


                  await FirebaseAnalytics.instance.logPurchase(
                    transactionId: "null",
                    affiliation: "Kosi Service",
                    currency: 'INR',
                    value: totalservicevalue,
                    shipping:totalvisitingcharge,
                    tax: taxandvalue,
                    coupon: "Kosi Service",
                    items: [cartitem],
                  );

                  if(totalservicevalue!=0){
                   /*LocationPickerResult? locationResult = await LocationPickerDialog.show(
                      context,
                      userModel!.name,
                      userModel!.userPhone,
                    );*/
            //if (locationResult != null) {
        //  _currentAddress=locationResult.address;
          setState( () {} );
          book('COD','${(totalvisitingcharge + totalservicevalue + taxandvalue).toStringAsFixed(2)}','${(totalvisitingcharge + totalservicevalue + taxandvalue).toStringAsFixed(2)}','no');
          /* }else{
         // ToastWidget.showToast(context, 'Cancel');
           }*/

                  }else{
                    ToastWidget.showToast(context, 'Cart is Empty');
                  }

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Set the background color to green
                ),
                child: Text('Cash on Delivery',style: TextStyle(color: Colors.white),),
              ),


            ],
          ),
        );
      },
    );
  }
  void book(String paymentoption, String dues, String totalcharge,
      String transid) {
    DateTime currentDate = DateTime.now();
    String date = DateFormat('dd/MM/yyyy').format(currentDate);
    String time = DateFormat('hh:mm a').format(currentDate);

    String bookingkey = mybookingref
        .push()
        .key ?? '';
    String bookingid = bookingkey.substring(2, 5) + bookingkey.substring(6, 9);
    String device;
    if (kIsWeb) {
      device = 'web';
    } else {
      device = 'App';
    }
    double? latitude = _currentPosition?.latitude;
    double? longitude = _currentPosition?.longitude;
    String bookingpin=getpin().toString();

    mybookingref.child(bookingkey).set({
      "bookingkey": bookingkey,
      "Name": userModel!.name,
      "Address": _currentAddress,
      "location":'$latitude,$longitude',
      "Services": Cartdata,
      "phone": userModel!.userPhone,
      "bookingdate": date,
      "bookingtime": time,
      "bookingid": bookingid,
      "bookingtotalprice": totalcharge,
      "bookingstatus": 'Pending',
      "paymentoption": paymentoption,
      "transcationid": transid,
      "bookdevice": device,
      "serviceboy": 'not Assigned',
      "bookingpin": bookingpin,
      "dues": dues,
    });
    adminbookref.child(bookingkey).set({
      "bookingkey": bookingkey,
      "Name": userModel!.name,
      "Address": _currentAddress,
      "location":'$latitude,$longitude',
      "Services": Cartdata,
      "phone": userModel!.userPhone,
      "bookingdate": date,
      "bookingtime": time,
      "bookingid": bookingid,
      "bookingtotalprice": totalcharge,
      "bookingstatus": 'Pending',
      "paymentoption": paymentoption,
      "transcationid": transid,
      "bookdevice": device,
      "serviceboy": 'not Assigned',
      "bookingpin": bookingpin,
      "dues": dues,
    });
    cartref.remove();
    ToastWidget.showToast(context, 'Booking Placed');
    Navigator.of(context).pop();
    sendpushnotificationtoadmin('New Booking from ${userModel!.name}','https://firebasestorage.googleapis.com/v0/b/firstandfast-781dd.appspot.com/o/neworder.jpg?alt=media&token=2b93938f-ecd7-4d12-a03a-26f395fdcea2');
    Navigator.push(
      context as BuildContext, MaterialPageRoute(builder: (context) => MyBookingPage()),
    );


  }

  getPaymentSummary() async {
    totalservicevalue=0;
    totalvisitingcharge=0;
    taxandvalue=0;
    final datasnap= await cartref.get();
    Map<dynamic, dynamic> cartItems = datasnap.value as Map<dynamic, dynamic>;
    String Servicecharge;
    String Servicegstcharge;
    String Serviceqty;
    String Servicevisitingcharge;


    cartItems.forEach((key, value) async {
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
  void updateQuantity(String key, int newQuantity) {
    DatabaseReference itemRef = cartref.child(key);

    // Check if the new quantity is greater than or equal to 1
    if (newQuantity >= 1) {
      // Update the quantity in Firebase
      itemRef.child('Serviceqty').set(newQuantity).then((_) {
        print('Quantity updated for $key: $newQuantity');
        getPaymentSummary();
      }).catchError((error) {
        print('Error updating quantity: $error');
      });
    } else {
      // Remove the item from Firebase if the new quantity is less than 1
      itemRef.remove().then((_) {
        print('Item removed: $key');
        getPaymentSummary();
      }).catchError((error) {
        print('Error removing item: $error');
      });
    }
  }
  void decreaseQuantity(String key, int currentQuantity) {
    int newQuantity = currentQuantity - 1;
    // Update quantity in Firebase or remove item if it becomes less than 1
    updateQuantity(key, newQuantity);
  }
  void increaseQuantity(String key, int currentQuantity) {
    int newQuantity = currentQuantity + 1;
    // Update quantity in Firebase or remove item if it becomes less than 1
    updateQuantity(key, newQuantity);
  }





  int getpin() {
    Random random = Random();
    return random.nextInt(9000) + 1000;
  }

  Future<void> sendpushnotificationtoadmin(String msg,String imageurl) async {
    final pushoneSignalNotification = PushOneSignalNotification(
      restApiKey: 'M2FhZjZjODItYzllYi00M2M5LTlhNDItNzZmOGU4ZDEwYjEw',
      appId: 'e2fa9bad-fd7f-4d34-b2ed-14d28772867d',
    );

    await pushoneSignalNotification.sendPushNotification(
      message: msg,
      title: 'Kosi Service',
      heading: 'New message from Kosi Service',
      externalIds: adminphone,
      targetChannel: 'push',
      customData: {"custom_key": "custom_value"},
      imageUrl: imageurl,
    );
  }



}

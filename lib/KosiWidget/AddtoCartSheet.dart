import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:kosiservice/KosiPages/MyBookingDetail.dart';
import 'package:kosiservice/KosiPages/SubcateogoryDetailPage.dart';
import 'package:kosiservice/KosiWidget/SlotWidget.dart';
import 'package:kosiservice/Utils/Toast.dart';

import '../Models/KosiUserModel.dart';
import '../Utils/AppColors.dart';


class AddtoCartSheet extends StatefulWidget {
  final String servicetitle, serviceid, charge, visitingcharge, servicegstcharge, serimg;
 final String serviceref;


  AddtoCartSheet({
    required this.servicetitle,
    required this.serviceid,
    required this.charge,
    required this.visitingcharge,
    required this.servicegstcharge,
    required this.serimg,
    required this.serviceref,

  });

  @override
  State<AddtoCartSheet> createState() => _AddtoCartSheetState();
}

User? user = FirebaseAuth.instance.currentUser;

String? phoneNumber;
final cartref = FirebaseDatabase.instance.ref('KosiService/User/$phoneNumber/cart');
final admincart = FirebaseDatabase.instance.ref('KosiService/Admin/Cart');
String? servicetimeslot, servicedateslot;
bool isAddingToCart = false;
KosiUserModel? userModel;


class _AddtoCartSheetState extends State<AddtoCartSheet> {
  int quantity = 1;
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
    print(event.snapshot.value);
        setState(() {
          completer.complete(); // Signal that the operation is complete
        });
      }
    });

    return completer.future; // Return the future for external awaiters
  }

  @override
  void initState() {
    print(user?.phoneNumber.toString().substring(3, 13));
    phoneNumber = user?.phoneNumber.toString().substring(3, 13);
    getUserDetails();
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
   // getUserDetails();
    final cartref = FirebaseDatabase.instance.ref('KosiService/User/$phoneNumber/cart');
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
                height: 200,
                width: double.infinity,
                child: Image.network(widget.serimg, fit: BoxFit.cover),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 10, top: 4),
                child: Text(
                  widget.servicetitle,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 13, top: 3, bottom: 8),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text('charges- ₹${widget.charge}', style: TextStyle(color: Colors.green, fontSize: 18)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SlotWidget(onSelectionChanged: (String daySlot, String timeSlot) {
                setState(() {
                  servicetimeslot = daySlot;
                  servicedateslot = timeSlot;
                });
              }),
            ),
            SizedBox(height: 40),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xB5C9FFED),
                        border: Border.all(color: Colors.greenAccent, width: 0.50),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () => setState(() => quantity = quantity > 1 ? quantity - 1 : quantity),
                          ),
                          Text('$quantity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo)),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () => setState(() => quantity++),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isAddingToCart
                              ? null
                              : () async {
                            if (servicetimeslot == null && servicedateslot == null) {
                              ToastWidget.showToast(context, 'Please select the date and days slot');
                              return;
                            }
                            setState(() => isAddingToCart = true);

                            try {
                              await admincart.push().set({
                                "Servicetitle": widget.servicetitle,
                                "Servicecharge": widget.charge,
                                "Servicegstcharge": widget.servicegstcharge,
                                "Servicevisitingcharge": widget.visitingcharge,
                                "Serviceqty": quantity,
                                "Serviceid": widget.serviceid,
                                "Serviceimg": widget.serimg,
                                "Serviceslot": servicetimeslot! + servicedateslot!,
                                "UserName": userModel!.name,
                                "UserPhone": userModel!.userPhone,
                                "serviceref": widget.serviceref,
                              });

                              await cartref.push().set({
                                "Servicetitle": widget.servicetitle,
                                "Servicecharge": widget.charge,
                                "Servicegstcharge": widget.servicegstcharge,
                                "Servicevisitingcharge": widget.visitingcharge,
                                "Serviceqty": quantity,
                                "Serviceid": widget.serviceid,
                                "Serviceimg": widget.serimg,
                                "Serviceslot": '$servicetimeslot $servicedateslot!',
                                "serviceref": widget.serviceref,
                              });


                              final cartitem = AnalyticsEventItem(
                                itemId: widget.serviceid,
                                itemName: widget.servicetitle,
                                itemCategory: '',
                                itemVariant: "",
                                itemBrand: "Kosi Service",
                                price: double.parse(widget.charge),
                              );

                              await FirebaseAnalytics.instance.logAddToCart(
                                currency: 'INR',
                                value: double.parse(widget.charge),
                                items: [cartitem],
                              );

                              ToastWidget.showToast(context, 'Service added to cart');
                              setState(() => isAddingToCart = false);
                              Navigator.pop(context);
                            } catch (e) {
                              ToastWidget.showToast(context, 'Error adding service to cart: $e');
                              setState(() => isAddingToCart = false);
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                            child: Stack(
                              children: [
                                Visibility(
                                  visible: !isAddingToCart,
                                  child: Text('Add to Cart- ₹${int.parse(widget.charge) * quantity}', style: TextStyle(fontSize: 18, color: Colors.white)),
                                ),
                                Visibility(
                                  visible: isAddingToCart,
                                  child: Center(child: CircularProgressIndicator()),
                                ),
                              ],
                            ),
                          ),
                        ),

                      ),
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}


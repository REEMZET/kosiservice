import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../Models/KosiUserModel.dart';
import 'AddtoCartSheet.dart';
import 'SigninBottomSheetWidget.dart';
import 'ViewDetailsBottomSheetLayout.dart';

class TopServices extends StatefulWidget {
  @override
  State<TopServices> createState() => _TopServicesState();
}
final topref = FirebaseDatabase.instance.ref('KosiService/TopServices');

KosiUserModel? userModel;
User? user = FirebaseAuth.instance.currentUser;
String? phoneNumber = user?.phoneNumber.toString().substring(3, 13);

class _TopServicesState extends State<TopServices> {
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
   //getUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return FirebaseAnimatedList(
      scrollDirection: Axis.horizontal,
      query: topref,
      itemBuilder: (BuildContext context, DataSnapshot snapshot,
          Animation<double> animation, int index) {
        final data = snapshot.value;
        if (data != null && data is Map) {
          String sertitle = snapshot.child('sertitle').value.toString();
          String sercharge = snapshot.child('sercharge').value.toString();
          String sermrp = snapshot.child('sermrp').value.toString();
          String sermsghead = snapshot.child('serheadmsg').value.toString();
          String serdesc = snapshot.child('serdesc').value.toString();
          String quotationhtml = snapshot.child('quotation').value.toString();
          String serid=snapshot.child('serid').value.toString();
          String servisitingcharge=snapshot.child('servisitingcharge').value.toString();
          String sergstcharge =snapshot.child('sergstcharge').value.toString();



          List<String> photosUrl = [];

          if (data['serimg'] != null && data['serimg'] is List) {
            photosUrl = List<String>.from(data['serimg']);
          }

          Widget childWidget;
          if (photosUrl.isNotEmpty) {
            // Generate a random index within the range of the photosUrl list
            int randomIndex = Random().nextInt(photosUrl.length);
            childWidget = GestureDetector(
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
                    return Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: ViewDetailsBottomSheet(imageurl:photosUrl,servicename: sertitle,
                        quotation:quotationhtml,
                        subcatkey: 'Top Service',
                        sercharge: sercharge,
                        sermrp: sermrp, serref: topref.path.toString(), serdesc: serdesc, serviceid: serid, serviceqty: '1',
                        visitingcharge: servisitingcharge, servicegstcharge: sergstcharge,

                      ),
                    );
                  },
                );
              },
              // Use widget.onPressed to access the onPressed function
              child: ScreenTypeLayout(
                mobile: Container(
                    margin: const EdgeInsets.all(4),
                    width: 240,
                    height: 130,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Card(
                      color: Colors.white,
                      surfaceTintColor: Colors.white54,
                      elevation: 1,
                      margin: const EdgeInsets.all(2),
                      child: Row(
                        children: [
                          ClipRRect(
                            // Apply rounded corners to the image
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                photosUrl.elementAt(randomIndex),
                                width: 100,
                                height: 110,
                                fit: BoxFit.cover,
                                loadingBuilder: (BuildContext context, Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  } else {
                                    return const SizedBox(
                                      width: 90,
                                      height: 100,
                                      child: Center(
                                        child: SizedBox(
                                            width: 30,
                                            height: 30,
                                            child: CircularProgressIndicator()),
                                      ),
                                    );
                                  }
                                },
                                errorBuilder: (BuildContext context, Object error,
                                    StackTrace? stackTrace) {
                                  return Image.asset(
                                    'assets/images/placeholder.png',
                                    width: 90,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  );
                                },
                              )),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: 10,),
                                Text(
                                  sertitle,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.arrow_downward,
                                          color: Colors.green,
                                          size: 11,
                                        ),
                                        //Text('off',style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold),),
                                        Text(
                                          '${calculatePercentage(sermrp, sercharge).toStringAsFixed(2)}%',
                                          style: TextStyle(
                                              fontSize: 11,
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
                                            fontSize: 11,
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
                                            fontSize: 12,
                                            color: Colors.pink,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(onPressed: (){
                            User? user = FirebaseAuth.instance.currentUser;
                            if(user!=null)
                            {
                              addservicetocartwidget(topref.path.toString(), sertitle, serid, '1', sercharge,
                                  servisitingcharge, sergstcharge,photosUrl.first );
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

                                }, icon: Icon(Icons.add_shopping_cart,color: Colors.green,size: 24,))
                              ],
                            ),
                          )
                        ],
                      ),
                    )),
                desktop:  Container(
                    margin: const EdgeInsets.all(4),
                    width: 500,
                    height: 220,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Card(
                      color: Colors.white,
                      surfaceTintColor: Colors.white54,
                      elevation: 1,
                      margin: const EdgeInsets.all(2),
                      child: Row(
                        children: [
                          ClipRRect(
                            // Apply rounded corners to the image
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                photosUrl.elementAt(randomIndex),
                                width: 270,
                                height: 220,
                                fit: BoxFit.cover,
                                loadingBuilder: (BuildContext context, Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  } else {
                                    return const SizedBox(
                                      width: 90,
                                      height: 100,
                                      child: Center(
                                        child: SizedBox(
                                            width: 30,
                                            height: 30,
                                            child: CircularProgressIndicator()),
                                      ),
                                    );
                                  }
                                },
                                errorBuilder: (BuildContext context, Object error,
                                    StackTrace? stackTrace) {
                                  return Image.asset(
                                    'assets/images/placeholder.png',
                                    width: 90,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  );
                                },
                              )),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: 10,),
                                Text(
                                  sertitle,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.arrow_downward,
                                          color: Colors.green,
                                          size: 12,
                                        ),
                                        //Text('off',style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold),),
                                        Text(
                                          '${calculatePercentage(sermrp, sercharge).toStringAsFixed(2)}%',
                                          style: TextStyle(
                                              fontSize: 12,
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
                                            decorationColor: Colors.blueGrey,
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
                                            fontSize: 13,
                                            color: Colors.pink,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(onPressed: (){
                                  User? user = FirebaseAuth.instance.currentUser;
                                  if(user!=null){
                                    addservicetocartwidget(topref.path.toString(), sertitle, serid, '1', sercharge,
                                        servisitingcharge, sergstcharge,photosUrl.first );
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

                                }, icon: Icon(Icons.add_shopping_cart,color: Colors.green,size: 24,))

                              ],
                            ),
                          )
                        ],
                      ),
                    )),
              ),
            );
          } else {
            childWidget =
            const SizedBox(); // or another default widget if the list is empty
          }
          return SizeTransition(
            sizeFactor: animation,
            child: childWidget,
          );
        }

        return const SizedBox(); // Return an empty container if data is not in the expected format.
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

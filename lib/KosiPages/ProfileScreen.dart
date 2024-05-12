import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:kosiservice/KosiPages/MyBookingPAge.dart';


import '../Models/UserModel.dart';
import '../Utils/AddressEditDialog.dart';
import '../Utils/AppColors.dart';


class UserProfile extends StatefulWidget {



  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {

  UserModel? userModel;
  String? phoneNumber;
  bool isloading=true;

  User? user = FirebaseAuth.instance.currentUser;
  
  void getUserDetails(String userPhoneNumber) {
    DatabaseReference userRef = FirebaseDatabase.instance.reference().child(
        'KosiService/User/$userPhoneNumber');
    userRef.onValue.listen((event) {
      final udata = event.snapshot.value;
      if (udata != null) {
        Map<dynamic, dynamic> data = udata as Map<dynamic, dynamic>;
        userModel = UserModel(
          name: data['name'] ?? '',
          userPhone: data['userphone'] ?? '',
          userLatitude: data['userlatitude'] ?? '',
          userLongitude: data['userlongitude'] ?? '',
          uid: data['uid'] ?? '',
          deviceId: data['deviceid'] ?? '',
          regDate: data['regdate'] ?? '',
          address: data['add'] ?? '',
          accountType: data['accounttype'] ?? '',
        );
        setState(() {
          isloading=false;
        });

      }
    }
    );

  }

 @override
  void initState() {
   phoneNumber= user?.phoneNumber.toString().substring(3,13);
   getUserDetails(phoneNumber.toString());
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('User Profile'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: SingleChildScrollView(
        child: isloading? Container(child: Center(child: CircularProgressIndicator())) : userModel != null? Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(6),
              child: Column(
                children: [
                  Image.asset('assets/images/user.png', height: 100),
                  SizedBox(height: 2),
                  Text(
                  userModel!.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Text(
                    'phone-' + (userModel!.userPhone),
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 8),
              child: Padding(
                padding: EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // My Order button action
                        },
                        child: Card(
                          elevation: 2,
                          color: Colors.white,
                          child: Padding(
                            padding: EdgeInsets.all(6),
                            child: Row(
                              children: [
                                Image.asset('assets/images/booking.png', height: 50),
                                SizedBox(width: 8),
                                Text(
                                  'My Booking',
                                  style: TextStyle(color: Colors.black),
                                ),
                                Spacer(),
                                IconButton(onPressed: () { Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => MyBookingPage()),
                                );}, icon: Icon(Icons.arrow_forward),)
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
            Card(
              elevation: 4,
              margin: EdgeInsets.all(12),
              child: Padding(
                padding: EdgeInsets.all(4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Default Address',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AddressInputDialog();
                            },
                          );
                        }, icon: Icon(Icons.edit),),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(userModel!.name, style: TextStyle(color: Colors.black)),
                    Text(userModel!.address, style: TextStyle(color: Colors.black)),
                    Text('India', style: TextStyle(color: Colors.black)),
                    Text('mob-'+(userModel!.userPhone), style: TextStyle(color: Colors.black)),
                  ],
                ),
              ),
            ),
          ],
        ):Text("Nodata"),
      ),
    );
  }
}


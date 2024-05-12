import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../Models/KosiUserModel.dart';


KosiUserModel? userData;

Future<void> getUserDetails(BuildContext context, String phoneNumber) async {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent user from dismissing the dialog
    builder: (BuildContext context) {
      return Center(
        child: CircularProgressIndicator(),
      );
    },
  );

  Completer<void> completer = Completer<void>();
  DatabaseReference userRef = FirebaseDatabase.instance.reference().child('KosiService/User/$phoneNumber');
  userRef.onValue.listen((event) {
    final udata = event.snapshot.value;
    if (udata != null) {
      Map<dynamic, dynamic> data = udata as Map<dynamic, dynamic>;
      userData = KosiUserModel(
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
        address: '',
      );
      print(userData!.name); // Print user's name after successfully retrieving data
      completer.complete(); // Signal that the operation is complete
    } else {
      completer.completeError('User data not found'); // Signal completion with an error if data is not found
    }
  });

  try {
    await completer.future; // Await for the completer to complete
  } catch (error) {
    print('Error fetching user data: $error'); // Handle any errors that occur during data retrieval
  } finally {
    Navigator.of(context).pop(); // Close the loading dialog
  }
}


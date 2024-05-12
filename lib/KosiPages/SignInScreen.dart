import 'package:android_id/android_id.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:restart_app/restart_app.dart';
import 'KosiHomePage.dart';
import '../Models/KosiUserModel.dart';
import '../Models/UserModel.dart';
import '../Utils/AppColors.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool otpSent = false;
  late String _phoneNumber="";
  late String _verificationId;
  late String _otp;
  late String buttontext = 'GET OTP';
  late String _name;

  @override
  void initState() {
    super.initState();

  }
  Future<void> _verifyPhoneNumber() async {
    final PhoneVerificationCompleted verificationCompleted =
        (PhoneAuthCredential credential) async {
      await _auth.signInWithCredential(credential);
      await _auth.signInWithCredential(credential);
      User? user = FirebaseAuth.instance.currentUser;
      DateTime currentDate = DateTime.now();
      String formattedDate = DateFormat('d/M/yy').format(currentDate);
      String  device;
      if (kIsWeb) {
        device='web';
      } else {
        device='app';

      }
      KosiUserModel userModel = KosiUserModel(
        name: _name,
        userPhone: _phoneNumber.substring(3,13),
        userLatitude: "",
        userLongitude: "",
        uid: user!.uid.toString(),
        deviceId: device,
        regDate: formattedDate,
        address: "",
        accountType: 'Normal',
        balance: '0',
        referalcode: '${user.uid.substring(4, 7)}${_phoneNumber.substring(3,5)}',
      );
      _pushUserModelToRealtimeDB(userModel);
      
      Navigator.push(
        context, MaterialPageRoute(builder: (context) => KosiHomePage()),
      );
    };

    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Verification Failed: $e')));
      print('Verification Failed: $e');
    };

    final PhoneCodeSent codeSent =
        (String verificationId, int? resendToken) async {
      _verificationId = verificationId;
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {};

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: _phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error sending verification code: $e')));
      print('Error sending verification code: $e');
    }
  }

  Future<void> verify() async {
    try {
      // Use _verificationId and the OTP entered by the user to create a PhoneAuthCredential
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otp,
      );
      await _auth.signInWithCredential(credential);
      User? user = FirebaseAuth.instance.currentUser;
      DateTime currentDate = DateTime.now();
      String formattedDate = DateFormat('d/M/yy').format(currentDate);
      String  device;
      if (kIsWeb) {

       device='web';
      } else {
        device='app';

      }
      KosiUserModel userModel = KosiUserModel(
        name: _name,
        userPhone: _phoneNumber.substring(3,13),
        userLatitude: "",
        userLongitude: "",
        uid: user!.uid.toString(),
        deviceId: device,
        regDate: formattedDate,
        address: "",
        accountType: 'Normal',
        balance: '0',
        referalcode: '${user.uid.substring(4, 7)}${_phoneNumber.substring(3,5)}',
      );
      
      _pushUserModelToRealtimeDB(userModel);
      Restart.restartApp();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => KosiHomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error verifying OTP: $e')));
      print('Error verifying OTP: $e');
    }
  }

  void _pushUserModelToRealtimeDB(KosiUserModel userModel) async {
    String phoneNumber = _phoneNumber.substring(3, 13);
    var externalId = phoneNumber; // You will supply the external id to the OneSignal SDK
    OneSignal.login(externalId);
    OneSignal.User.pushSubscription.optIn();

    try {
      final DatabaseReference usersRef = FirebaseDatabase.instance
          .reference()
          .child('KosiService')
          .child('User')
          .child(phoneNumber);

      Map<String, dynamic> userMap = userModel.toMap();

      await usersRef.update(userMap);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('account created')));

    Restart.restartApp( );
      // Restart the application after successful login
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => KosiHomePage()),
            (route) => false, // Remove all existing routes from the stack
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding user data to Realtime Database: $e')));
    }
  }


  @override
  Widget build(BuildContext context) {

    User? user = _auth.currentUser;
    if (user != null) {
      return KosiHomePage();
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor:AppColors.primaryColor ,
        title: Text('Login to Kosi Service'),
      ),
      backgroundColor: const Color(0xFFA9FCDB),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 4),
              Image.asset(
                'assets/images/logofirst.png',
                height: 100,
                width: double.infinity,
              ),
              const SizedBox(height: 4),
              const Text(
                'Sign_In',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                margin: const EdgeInsets.all(8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      const Text(
                        'verify_your_phone_number',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Enter your name',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          _name = value;
                        },
                        maxLength: 10,
                      ),
                      TextField(
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'Enter phone number',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          _phoneNumber = '+91'+value;
                        },
                        maxLength: 10,
                      ),
                      const SizedBox(height: 2),
                      if (otpSent) // Only show OTP text field when OTP is sent
                        TextField(
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: 'Enter Otp',
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            _otp = value;
                          },
                          maxLength: 6,
                        ),
                      const SizedBox(height: 4),
                      ElevatedButton(
                        onPressed: () async {
                          if (buttontext == 'GET OTP') {
                            if (_phoneNumber.length == 13) {
                              setState(() {
                                buttontext = 'Sending OTP';
                              });
                              try {
                                await _verifyPhoneNumber();
                                await Future.delayed(Duration(seconds: 4));
                                setState(() {
                                  buttontext = 'Verify OTP';
                                  otpSent = true; // Set OTP sent state
                                });
                              } catch (e) {
                                print('Error sending OTP: $e');
                                setState(() {
                                  buttontext = 'GET OTP';
                                });
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Invalid phone number')),
                              );
                            }
                          } else {
                            if (_otp.length == 6) {
                              setState(() {
                                buttontext = 'Verifying OTP';
                              });
                              try {
                                await verify();
                                setState(() {
                                  buttontext = 'OTP Verified';
                                });
                              } catch (e) {
                                print('Error verifying OTP: $e');
                                setState(() {
                                  buttontext = 'Verify OTP';
                                });
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Invalid otp')),
                              );
                            }
                          }
                        },
                        child: buttontext == 'Sending OTP' || buttontext == 'Verifying OTP'
                            ? CircularProgressIndicator() // Show progress indicator
                            : Text(buttontext),
                      ),


                      const SizedBox(height: 8),
                      InkWell(
                        child: const Text(
                          '-------Skip sign-------',
                          style: TextStyle(
                            color: Color(0xFF0A0A0A),
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => KosiHomePage()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              ],
          ),
        ),
      ),
    );
  }


}

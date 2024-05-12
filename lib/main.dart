import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kosiservice/KosiPages/KosiHomePage.dart';
import 'package:kosiservice/KosiPages/Map.dart';
import 'package:kosiservice/KosiPages/Cancel%20policy.dart';
import 'package:kosiservice/KosiPages/PrivacyPolicy.dart';
import 'package:kosiservice/KosiPages/TermsandCondition.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'KosiPages/SplashScreen.dart';
import 'package:flutter/material.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyBScD54azyQNpWJ03bQ8fX-NEOmWvqho4s",
          authDomain: "firstandfast-781dd.firebaseapp.com",
          databaseURL: "https://firstandfast-781dd-default-rtdb.firebaseio.com",
          projectId: "firstandfast-781dd",
          storageBucket: "firstandfast-781dd.appspot.com",
          messagingSenderId: "987733786476",
          appId: "1:987733786476:web:fd03f93c768ed7f0273d49",
          measurementId: "G-VEVLPJJL1B"
      )
  );
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

  OneSignal.initialize("e2fa9bad-fd7f-4d34-b2ed-14d28772867d");
  OneSignal.Notifications.requestPermission(true);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MyApp());
}
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message)async {
  await Firebase.initializeApp();
  print('show ${message.notification!.body}');
}



class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kosi Service',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => KosiHomePage(), // Assuming SplashScreen is your initial page
        '/terms-conditions': (context) => TermsAndConditions(),
        '/refund-return': (context) => CancellationPolicyPage(),
        '/privacypolicy': (context) => PrivacyPolicy(),
      },
    );
  }
}


import 'package:flutter/material.dart';
import 'package:kosiservice/KosiPages/KosiHomePage.dart';

import 'package:kosiservice/Utils/AppColors.dart';



class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 2), () {
      // Replace 'HomeScreen()' with your main app screen
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => KosiHomePage(),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logofirst.png', // Path to your icon image
                  width: 200,
                  height: 200,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4,bottom: 2),
                  child: Text('Kosi Service',style: TextStyle(color: AppColors.primaryColor,fontSize: 40,fontWeight: FontWeight.bold,fontFamily: 'RobotoSlab'),),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('"Need a service? Get it done in just one click!"',style: TextStyle(color: AppColors.primaryColor,fontSize: 18),),
                )
              ]
          ),
        ),
      ),
    );
  }
}


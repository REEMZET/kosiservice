import 'package:flutter/material.dart';

import '../Utils/AppColors.dart';

class PrivacyPolicy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          title: Text('Privacy Policy'),
        ),
        body: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Privacy Policy',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Effective Date: January 1, 2024',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'This Privacy Policy describes how Indpe Kosi Service Private Limited ("Kosi Service," "we," "us," or "our") collects, uses, and shares information when you use our mobile application ("App"). By using the App, you agree to the collection and use of information in accordance with this policy.',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Information Collection and Use',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'We may collect several types of information for various purposes to provide and improve our App:',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    '- Personal Data: While using our App, we may ask you to provide us with certain personally identifiable information that can be used to contact or identify you ("Personal Data"). This may include your name, email address, phone number, and other information.',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    '- Usage Data: We may also collect information about how the App is accessed and used ("Usage Data"). This Usage Data may include information such as your device\'s Internet Protocol address (e.g., IP address), device type, browser type, the pages of our App that you visit, the time and date of your visit, the time spent on those pages, unique device identifiers, and other diagnostic data.',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Use of Data',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'We use the collected data for various purposes, including:',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    '- To provide and maintain our App',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  Text(
                    '- To notify you about changes to our App',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  Text(
                    '- To allow you to participate in interactive features of our App when you choose to do so',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  Text(
                    '- To provide customer support',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  Text(
                    '- To gather analysis or valuable information so that we can improve our App',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Security',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                      'The security of your data is important to us, but remember that no method of transmission over the '
                          'Internet or method of electronic storage is'),
                ]
            )

        )
    );
  }
}

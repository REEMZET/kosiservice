import 'package:flutter/material.dart';
import '../Utils/AppColors.dart';

class TermsAndConditions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text('Terms and Conditions'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms and Conditions',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              '1. Services',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'The Services provided by Kosi Service (Indpe Kosi Service Pvt. Ltd.) include arranging and scheduling home-based services with third-party providers. Kosi Service facilitates payments to service professionals and collects payments on their behalf.',
              style: TextStyle(fontSize: 16.0),
            ),
            Text(
              'सेवाएं',
              style: TextStyle(fontSize: 16.0),
            ),
            Text(
              'कोसी सेवा (इंडिपी कोसी सेवा प्रा. लि.) द्वारा प्रदान की जाने वाली सेवाएं घर के आधारित सेवा प्रदाताओं के साथ सेवाओं का आयोजन और अनुसूचित करना शामिल है। कोसी सेवा सेवा पेशेवरों को भुगतान करने की सुविधा प्रदान करती है और उनके लिए भुगतान जमा करती है।',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            Text(
              '2. Creation of Account',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'To use the Services, users must create an account on the Platform. Users must be at least 18 years old and provide accurate information. Users are responsible for maintaining the security of their accounts and notifying Kosi Service of any unauthorized use.',
              style: TextStyle(fontSize: 16.0),
            ),
            Text(
              'खाता बनाना',
              style: TextStyle(fontSize: 16.0),
            ),
            Text(
              'सेवाओं का उपयोग करने के लिए उपयोगकर्ताओं को प्लेटफ़ॉर्म पर खाता बनाना होगा। उपयोगकर्ताओं को कम से कम 18 वर्ष का होना चाहिए और सटीक जानकारी प्रदान करनी चाहिए। उपयोगकर्ताओं को अपने खातों की सुरक्षा बनाए रखने और किसी अनधिकृत उपयोग की सूचना कोसी सेवा को देने की जिम्मेदारी है।',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            Text(
              '3. Bookings',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Users can request services through the Platform based on available slots. If a service professional is not available for the requested time, users will be contacted to find an alternative time.',
              style: TextStyle(fontSize: 16.0),
            ),
            Text(
              'बुकिंग',
              style: TextStyle(fontSize: 16.0),
            ),
            Text(
              'उपयोगकर्ता उपलब्ध स्लॉट के आधार पर प्लेटफ़ॉर्म के माध्यम से सेवाएं अनुरोध कर सकते हैं। यदि अनुरोधित समय के लिए कोई सेवा पेशेवर उपलब्ध नहीं है, तो उपयोगकर्ताओं को एक वैकल्पिक समय खोजने के लिए संपर्क किया जाएगा।',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            Text(
              '4. Pricing, Fees, and Payment Terms',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Kosi Service reserves the right to charge users for services and facilities provided. Users will be notified of applicable charges, fees, and payment methods at the time of booking. Payment can be made through various methods such as credit cards, debit cards, net banking, wallets, UPI, or cash upon completion of the service.',
              style: TextStyle(fontSize: 16.0),
            ),
            Text(
              'मूल्य निर्धारण, शुल्क, और भुगतान शर्तें',
              style: TextStyle(fontSize: 16.0),
            ),
            Text(
              'कोसी सेवा सेवाओं और सुविधाओं के लिए उपयोगकर्ताओं से शुल्क लेने का अधिकार सुरक्षित रखती है। उपयोगकर्ताओं को बुकिंग करने के समय लागू शुल्क, शुल्क, और भुगतान के तरीकों की सूचना दी जाती है। भुगतान क्रेडिट कार्ड, डेबिट कार्ड, नेट बैंकिंग, वॉलेट, यूपीआई, या सेवा पूरी करने के बाद नकदी जैसे विभिन्न तरीकों से किया जा सकता है।',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'Powered by Indpe Kosi Service Pvt Ltd',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            TextButton(
              onPressed: () {
                // Open the website in a browser
              },
              child: Text(
                'https://www.kosiservice.com',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

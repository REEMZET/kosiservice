import 'package:flutter/material.dart';
import '../Utils/AppColors.dart';

class CancellationPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text('Cancellation Policy'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Cancellation Policy:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Text(
                'You can cancel service purchased from KOSI SERVICE (INDPE KOSI SERVICE PVT. LTD.) within the specified time period, except for our non-cancelable service.',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                'Create a ‘Cancel Request’ under the “My Orders” section of the Website (https://www.kosiservice.com/) or a mobile app. Follow the screens that come up after tapping on the ‘Cancel’ button. Please make a note of the Cancel that we generate at the end of the process.',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                'We offer to cancel any service, before 3 hours of service booked time slot. Refund amount will transfer to your account in 2 - 4 working days. If you cancel your service in between the booked slot to 3 hrs, you will be charged ₹99 per booked service.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24.0),
              Text(
                'Refund Policy:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Text(
                'The refund process will begin after our team reviews your cancellation request. If your request is approved, the refund amount will be transferred to your designated bank account within 2 - 4 working days.',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                'Please note that the refund amount will be provided according to the specified refund policy.',
                style: TextStyle(fontSize: 16),
              ),

              SizedBox(height: 24.0),
              Text(
                'रद्दीकरण नीति:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Text(
                'आप कोसी सेवा (इंडपी कोसी सेवा प्रा. लि.) से खरीदी गई सेवा को निर्दिष्ट समय अवधि के भीतर रद्द कर सकते हैं, हमारी गैर-रद्द की जाने वाली सेवा को छोड़कर।',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                'वेबसाइट (https://www.kosiservice.com/) या मोबाइल ऐप के "मेरे आदेश" खंड में "रद्द अनुरोध" बनाएं। \'रद्द\' बटन पर टैप करने के बाद आने वाली स्क्रीनों का पालन करें। कृपया प्रक्रिया के अंत में हमारे द्वारा उत्पन्न रद्द को ध्यान से रखें।',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                'हम किसी भी सेवा को रद्द करने का प्रस्ताव देते हैं, सेवा बुक की गई समय स्लॉट से 3 घंटे पहले। रिफंड राशि को आपके खाते में 2 - 4 कार्य दिनों में हस्तांतरित किया जाएगा। यदि आप बुक की गई सेवा को बुक की गई स्लॉट से 3 घंटे के बीच में रद्द करते हैं, तो आपको प्रति बुक की गई सेवा के लिए ₹99 का शुल्क लगाया जाएगा।',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24.0),
              Text(
                'रिफंड नीति:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Text(
                'हमारी टीम आपके रद्द अनुरोध की समीक्षा करने के बाद रिफंड प्रक्रिया शुरू करेगी। यदि आपका अनुरोध स्वीकृत होता है, तो रिफंड राशि को आपके निर्दिष्ट बैंक खाते में 2 - 4 कार्य दिनों के भीतर हस्तांतरित किया जाएगा।',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                'ध्यान दें कि रिफंड राशि को निर्धारित किए गए रिफंड नीति के अनुसार ही प्रदान किया जाएगा।',
                style: TextStyle(fontSize: 16),
              ),

              SizedBox(height: 24.0),
              Text(
                'Powered by Indpe Kosi Service Pvt Ltd',
                style: TextStyle(fontSize: 14),
              ),
              TextButton(
                onPressed: () {
                  // Open the website in a browser
                },
                child: Text(
                  'https://www.kosiservice.com',
                  style: TextStyle(color: Colors.blue),
                ) ,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

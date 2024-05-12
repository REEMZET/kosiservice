import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late String paymentId;
  late String paymentPurpose;
  late double paymentAmount;
  late String paymentName;
  late String paymentPhone;
  late String paymentEmail;
  late String redirectUrl;
  late String paymentStatus;

  @override
  void initState() {
    super.initState();
    paymentId = "o1m8sx"; // Sample payment ID
    paymentPurpose = "Sample Purpose";
    paymentAmount = 1.0;
    paymentName = "John Doe";
    paymentPhone = "1234567890";
    paymentEmail = "john.doe@example.com";
    redirectUrl = "https://example.com/payment_success";
    paymentStatus = "";
  }

  Future<Map<String, dynamic>> initializePayment({
    required String paymentId,
    required String paymentPurpose,
    required double paymentAmount,
    required String paymentName,
    required String paymentPhone,
    required String paymentEmail,
    required String redirectUrl,
  }) async {
    final String apiUrl = "https://zgw.oynxdigital.com/api_payment_init.php";
    final String accountId = ""; // Add your account ID
    final String secretKey = ""; // Add your secret key

    Map<String, dynamic> data = {
      "account_id": accountId,
      "secret_key": secretKey,
      "payment_id": paymentId,
      "payment_purpose": paymentPurpose,
      "payment_amount": paymentAmount,
      "payment_name": paymentName,
      "payment_phone": paymentPhone,
      "payment_email": paymentEmail,
      "redirect_url": redirectUrl,
    };

    http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"init_payment": data}),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> fetchPaymentDetails(String paymentId) async {
    final String apiUrl = "https://zgw.oynxdigital.com/api_payment_status.php";
    final String accountId = "o1m8sx"; // Add your account ID
    final String secretKey = "C90zsJjssmrm"; // Add your secret key

    Map<String, dynamic> data = {
      "account_id": accountId,
      "secret_key": secretKey,
      "payment_id": paymentId,
    };

    http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"fetch_payment": data}),
    );

    return jsonDecode(response.body);
  }

  Future<void> makePayment() async {
    try {
      Map<String, dynamic> response = await initializePayment(
        paymentId: paymentId,
        paymentPurpose: paymentPurpose,
        paymentAmount: paymentAmount,
        paymentName: paymentName,
        paymentPhone: paymentPhone,
        paymentEmail: paymentEmail,
        redirectUrl: redirectUrl,
      );

      if (response.containsKey("error")) {
        setState(() {
          paymentStatus = "Error: ${response['error']}";
        });
      } else {
        setState(() {
          paymentStatus = "Payment initialized";
        });
        // Perform navigation or open webview to redirectUrl
      }
    } catch (e) {
      setState(() {
        paymentStatus = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Make Payment"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Payment Status: $paymentStatus",
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: makePayment,
              child: Text("Make Payment"),
            ),
          ],
        ),
      ),
    );
  }
}

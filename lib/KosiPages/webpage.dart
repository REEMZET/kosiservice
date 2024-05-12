import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WebViewPage extends StatelessWidget {
  final String url;

  WebViewPage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Web Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            if (await canLaunch(url)) {
              await launch(url);
            } else {
              // Handle error
              throw 'Could not launch $url';
            }
          },
          child: Text('Open in Browser'),
        ),
      ),
    );
  }
}

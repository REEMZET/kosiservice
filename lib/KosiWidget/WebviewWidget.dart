import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SimpleWebView extends StatelessWidget {
  final String url;

  SimpleWebView({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Simple WebView'),
      ),
      body: Column(
        children: [
          // You can add additional widgets below the WebView if needed
          // For example, you can use the HtmlWidget to render HTML content

        ],
      ),
    );
  }
}
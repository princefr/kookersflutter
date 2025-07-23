import 'package:flutter/material.dart';
import 'package:kookers/Widgets/TopBar.dart';
import 'package:webview_flutter/webview_flutter.dart';





class WebViewPage extends StatefulWidget {
  final String title;
  final String url;
  WebViewPage({Key? key, required this.url, required this.title}) : super(key: key);

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBarWitBackNav(title: this.widget.title, height: 54, isRightIcon: false,),
      body: WebView(initialUrl: this.widget.url,),
    );
  }
}
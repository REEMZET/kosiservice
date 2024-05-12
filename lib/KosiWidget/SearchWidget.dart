import 'dart:async';

import 'package:flutter/material.dart';

import '../KosiPages/SearchItem.dart';

class SearchWidget extends StatefulWidget {
  const SearchWidget({super.key});

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final List<String> searchHints = ["'Electrician'", "'Cleaners'", "'AC repair'","'Washroom Cleaning'","'Driver'"];
  int hintIndex = 0;
  Timer? hintTimer;
  String currentHint = "";

  @override
  void initState() {
    super.initState();
    // Start the timer to change the hint text
    hintTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        hintIndex = (hintIndex + 1) % searchHints.length;
        _updateHintText();
      });
    });
  }

  @override
  void dispose() {

    hintTimer?.cancel();
    super.dispose();
  }

  void _updateHintText() {
    setState(() {
      currentHint = "";
    });

    String hint = searchHints[hintIndex];
    int length = hint.length;

    for (int i = 0; i < length; i++) {
      Timer(Duration(milliseconds: (i + 1) * 150), () {
        setState(() {
          currentHint = hint.substring(0, i + 1);
        });
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchServices(),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 40, right: 40, top: 18,bottom: 20),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: Colors.grey[200],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.search,
                  color: Colors.black54,
                  size: 19,
                ),
                SizedBox(width: 8.0),
                Expanded(
                  child: TweenAnimationBuilder(
                    duration: Duration(milliseconds: 500),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, double value, child) {
                      return Opacity(
                        opacity: value,
                        child: Text(
                         'Search for $currentHint',
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    },
                  ),
                ),
                Icon(Icons.arrow_circle_right_outlined, size: 18, color: Colors.black87),
                SizedBox(width: 2,)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

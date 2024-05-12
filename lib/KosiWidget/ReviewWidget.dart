import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kosiservice/KosiPages/SubcateogoryDetailPage.dart';


class ReviewWidget extends StatefulWidget {
 final String reviewref;
  ReviewWidget({required this.reviewref});

  @override
  State<ReviewWidget> createState() => _ReviewWidgetState();
}

class _ReviewWidgetState extends State<ReviewWidget> {
  late final  reviewref;

  @override
  void initState() {
    reviewref=FirebaseDatabase.instance.ref(widget.reviewref);

    super.initState();
  }
  Color getRandomColor() {
    Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }
  @override
  Widget build(BuildContext context) {
    return FirebaseAnimatedList(

      scrollDirection: Axis.vertical,
      physics: NeverScrollableScrollPhysics(),
      query:reviewref.child('reviews'),
      itemBuilder: (context, snapshot, animation, index) {
        String reviewmsg = snapshot.child('reviewmsg').value.toString();
        String reviewdate=snapshot.child('reviewdate').value.toString();
        String uid=snapshot.child('uid').value.toString();
        String username=snapshot.child('username').value.toString();
        String userphone=snapshot.child('userphone').value.toString();
        String rating=snapshot.child('rating').value.toString();


        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Card(
                      margin: EdgeInsets.only(left: 8,right: 8),
                      elevation: 2,
                      color: getRandomColor(),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 14,right: 14,bottom: 8,top: 8),
                        child: Text(username.substring(0,1).toUpperCase(),style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),),
                      ),
                    ),
                    Column(
                      children: [
                        Text(username.toUpperCase(),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                        Text(reviewdate,style: TextStyle(color:  Colors.grey,fontSize: 12),)
                      ],
                    ),
                  ],
                ),

                Row(children: [
                  Icon(Icons.star,size: 18,color: CupertinoColors.systemGreen,),
                  Text(rating),
                ],)


              ],
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(reviewmsg,style: TextStyle(color: Colors.black,fontSize: 16),),
            ),
            Divider()

          ],
        );
      },
    );
  }
}

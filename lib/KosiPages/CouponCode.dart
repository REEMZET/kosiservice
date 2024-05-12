import 'package:clipboard/clipboard.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

import '../Utils/AppColors.dart';

class CouponCode extends StatefulWidget {
  const CouponCode({super.key});

  @override
  State<CouponCode> createState() => _CouponCodeState();
}

class _CouponCodeState extends State<CouponCode> {

  Widget getCuponCode() {

    final ref =
    FirebaseDatabase.instance.ref('FirstClick/offerlist');
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xfff7f5f6),
          borderRadius: BorderRadius.circular(0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 2,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: FirebaseAnimatedList(
          query: ref,
          itemBuilder: (context, snapshot, animation, index) {
            String offername = snapshot.child('offername').value.toString();
            String  offercode = snapshot.child('offercode').value.toString();
            String offerdetails = snapshot.child('offerdetails').value.toString();
            String offerdiscount = snapshot.child('offerdiscount').value.toString();
            String offerid = snapshot.child('offerid').value.toString();
            String  offerservice = snapshot.child('offerservice').value.toString();





            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Image.asset('assets/images/coupon.png',height: 50,width: 70,),
                        Container(
                                height:30,width:220,child: Text(offername,maxLines: 2,textAlign: TextAlign.center,style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),)
                            ),
                      ],
                    ),
                    Text('Offer on $offerservice',style: TextStyle(color: Colors.cyan,fontWeight: FontWeight.bold),),
                    OutlinedButton(
                      onPressed: () {
                        FlutterClipboard.copy(offercode);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('copied')));
                      },
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10,right: 10),
                            child: Text(offercode),
                          ),
                          Text('tap to copy code',style: TextStyle(fontSize: 6,color: Colors.grey),)

                        ],
                      ),

                    ),
                    Text(offerdetails,style: TextStyle(color: Colors.black54,fontSize: 8),),

                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text('Coupon Code and Offers'),
      ),
      body: Column(
        children: [
          // Other widgets
          getCuponCode(),
        ],
      ),
    );
  }
}

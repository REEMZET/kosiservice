
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:kosiservice/KosiPages/SignInScreen.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../KosiPages/SubCateogoryServiceList.dart';
import 'Pagerouter.dart';
class ImageSliderFromFirebase extends StatefulWidget {
  @override
  _ImageSliderFromFirebaseState createState() => _ImageSliderFromFirebaseState();
}

class _ImageSliderFromFirebaseState extends State<ImageSliderFromFirebase> {
  List<String> imageUrls = [];
  List<String> eventlist=[];
  List<String> mediaUrls = [];
  List<String>catlist=[];
  List<String>titlelist=[];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> serviceCategories = [];
  List<String> servicesubtitle = [];
  List<String> servicekey = [];
  List<String> servicequotes = [];
  List<List<String>?> serimgvidlist = [];
  final serviceref = FirebaseDatabase.instance.reference().child('Kosisevice/Services/');

  @override
  void initState() {
    super.initState();
    fetchDataFromFirebase();
  }

  Future<void> fetchDataFromFirebase() async {
    try {
      final databaseReference =
      FirebaseDatabase.instance.reference().child('KosiService/slider');
      DataSnapshot dataSnapshot =
      await databaseReference.once().then((event) => event.snapshot);

      Map<dynamic, dynamic>? sliderData = dataSnapshot.value as Map<dynamic, dynamic>?;
      if (sliderData != null) {
        sliderData.forEach((key, value) {
          String imageUrl = value['posterurl'];
          String eventText = value['posterevent'];
         imageUrls.add(imageUrl);
         eventlist.add(eventText);
         setState(() {

         });
        });

      }
      else {
        // Handle the case where the data is not in the expected format.
        print('Data is not in the expected format');
        // You can display an error message to the user or take appropriate action.
      }
    } catch (e) {
      // Handle exceptions here.
      print('Error accessing Firebase: $e');
      // You can display an error message to the user or take appropriate action.
    }
  }

  Future<void> fetchCatData() async {
    final ref = FirebaseDatabase.instance.ref('KosiService/ServiceFolder');
    try {
      final snapshot = await ref.once();
      if (snapshot.snapshot.value != null) {
        final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
        for (final entry in data.entries) {
          final title = entry.value['sercatname'];
          final subtitle=entry.value['catmsg'];
          dynamic photosUrlValue = entry.value['serimgvideo'];
          final key=entry.value['key'];
          final quotes=entry.value['quotes'];
          List<String>? imgvideolist;
          if (photosUrlValue is List<dynamic>) {
            imgvideolist = List<String>.from(
                photosUrlValue.map((dynamic item) => item.toString()));
          }
          serviceCategories.add(title);
          servicesubtitle.add(subtitle);
          servicekey.add(key);
          servicequotes.add(quotes);
          serimgvidlist.add(imgvideolist);
        }
        setState(() {
        });
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      setState(() {
        // Handle the error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
        mobile: CarouselSlider(
        options: CarouselOptions(
          autoPlay: true,
          aspectRatio: 21 / 9,
          enlargeCenterPage: false,
         disableCenter: true,
          pageSnapping: true,
          viewportFraction: 1
      
        ),
        items: imageUrls.asMap().entries.map((entry) {
          int index = entry.key;
          String imageUrl = entry.value;
          String eventText = eventlist[index];
          return Builder(
            builder: (BuildContext context) {
              return InkWell(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                onTap: (){
                 if(eventText!="no"){
                   Navigator.push(context, customPageRoute(SubCateogoryServiceList(subcatlistref:eventText,title:'Kosi Service',)));
                 }
                },
              );
            },
          );
        }).toList(),
      ),
        desktop: CarouselSlider(
          options: CarouselOptions(
              autoPlay: true,
              aspectRatio: 21 / 10,
              enlargeCenterPage: true,
              disableCenter: true,
              pageSnapping: true,
              viewportFraction: 1

          ),
          items: imageUrls.asMap().entries.map((entry) {
            int index = entry.key;
            String imageUrl = entry.value;
            String eventText = eventlist[index];
            return Builder(
              builder: (BuildContext context) {
                return InkWell(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.all(60),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  onTap: (){
                    if(eventText!="no"){
                      Navigator.push(context, customPageRoute(SubCateogoryServiceList(subcatlistref:eventText,title:'Kosi Service',)));
                    }
                  },
                );
              },
            );
          }).toList(),
        ),
    );
  }
}

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../KosiPages/SubcateogoryDetailPage.dart';
import '../Utils/Pagerouter.dart';

class ServiceFolder extends StatefulWidget {
  const ServiceFolder({Key? key}) : super(key: key);

  @override
  State<ServiceFolder> createState() => _ServiceFolderState();
}


FirebaseAnalytics analytics = FirebaseAnalytics.instance;
class _ServiceFolderState extends State<ServiceFolder> {
  late int itemcount = 4;
  final ref = FirebaseDatabase.instance.ref('KosiService/ServiceFolder');

  Widget Menu() {
    return FutureBuilder<DatabaseEvent>(
      future: ref.once(),
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData) {
          return Text('No data available');
        }

        final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
        itemcount = data.length;

        return GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 0.1,
            mainAxisSpacing: 0.1,
          ),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final title = data.entries.elementAt(index).value['sercatname'];
            final imageUrl =
            data.entries.elementAt(index).value['sercatimg'];
            dynamic photosUrlValue =
            data.entries.elementAt(index).value['serimgvideo'];
            final key = data.entries.elementAt(index).value['key'];
            final quotes = data.entries.elementAt(index).value['quotes'];
            List<String>? imgvideolist;
            if (photosUrlValue is List<dynamic>) {
              imgvideolist = List<String>.from(photosUrlValue
                  .map((dynamic item) => item.toString()));
            }

            return GestureDetector(
              onTap: () async {
                print('key -$key');

                await FirebaseAnalytics.instance.logEvent(
                  name: title,
                  parameters: {
                    "image_name":title,
                    "full_text": 'Folder menu click',
                  },
                );


                Navigator.push(
                  context,
                  customPageRoute(
                    SubCateogoryDetailPage(
                      cateogory: title,
                      imgvideolist: imgvideolist,
                      serkey: key,
                      quotes: quotes,
                    ),
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    elevation: 0.4,
                    child: Container(
                      height: 80,
                      width: 90,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> fetchCatData() async {
    try {
      final snapshot = await ref.once();
      if (snapshot.snapshot.value != null) {
        final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
        itemcount = data.length;
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      setState(() {
        // Handle the error
      });
    }
  }

  @override
  void initState() {
    Firebase.initializeApp(); // Initialize Firebase
    fetchCatData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: Container(
        margin: EdgeInsets.only(left: 8, right: 8),
        height: (itemcount / 3) * 200,
        child: Menu(),
      ),
      desktop: Container(
        margin: EdgeInsets.only(left: 8, right: 8),
        height: (itemcount / 3) * 600,
        child: Menu(),
      ),
    );
  }
}

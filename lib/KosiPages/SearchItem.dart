import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Utils/AppColors.dart';
import '../Utils/Pagerouter.dart';
import 'SubCateogoryServiceList.dart';

class SearchServices extends StatefulWidget {
  @override
  _SearchServicesState createState() => _SearchServicesState();
}

class _SearchServicesState extends State<SearchServices> {
  final TextEditingController _searchController = TextEditingController();

  late Query query;



  @override
  void initState() {
    super.initState();
    query = FirebaseFirestore.instance.collection("Service");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Service',style: TextStyle(color: Colors.white),),
        backgroundColor: AppColors.primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: Colors.grey[100],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.search,
                      color: Colors.black87,
                      size: 20,
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: TextField(
                        style: const TextStyle(fontSize: 14),
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            if (value.length > 0)
                              query = FirebaseFirestore.instance
                                  .collection("Service")
                                  .where("tag", arrayContains: value)
                                  .limit(50);
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: "Search Services",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: query.snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final items = snapshot.data!.docs;
                List<Widget> itemList = [];

                for (var item in items) {
                  final model = ServiceModel.fromSnapshot(item);
                  itemList.add(
                    buildServiceItem(model),
                  );
                }

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Number of columns
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return itemList[index];
                  },
                  itemCount: itemList.length,
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget buildServiceItem(ServiceModel model) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(context, customPageRoute(SubCateogoryServiceList(subcatlistref: model.serref,title: model.sername,)));
        },
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(2),
              width: 90,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                image: DecorationImage(
                  fit: BoxFit.fitWidth,
                  scale: 2.0,
                  image: NetworkImage(model.serimgurl),
                ),
              ),
            ),
            Container(
              height: 20,
              child: Text(
                model.sername.length < 20
                    ? model.sername
                    : model.sername.substring(0, 20),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceModel {
  String sername;

  String serimgurl;

  List<String> itemtag;
  String serref;

  ServiceModel({
    required this.sername,
    required this.serimgurl,
    required this.itemtag,
    required this.serref,
  });

  factory ServiceModel.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    return ServiceModel(
      sername: data['servicetitle'] ?? '',
      serimgurl: data['itemimg'] ?? '',
      serref: data['serref'] ?? '',
      itemtag: (data['itemtag'] as List<dynamic>?)
              ?.map((tag) => tag.toString())
              .toList() ??
          [],
    );
  }
}

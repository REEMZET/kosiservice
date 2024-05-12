import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:kosiservice/KosiPages/SubCateogoryServiceList.dart';
import 'package:kosiservice/KosiWidget/PosterSlider.dart';
import 'package:kosiservice/KosiWidget/Recomendation.dart';
import 'package:kosiservice/KosiWidget/SearchWidget.dart';
import 'package:kosiservice/KosiWidget/ServiceFolder.dart';
import 'package:kosiservice/KosiWidget/TopWidget.dart';
import 'package:kosiservice/Utils/AppColors.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
// import the package
import 'package:responsive_builder/responsive_builder.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';
import '../KosiWidget/SigninBottomSheetWidget.dart';
import '../Models/KosiUserModel.dart';
import 'Cancel policy.dart';
import 'JobPage.dart';
import 'PrivacyPolicy.dart';
import 'ProfileScreen.dart';
import 'SignInScreen.dart';
import 'SplashScreen.dart';
import 'TermsandCondition.dart';
import 'webpage.dart';
import '../Utils/ImageSlider.dart';
import '../Utils/Pagerouter.dart';
import 'CartPage.dart';
import 'MyBookingPAge.dart';
import 'SubcateogoryDetailPage.dart';

class KosiHomePage extends StatefulWidget {
  const KosiHomePage({super.key});

  @override
  State<KosiHomePage> createState() => _KosiHomePageState();
}

late User? user;
late bool checkcart = true;

final FirebaseAuth _auth = FirebaseAuth.instance;

String? phoneNumber = user?.phoneNumber.toString().substring(3, 13);


class _KosiHomePageState extends State<KosiHomePage> {
  KosiUserModel? userModel;
  List<String> serviceCategories = [];
  List<String> servicesubtitle = [];
  List<String> servicekey = [];
  List<String> servicequotes = [];
  List<List<String>?> serimgvidlist = [];
  late int catsize = 8;
  BuildContext? currentcontext;
  late String currentcity = '';
  Position? _currentPosition;

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }
  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      getAddressFromLocation(position);
      setState(() {
        _currentPosition = position;
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }
  void getAddressFromLocation(Position position) async {
    String? city = await getAddressFromLatLng(position.latitude, position.longitude);
    setState(() {
      currentcity = city ?? 'Unknown'; // Set a default value if city is null
    });
  }


  Future<String?> getAddressFromLatLng(double lat, double lng) async {
    if (lat != null && lng != null) {
      String _host = 'https://maps.google.com/maps/api/geocode/json';
      final url =
          '$_host?key=AIzaSyAAQzj4K4H8RARgq-YNHh6G-YaKFdq3WgY&language=en&latlng=$lat,$lng'; // Replace YOUR_API_KEY with your actual API key
      try {
        var response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          Map data = jsonDecode(response.body);
          List<dynamic> results = data["results"];
          for (var result in results) {
            List<dynamic> addressComponents = result["address_components"];
            for (var component in addressComponents) {
              List<dynamic> types = component["types"];
              if (types.contains("locality")) {
                return component["long_name"];
              }
            }
          }
        }
      } catch (e) {
        print('Error: $e');
      }
    }
    return null;
  }

  Future<void> getUserDetails() async {
    Completer<void> completer = Completer<void>();
    DatabaseReference userRef = FirebaseDatabase.instance
        .reference()
        .child('KosiService/User/$phoneNumber');
    userRef.onValue.listen((event) {
      final udata = event.snapshot.value;
      if (udata != null) {
        Map<dynamic, dynamic> data = udata as Map<dynamic, dynamic>;
        userModel = KosiUserModel(
            name: data['name'] ?? '',
            userPhone: data['userphone'] ?? '',
            uid: data['uid'] ?? '',
            regDate: data['regdate'] ?? '',
            accountType: data['accounttype'] ?? '',
            balance: data['balance'] ?? '',
            referalcode: data['referalcode'],
            userLatitude: '',
            userLongitude: '',
            deviceId: '',
            address: '');
        setState(() {
          completer.complete(); // Signal that the operation is complete
        });
      }
    });

    return completer.future; // Return the future for external awaiters
  }

  Future<void> fetchCatData() async {
    final ref = FirebaseDatabase.instance.ref('KosiService/ServiceFolder');
    try {
      final snapshot = await ref.once();
      if (snapshot.snapshot.value != null) {
        final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
        catsize = data.length;
        for (final entry in data.entries) {
          final title = entry.value['sercatname'];
          final subtitle = entry.value['catmsg'];
          dynamic photosUrlValue = entry.value['serimgvideo'];
          final key = entry.value['key'];
          final quotes = entry.value['quotes'];
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
          // Update the state with the service categories
        });
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      setState(() {
        // Handle the error
      });
    }
  }

  ListView serviceListsFromCategories() {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      itemCount: serviceCategories.length,
      itemBuilder: (context, index) {
        final category = serviceCategories[index];
        final catsubtitle = servicesubtitle[index];
        final catserkey = servicekey[index];
        final catserquotes = servicequotes[index];
        final catserimgvid = serimgvidlist[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: serviceList(
              category, catsubtitle, catserkey, catserquotes, catserimgvid),
        );
      },
    );
  }

  Widget serviceList(String catname, String catsubtitle, String catserkey, String catserquotes, List<String>? catserimgvidlist) {
    final ref = FirebaseDatabase.instance
        .ref('KosiService/ServiceFolder/$catname/subcateogory');
    return Card(
      surfaceTintColor: Colors.white,
      color: Colors.white,
      elevation: 0.1,
      margin: EdgeInsets.only(top: 2),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: EdgeInsets.all(8),
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$catname',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: Align(alignment:Alignment.topLeft,
                            child: Text(catsubtitle,style: TextStyle(fontSize: 10,color: Colors.black54),)),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap:() {
                    Navigator.push(
                        context,
                        customPageRoute(
                          SubCateogoryDetailPage(
                              cateogory: catname,
                              imgvideolist: catserimgvidlist,
                              serkey: catserkey,
                              quotes: catserquotes),
                        ));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(alignment:Alignment.centerRight,child: Text('see all',style: TextStyle(color: Colors.blue),)),
                  ),
                )
              ],
            ),
            ScreenTypeLayout(
              mobile: Container(
                height: 190,
                margin: EdgeInsets.only(bottom: 5),
                width: double.maxFinite,
                child: FirebaseAnimatedList(
                  scrollDirection: Axis.horizontal,
                  query: ref,
                  itemBuilder: (context, snapshot, animation, index) {
                    String title = snapshot.child('subcattitle').value.toString();

                    List<String> subcatphotosUrl = [];
                    dynamic photosUrlValue = snapshot.child('subcatimage').value;
                    if (photosUrlValue is List<dynamic>) {
                      subcatphotosUrl = List<String>.from(
                          photosUrlValue.map((dynamic item) => item.toString()));
                    }

                    return InkWell(
                      onTap: () async {

                        await FirebaseAnalytics.instance.logEvent(
                          name: title,
                          parameters: {
                            "image_name":catname,
                            "full_text": 'Service List click',
                          },
                        );
                        Navigator.push(context, customPageRoute(SubCateogoryServiceList(subcatlistref: 'KosiService/ServiceFolder/$catname/subcateogory/${snapshot.key}/servicelist',title: title,)));
                      },
                      child:
                      Column(
                        children: [
                          Container(
                            margin: EdgeInsets.all(8),
                            height: 135,
                            width: 140,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.black26,
                                width: 0.2,
                              ),
                              image: DecorationImage(
                                fit: BoxFit.fill,
                                scale: 2.0,
                                image: NetworkImage( subcatphotosUrl.isNotEmpty
                                    ? subcatphotosUrl[Random().nextInt(subcatphotosUrl.length)]
                                    : 'https://firebasestorage.googleapis.com/v0/b/onlinemedis-f9e0a.appspot.com/o/image%20(2).png?alt=media&token=6733e85f-7213-45fa-a24d-b7420ee09b33',),
                              ),
                            ),
                          ),
                          SizedBox(height: 10,),
                          Text(
                            title.length < 20 ? title : title.substring(0, 20),
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ) ,
                    );
                  },
                ),
              ),
              desktop: Container(
                height: 300,
                margin: EdgeInsets.only(bottom: 5),
                width: double.maxFinite,
                child: FirebaseAnimatedList(
                  scrollDirection: Axis.horizontal,
                  query: ref,
                  itemBuilder: (context, snapshot, animation, index) {
                    String title = snapshot.child('subcattitle').value.toString();

                    List<String> subcatphotosUrl = [];
                    dynamic photosUrlValue = snapshot.child('subcatimage').value;
                    if (photosUrlValue is List<dynamic>) {
                      subcatphotosUrl = List<String>.from(
                          photosUrlValue.map((dynamic item) => item.toString()));
                    }

                    return InkWell(
                      onTap: () {
                        Navigator.push(context, customPageRoute(SubCateogoryServiceList(subcatlistref: 'KosiService/ServiceFolder/$catname/subcateogory/${snapshot.key}/servicelist',title: title,)));
                      },
                      child:
                      Column(
                        children: [
                          Container(
                            margin: EdgeInsets.all(8),
                            height: 250,
                            width: 250,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.black26,
                                width: 0.2,
                              ),
                              image: DecorationImage(
                                fit: BoxFit.fill,
                                scale: 2.0,
                                image: NetworkImage( subcatphotosUrl != null && subcatphotosUrl.isNotEmpty
                                    ? subcatphotosUrl[Random().nextInt(subcatphotosUrl.length)]
                                    : 'https://firebasestorage.googleapis.com/v0/b/onlinemedis-f9e0a.appspot.com/o/image%20(2).png?alt=media&token=6733e85f-7213-45fa-a24d-b7420ee09b33',),
                              ),
                            ),
                          ),
                          SizedBox(height: 10,),
                          Text(
                            title.length < 20 ? title : title.substring(0, 20),
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ) ,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  /*Future<bool> checkCartExists() async {
    Completer<bool> completer = Completer<bool>();
    cartref.onValue.listen((event) {

      final data = event.snapshot.value;
      if (data != null) {
        completer.complete(true);
        setState(() {
          checkcart=true;
        });

      } else {
        setState(() {
          checkcart=false;
        });
        completer.complete(false);

      }
    });
    return completer.future;
  }*/

  void launchEnquiryWhatsApp() async {
    String enquirymsg = '''
  *Enquiry for Kosi Service*

Hello Kosi Service team,

I'm interested in learning more about your repair services. 
Could you please provide me with information regarding availability, 
pricing, and any current offer? 
\nThank you!

''';

    final link = WhatsAppUnilink(
      phoneNumber: '+91-7667538694', // Replace with the appropriate phone number
      text: enquirymsg,
    );

    await launch('$link');
  }

  void openWebsite() async {
    var whatsappURl_android = "https://www.kosiservice.com";
    await launch(whatsappURl_android );
  }

  openyoutube() async{
    var whatsappURl_android = "https://www.youtube.com/@kosiservice";
    await launch(whatsappURl_android );
  }
  openfb() async{
    var whatsappURl_android = "https://www.facebook.com/profile.php?id=100091873388495&mibextid=nW3QTL";
    await launch(whatsappURl_android );
  }
  openinsta() async{
    var whatsappURl_android = "https://www.instagram.com/kosiservice";
    await launch(whatsappURl_android );
  }
  openplaystore() async{
    var whatsappURl_android = " https://play.google.com/store/apps/details?id=com.kosi.kosiservice&hl=en_US";
    await launch(whatsappURl_android );
  }
  void _makePhoneCall() {
    final String phoneNumber = '7667538694';
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    launch(phoneUri.toString());
  }
  void _shareContent() async {
    const url = 'https://kosiservice.com/';
    const imageUrl = 'https://i.ibb.co/4Szmv5r/logofirst.png'; // Replace with your image URL
    const message = 'Check out this website:\n$url';

    await Share.share(
      message,
      subject: 'https://kosiservice.com/',
    );
  }
  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.push(
        context as BuildContext, MaterialPageRoute(builder: (context) => SplashScreen()),
      );
    } catch (e) {
      print('Error during sign out: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    user=FirebaseAuth.instance.currentUser;
    fetchCatData();
    getUserDetails();
    _getCurrentPosition();

  }





  @override
  Widget build(BuildContext context) {

    currentcontext =context;
    return ScreenTypeLayout(
      mobile: Scaffold(
        drawer: DrawerWidget(),
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Kosi service',style: TextStyle(color: Colors.white),),
              Text(currentcity,style: TextStyle(color: Colors.white,fontSize: 14),),
            ],
          ),
          elevation: 0.0,
          backgroundColor: AppColors.primaryColor,
          actions: [
            InkWell(
              onTap: () {
                user=FirebaseAuth.instance.currentUser;
                if (user != null) {
                  Navigator.push(context, customPageRoute(CartPage()));
                } else {
                  {
                    {

                      showModalBottomSheet<void>(
                        context: context,
                        useSafeArea: true,
                        elevation: 4,
                        isScrollControlled: true,
                        enableDrag: true,
                        showDragHandle:true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(40.0), // Adjust the radius as needed
                          ),
                        ),
                        builder: (BuildContext context) {
                          return Container(
                            color: Colors.greenAccent,
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  SignInBottomSheet()
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                  }
                }
              },
              child: Row(
                children: [
                  TextButton(onPressed: (){
                    {
                      user=FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        Navigator.push(context, customPageRoute(CartPage()));
                      } else {
                        {
                          {

                            showModalBottomSheet<void>(
                              context: context,
                              useSafeArea: true,
                              elevation: 4,
                              isScrollControlled: true,
                              enableDrag: true,
                              showDragHandle:true,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(40.0), // Adjust the radius as needed
                                ),
                              ),
                              builder: (BuildContext context) {
                                return Container(
                                  color: Colors.greenAccent,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        SignInBottomSheet()
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        }
                      }
                    }
                  }, child: Text(user!=null?'':'Login',style: TextStyle(color:Colors.yellow),)),
                  Container(
                    margin: EdgeInsets.only(top: 8, right: 12),
                    child: Column(
                      children: [
                        Icon(Icons.shopping_cart_checkout,color: Colors.yellow,),
                        Text('Cart',
                          style: TextStyle(
                              color: Colors.yellow,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [

              SearchWidget(),
              Align(alignment: Alignment.topLeft, child: Wellcomemsg()),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ImageSliderFromFirebase(),
              ),
              MenuText('Explore Kosi Services'),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: ServiceFolder(),
              ),

              MenuText('Top Kosi Services'),
              SizedBox(
                height: 8,
              ),
              Container(
                  height: 130,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: TopServices(),
                  )),
              MenuText('Top Kosi Offers'),
              SizedBox(
                height: 8,
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: PosterSliderWidget(),
              ),
              MenuText('Recommended for you'),
              SizedBox(
                height: 8,
              ),
              Container(
                height: 350,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: RecomendationSliderWidget(),
                ),
              ),
              SizedBox(height: 20,),
              Container(
                height: serviceCategories.length*290,
                child: serviceListsFromCategories(), // Use the new method here
              ),
              Footer()
            ],
          ),
        ),
        floatingActionButton: SpeedDial(
          backgroundColor: AppColors.blueColor,
          activeIcon: Icons.support_agent ,
          icon: Icons.call,
          iconTheme: IconThemeData(color: Colors.white),
          label: Text('Call US',style: TextStyle(color: Colors.white),),
          children: [
            SpeedDialChild(
              onTap: () {
                _makePhoneCall();
              },
              child: Icon(FontAwesomeIcons.phone),
              label: 'Call', // Help text for making a phone call
            ),
            SpeedDialChild(
              onTap: () {
                launchEnquiryWhatsApp();
              },
              child: Icon(FontAwesomeIcons.whatsapp),
              label: 'WhatsApp', // Help text for launching WhatsApp
            ),
            // Add more SpeedDialChild widgets as needed
          ],
        ),





        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: AppColors.primaryColor,
          selectedLabelStyle: TextStyle(color: Colors.black),
          unselectedLabelStyle: TextStyle(color: Colors.white),
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.white,
          currentIndex: 0,
          onTap: (index) {
            user=FirebaseAuth.instance.currentUser;
            if (index == 1) {

              if (user!= null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyBookingPage()),
                );
              }else{
                {

                  showModalBottomSheet<void>(
                    context: context,
                    useSafeArea: true,
                    elevation: 4,
                    isScrollControlled: true,
                    enableDrag: true,
                    showDragHandle:true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(40.0), // Adjust the radius as needed
                      ),
                    ),
                    builder: (BuildContext context) {
                      return Container(
                        color: Colors.greenAccent,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SignInBottomSheet()
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              }


            }
            if (index == 2) {
              User? user = _auth.currentUser;
              if (user!= null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserProfile()),
                );
              }else{

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('you are not login')));
                showModalBottomSheet<void>(
                  context: context,
                  useSafeArea: true,
                  elevation: 4,
                  isScrollControlled: true,
                  enableDrag: true,
                  showDragHandle:true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(40.0), // Adjust the radius as needed
                    ),
                  ),
                  builder: (BuildContext context) {
                    return Container(
                      color: Colors.greenAccent,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SignInBottomSheet()
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            }
            // Add other navigation logic here for other items
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.cabin,color: Colors.black,),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_online,color: Colors.black),
              label: 'Booking',

            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.person,color: Colors.black,),
              label: 'Profile',
            ),
          ],
        ),
      ),
      desktop: Scaffold(
        drawer: DrawerWidget(),
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Kosi service',style: TextStyle(color: Colors.white),),
              Text(currentcity,style: TextStyle(color: Colors.white,fontSize: 14),),
            ],
          ),
          elevation: 0.0,
          backgroundColor: AppColors.primaryColor,
          actions: [
            InkWell(
              onTap: () {
                user=FirebaseAuth.instance.currentUser;
                if (user != null) {
                  Navigator.push(context, customPageRoute(CartPage()));
                } else {
                  {
                    {

                      showModalBottomSheet<void>(
                        context: context,
                        useSafeArea: true,
                        elevation: 4,
                        isScrollControlled: true,
                        enableDrag: true,
                        showDragHandle:true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(40.0), // Adjust the radius as needed
                          ),
                        ),
                        builder: (BuildContext context) {
                          return Container(
                            color: Colors.greenAccent,
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  SignInBottomSheet()
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                  }
                }
              },
              child: Container(
                margin: EdgeInsets.only(top: 8, right: 12),
                child: Column(
                  children: [
                    Icon(Icons.shopping_cart_checkout),
                    Text(
                      'Cart',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(left: 150,right:150),
            child: Column(
              children: [
                Align(alignment: Alignment.topLeft, child: Wellcomemsg()),
                SearchWidget(),
                MenuText('Explore Kosi Services'),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: ServiceFolder(),
                ),
               Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ImageSliderFromFirebase(),
                ),
                MenuText('Top Kosi Services'),
                SizedBox(
                  height: 8,
                ),
                Container(
                    height: 220,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: TopServices(),
                    )),
                MenuText('Top Kosi Offers'),
                SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: PosterSliderWidget(),
                ),
                MenuText('Recommended for you'),
                SizedBox(
                  height: 8,
                ),
             /*   Container(
                  height: 700,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: RecomendationSliderWidget(),
                  ),
                ),*/
                SizedBox(height: 20,),
                Container(
                  height: serviceCategories.length*450,
                  child: serviceListsFromCategories(), // Use the new method here
                ),
                Footer()
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _makePhoneCall,
          backgroundColor:AppColors.primaryColor,
          child: Text('Call',textAlign: TextAlign.center,style: TextStyle(color:Colors.white,fontSize: 15,fontWeight: FontWeight.bold),),
        ),


       /* bottomNavigationBar: BottomNavigationBar(
          backgroundColor: AppColors.primaryColor,
          selectedLabelStyle: TextStyle(color: Colors.black),
          unselectedLabelStyle: TextStyle(color: Colors.white),
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.white,
          currentIndex: 0,
          onTap: (index) {
            if (index == 1) {
              if (user!= null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyBookingPage()),
                );
              }else{
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignInScreen()),
                );
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('you are not login')));
              }

            }
            if (index == 2) {
              User? user = _auth.currentUser;
              if (user!= null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserProfile()),
                );
              }else{
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('you are not login')));
              }
            }
            // Add other navigation logic here for other items
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.cabin,color: Colors.black,),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_online,color: Colors.black),
              label: 'Booking',

            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.person,color: Colors.black,),
              label: 'Profile',
            ),
          ],
        ),*/
      ),
    );
  }
  Widget Wellcomemsg(){
    return Padding(
      padding: const EdgeInsets.only(top: 12,left: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Home,',
            style: TextStyle(wordSpacing:2,fontFamily: 'AbrilFatface',fontWeight: FontWeight.w600,fontSize: 13,letterSpacing: 1,color: Colors.green),),
          SizedBox(height: 4,),
          Text('Our Experties- INDPE KOSI SERVICE PVT.LTD',
            style: TextStyle(wordSpacing:2,fontWeight: FontWeight.w600,fontSize: 13,letterSpacing: 1,color: Colors.green),),
        ],
      ),
    );
  }
  Widget MenuText(String text){
    return Padding(
      padding: const EdgeInsets.only(left: 15,top: 20),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          '$text',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
  Widget DrawerWidget(){
    return Drawer(
      backgroundColor: Colors.grey[200],
      width: 250,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 170,
            child: Padding(
              padding: const EdgeInsets.only(top: 50,bottom: 20),
              child: Image.asset("assets/images/logofirst.png"),
            ),
          ),
          Text('KosiService',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
          SizedBox(height: 10,),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(currentcontext!);
              Navigator.push(
                currentcontext!,
                MaterialPageRoute(builder: (context) =>KosiHomePage()),
              );
            },
            icon: Align(
              alignment: Alignment.centerLeft,
              child: Icon(Icons.home , size: 20,// Adjust the height as needed
              ),
            ),
            label: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Home',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blueColor,
                ),
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(currentcontext!);
              Navigator.push(
                currentcontext!,
                MaterialPageRoute(builder: (context) => MyBookingPage()),
              );
            },
            icon: Align(
              alignment: Alignment.centerLeft,
              child: Icon(Icons.reorder , size: 24,// Adjust the height as needed
              ),
            ),
            label: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'My Booking',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blueColor,
                ),
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(currentcontext!);
              _shareContent();
            },
            icon: Align(
              alignment: Alignment.centerLeft,
              child: Icon(Icons.share , size: 20,// Adjust the height as needed
              ),
            ),
            label: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Share',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blueColor,
                ),
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(currentcontext!);
              _makePhoneCall();
            },
            icon: Align(
              alignment: Alignment.centerLeft,
              child: Icon(Icons.phone , size: 20,// Adjust the height as needed
              ),
            ),
            label: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Call or Support',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blueColor,
                ),
              ),
            ),
          ),

          TextButton.icon(
            onPressed: () {
              Navigator.pop(currentcontext!);
              Navigator.push(
                context as BuildContext, MaterialPageRoute(builder: (context) => PrivacyPolicy()),
              );
            },
            icon: Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                'assets/images/logofirst.png', // Replace with your image asset
                width: 20, // Adjust the width as needed
                height: 20, // Adjust the height as needed
              ),
            ),
            label: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Privacy Policy',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blueColor,
                ),
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(currentcontext!);
              Navigator.push(
                context as BuildContext, MaterialPageRoute(builder: (context) => CancellationPolicyPage()),
              );
            },
            icon: Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                'assets/images/logofirst.png', // Replace with your image asset
                width: 20, // Adjust the width as needed
                height: 20, // Adjust the height as needed
              ),
            ),
            label: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Refund Policy',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blueColor,
                ),
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(currentcontext!);
              Navigator.push(
                context as BuildContext, MaterialPageRoute(builder: (context) => TermsAndConditions()),
              );
            },
            icon: Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                'assets/images/logofirst.png', // Replace with your image asset
                width: 20, // Adjust the width as needed
                height: 20, // Adjust the height as needed
              ),
            ),
            label: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Terms and Condition',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blueColor,
                ),
              ),
            ),
          ),

          TextButton.icon(
            onPressed: () {
              Navigator.pop(currentcontext!);
              Navigator.push(
                context as BuildContext, MaterialPageRoute(builder: (context) => JobPage()),
              );
            },
            icon: Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                'assets/images/logofirst.png', // Replace with your image asset
                width: 20, // Adjust the width as needed
                height: 20, // Adjust the height as needed
              ),
            ),
            label: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Join to work with Us',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blueColor,
                ),
              ),
            ),
          ),

          TextButton.icon(
            onPressed: () {
              Navigator.pop(currentcontext!);
              Navigator.push(
                context as BuildContext, MaterialPageRoute(builder: (context) => WebViewPage( url: 'kosiservice.com')),
              );
            },
            icon: Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                'assets/images/logofirst.png', // Replace with your image asset
                width: 20, // Adjust the width as needed
                height: 20, // Adjust the height as needed
              ),
            ),
            label: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'About Org.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blueColor,
                ),
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(currentcontext!);
              Navigator.push(
                context as BuildContext, MaterialPageRoute(builder: (context) => WebViewPage( url: 'https://reemzetdeveloper.in/')),
              );

            },
            icon: Align(
              alignment: Alignment.centerLeft,
              child: Icon(Icons.developer_mode , size: 20,// Adjust the height as needed
              ),
            ),
            label: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Developer_@_Reemzet developer',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blueColor,
                ),
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(currentcontext!);
              _signOut();
            },
            icon: Align(
              alignment: Alignment.centerLeft,
              child: Icon(Icons.logout , size: 20,// Adjust the height as needed
              ),
            ),
            label: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Logout',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blueColor,
                ),
              ),
            ),
          )

        ],
      ),
    );
  }
  Widget Footer() {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      color: screenWidth<600?Colors.greenAccent:Colors.white, // Change to your desired background color
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 100,
            child: Image.asset("assets/images/logofirst.png"),
          ),
          Text(
            'Follow Us:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              kIsWeb?SocialButton(
                iconUrl: 'https://firebasestorage.googleapis.com/v0/b/firstandfast-781dd.appspot.com/o/Social%20png%2Fgame.png?alt=media&token=9be8eae4-8e99-4b02-8be2-d882a8783af7',
                label: 'Kosi App',
                onTap: () {
                  openplaystore();
                },
              ):
              SocialButton(
                iconUrl: 'https://firebasestorage.googleapis.com/v0/b/firstandfast-781dd.appspot.com/o/Social%20png%2Fweb-link.png?alt=media&token=2be25c46-6d62-4671-8460-062204932f2c',
                label: 'Kosi website',
                onTap: () {
                 openWebsite();
                },
              ),
              SocialButton(
                iconUrl: 'https://firebasestorage.googleapis.com/v0/b/firstandfast-781dd.appspot.com/o/Social%20png%2Ffacebook.png?alt=media&token=9bc512d2-c988-4f09-a911-7c35b011306e',
                label: 'Facebook',
                onTap: () {
                  openfb();
                },
              ),
              SocialButton(
                iconUrl: 'https://firebasestorage.googleapis.com/v0/b/firstandfast-781dd.appspot.com/o/Social%20png%2Finstagram.png?alt=media&token=cafdc199-0baa-404b-8f94-6055bbaafd3e',
                label: 'Instagram',
                onTap: () {
                  openinsta();
                },
              ),
              SocialButton(
                iconUrl: 'https://firebasestorage.googleapis.com/v0/b/firstandfast-781dd.appspot.com/o/Social%20png%2Fyoutube%20(1).png?alt=media&token=edd97296-b933-4b23-a733-e8561be7e4d8',
                label: 'YouTube',
                onTap: () {
                  openyoutube();
                },
              ),
            ],
          ),SizedBox(height: 8,),
          Text('IKSPL (INDPE KOSI SERVICE PRIVATE LIMITED)',style: TextStyle(fontWeight: FontWeight.bold),),
          SizedBox(height: 8,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on_outlined,size: 20,),
              Align(alignment: Alignment.center,child: Text('Adarsh, Colony,Rd #01,khemnichak, Ram Krishna Nagar,\n Patna, Sampatchak, Bihar, India, 800027',style: TextStyle(fontSize: 14,))),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Service Location',style:TextStyle(color: Colors.black,fontWeight: FontWeight.bold,),),
              Text('Patna')
            ],
          )
        ],
      ),
    );
  }
}







class SocialButton extends StatelessWidget {
  final String iconUrl; // Change IconData to String for URL
  final String label;
  final Function onTap;

  SocialButton({
    required this.iconUrl, // Change IconData to String for URL
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (onTap != null) {
          onTap();
        }
      },
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Image.network( // Using Image.network to fetch icon from URL
              iconUrl,
              width: 36,
              height: 36,
               // You can add color if needed
            ),
            SizedBox(height: 5),
            Text(label),
          ],
        ),
      ),
    );
  }
}


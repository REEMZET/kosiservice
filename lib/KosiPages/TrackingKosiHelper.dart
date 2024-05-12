import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:kosiservice/Utils/AppColors.dart';
import 'dart:convert';

import '../Models/KosiHelperModels.dart';

class TrackingKosiHelper extends StatefulWidget {
  final String helperid;
  final LatLng destination;

  TrackingKosiHelper({required this.helperid, required this.destination});

  @override
  State<TrackingKosiHelper> createState() => _TrackingKosiHelperState();
}

Helper? helpermodel;

class _TrackingKosiHelperState extends State<TrackingKosiHelper> {
  LatLng? destination;
  LatLng? helperLocation;
  GoogleMapController? mapController;
  BitmapDescriptor markerIcon =
  BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);

  List<LatLng> polylineCoordinates = [];
  Set<Polyline> polylines = {};

  void addCustomMarker() {
    ImageConfiguration configuration = ImageConfiguration(size: Size(4, 4));
    BitmapDescriptor.fromAssetImage(configuration, 'assets/images/kosihero.png')
        .then((value) {
      setState(() {
        markerIcon = value;
      });
    });
  }


  void getKosiHelper(String helperid) {
    DatabaseReference userRef = FirebaseDatabase.instance
        .reference()
        .child('KosiService/KosiHelper/$helperid');
    userRef.onValue.listen((event) {
      final udata = event.snapshot.value;
      if (udata != null) {
        Map<dynamic, dynamic> value = udata as Map<dynamic, dynamic>;
        setState(() {
          helpermodel = Helper(
            accountType: value['accountype'],
            helperAge: value['helperage'],
            helperDeviceId: value['helperdeviceid'],
            helperId: value['helperid'],
            helperLatitude: value['helperlatitiude'],
            helperLongitude: value['helperlongitude'],
            helperName: value['helpername'],
            helperPhone: value['helperphone'],
            helperPic: value['helperpic'],
            helperUid: value['helperuid'],
            helperWorkCount: value['helperworkcount'],
            helperJoinDate: value['helperjoindate'],
            helperbalance: value['helperbalance'],
          );
          helperLocation = LatLng(
            double.parse(helpermodel!.helperLatitude),
            double.parse(helpermodel!.helperLongitude),
          );
          mapController?.animateCamera(CameraUpdate.newLatLng(helperLocation!));

          // Draw path
          drawPath();
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    destination=widget.destination;
    getKosiHelper(widget.helperid);

    addCustomMarker();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Track Helper',style: TextStyle(color: Colors.white),),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Stack(
        children: [
          if (helpermodel != null)
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  double.parse(helpermodel!.helperLatitude),
                  double.parse(helpermodel!.helperLongitude),
                ),
                zoom: 15,
              ),
              mapType: MapType.normal,
              onMapCreated: (controller) {
                mapController = controller;
              },
              markers: {
                Marker(
                  markerId: const MarkerId('Your Location'),
                  position: widget.destination,
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                  infoWindow: InfoWindow(
                    title: 'Destination',
                  ),
                ),
                Marker(
                  markerId: const MarkerId('Kosi Partner'),
                  position: helperLocation ?? LatLng(0, 0),
                  icon:  BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                  infoWindow: InfoWindow(
                    title: 'Kosi Partner',
                  ),
                ),
              },
              polylines: polylines,
            ),
        ],
      ),
    );
  }

  void drawPath() async {
    String apiUrl =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${helperLocation!.latitude},${helperLocation!.longitude}&destination=${widget.destination.latitude},${widget.destination.longitude}&key=AIzaSyAAQzj4K4H8RARgq-YNHh6G-YaKFdq3WgY';

    var response = await http.get(Uri.parse(apiUrl));
    var result = json.decode(response.body);

    List<LatLng> points = [];

    if (result['status'] == 'OK') {
      List<dynamic> routes = result['routes'];
      routes.forEach((route) {
        List<dynamic> legs = route['legs'];
        legs.forEach((leg) {
          List<dynamic> steps = leg['steps'];
          steps.forEach((step) {
            dynamic polyline = step['polyline'];
            String pointsEncoded = polyline['points'];
            points.addAll(_convertToLatLng(_decodePoly(pointsEncoded)));
          });
        });
      });

      setState(() {
        polylines.add(Polyline(
          polylineId: PolylineId('poly'),
          color: Colors.green,
          points: points,
        ));
      });
    }
  }

  List<LatLng> _convertToLatLng(List points) {
    List<LatLng> result = <LatLng>[];
    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(LatLng(points[i - 1], points[i]));
      }
    }
    return result;
  }

  List _decodePoly(String poly) {

    List<int> list = poly.codeUnits;
    List<double> lList = List.empty(growable: true);

    int index = 0;
    int len = poly.length;
    int c = 0;
    // repeating until all attributes are decoded
    do {
      var shift = 0;
      int result = 0;

      // for decoding value of one attribute
      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      /* if value is negative then bitwise not the value */
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

    /*adding to previous value as done in encoding */
    for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];

    print(lList.toString());

    return lList;
  }
}

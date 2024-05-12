import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final LatLng _sourceLocation = const LatLng(24.775381327294184, 85.0215659648488);
  final LatLng _destinationLocation = const LatLng(24.78087002195518, 84.99538426697357);
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _markers.add(
      Marker(
        markerId: MarkerId('source'),
        position: _sourceLocation,
        infoWindow: InfoWindow(title: 'Source'),
      ),
    );
    _markers.add(
      Marker(
        markerId: MarkerId('destination'),
        position: _destinationLocation,
        infoWindow: InfoWindow(title: 'Destination'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map Navigation'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _sourceLocation,
          zoom: 12.0,
        ),
        onMapCreated: _onMapCreated,
        markers: _markers,
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => _navigate(),
            child: Icon(Icons.navigation),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _goToUserLocation,
            child: Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _navigate() {
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      LatLng currentPosition = LatLng(position.latitude, position.longitude);
      _getPolylineCoordinates(currentPosition, _destinationLocation)
          .then((List<LatLng> polylineCoordinates) {
        _drawPolyline(polylineCoordinates);
      }).catchError((error) => print(error));
    }).catchError((error) => print(error));
  }

  Future<List<LatLng>> _getPolylineCoordinates(
      LatLng start, LatLng destination) async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      'Your_API_Key', // Replace with your Google Maps API Key
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    return polylineCoordinates;
  }

  void _drawPolyline(List<LatLng> polylineCoordinates) {
    setState(() {
      Polyline polyline = Polyline(
        polylineId: PolylineId('poly'),
        color: Colors.blue,
        points: polylineCoordinates,
        width: 5,
      );
      _markers.removeWhere((marker) => marker.markerId.value == 'poly');
     /* mapController.clearMarkers();
      mapController.addPolyline(polyline);*/
    });
  }

  void _goToUserLocation() {
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          20, // Adjust the zoom level as needed
        ),
      );
      setState(() {
        _markers.add(
          Marker(
            markerId: MarkerId("currentLocation"),
            position: LatLng(position.latitude, position.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            infoWindow: InfoWindow(title: "Your Location"),
          ),
        );
      });
    }).catchError((error) => print(error));
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kosiservice/Utils/AppColors.dart';

class LocationPickerResult {
  final LatLng? location;
  final String? address;

  LocationPickerResult({this.location, this.address});
}
TextEditingController hintaddressController = TextEditingController();
class LocationPickerDialog {
  static Future<LocationPickerResult?> show(BuildContext context, String name,
      String phoneNumber) async {
    Completer<LocationPickerResult?> completer = Completer();

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: CircularProgressIndicator(),
          ), // Show a circular progress indicator
        );
      },
    );

    // Fetch current location and address
    PositionAndAddress? currentPositionAndAddress =
    await _getCurrentLocation(name, phoneNumber);

    LatLng? selectedLocation = currentPositionAndAddress?.position;
    String? currentAddress = currentPositionAndAddress?.address;

    // Dismiss loading indicator
    Navigator.of(context).pop();

    // Show location picker dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Choose & Confirm Location"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 350,
                      width: 300,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            selectedLocation?.latitude ?? 0,
                            selectedLocation?.longitude ?? 0,
                          ),
                          zoom: 18,
                        ),
                        myLocationEnabled: true,
                        onTap: (LatLng latLng) async {
                          setState(() {
                            selectedLocation = latLng;
                          });
                          currentAddress = await _getAddressFromLocation(
                              latLng.latitude, latLng.longitude, name, phoneNumber);
                          setState(() {});
                        },
                        markers: Set.from(
                          [
                            if (selectedLocation != null)
                              Marker(
                                markerId: MarkerId("selectedLocation"),
                                position: selectedLocation!,
                                icon: BitmapDescriptor.defaultMarker,
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (currentAddress != null)
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "$currentAddress",
                          style: TextStyle(

                            fontSize: 14,color: Colors.black
                          ),
                        ),
                      ),
                    TextField(
                      controller: hintaddressController,
                      decoration: InputDecoration(
                        labelText: 'Enter any Near Address (Optional)',
                        labelStyle: TextStyle(fontSize: 12,color: Colors.blue,fontWeight: FontWeight.bold),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green),
                        ),
                        prefixIcon: Icon(
                          Icons.location_on,color: Colors.blue,
                        ),
                      ),
                    ),

                  ],
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    completer.complete(LocationPickerResult(
                        location: selectedLocation,
                        address: '$currentAddress ${hintaddressController.text}'));
                  },
                  child: Text("Confirm & Book",style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Set the background color to green
                  ),
                ),

                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    completer.complete(null);
                  },
                  child: Text("Cancel"),
                ),
              ],
            );
          },
        );
      },
    );

    return completer.future;
  }

  static Future<PositionAndAddress?> _getCurrentLocation(
      String name, String phoneNumber) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    Position currentPosition = await Geolocator.getCurrentPosition();
    String currentAddress = await _getAddressFromLocation(
        currentPosition.latitude, currentPosition.longitude, name, phoneNumber);

    return PositionAndAddress(
      position: LatLng(currentPosition.latitude, currentPosition.longitude),
      address: '$currentAddress',
      name: name,
      phoneNumber: phoneNumber,
    );
  }

  static Future<String> _getAddressFromLocation(double latitude,
      double longitude, String name, String phoneNumber) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      Placemark placemark = placemarks.first;
      String subLocality = placemark.subLocality ?? '';
      String locality = placemark.locality ?? '';
      String administrativeArea = placemark.administrativeArea ?? '';
      String country = placemark.country ?? '';
      String postalCode = placemark.postalCode ?? '';

      print(placemark);
      // Concatenate name and phone number with the address components
      return 'Add-${placemark.name} ${placemark.street} $subLocality, $locality, $administrativeArea, $country, $postalCode';
    } catch (e) {
      return "Address not found";
    }
  }
}

class PositionAndAddress {
  final LatLng position;
  final String address;
  final String name;
  final String phoneNumber;

  PositionAndAddress({
    required this.position,
    required this.address,
    required this.name,
    required this.phoneNumber,
  });
}

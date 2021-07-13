import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:lawer/users/people/home__people.dart';
import 'package:lawer/users/userselection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'lawers/home__lawer.dart';

import 'package:flutter/material.dart';
import 'package:platform/platform.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {

Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device
  var g=await Geolocator.getCurrentPosition();
  SharedPreferences preferences = await SharedPreferences.getInstance();
 preferences.setDouble('lat', g.latitude);
  preferences.setDouble('lng', g.longitude);
  getSharedData();
  return await Geolocator.getCurrentPosition();
}

  getSharedData() async {

    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.getBool('isLogInPeople');
    if (preferences.getBool('isLogInPeople') == true) {
      Get.off(HomePeople());
    } else if (preferences.getBool('isLogInLawer') == true) {
      Get.off(HomeLawer());
    } else {
      Get.off(UserSelection());
    }
  }

  @override
  void initState() {
    determinePosition();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backwardsCompatibility: false,
          systemOverlayStyle:
              SystemUiOverlayStyle(statusBarColor: Colors.transparent),
        ),
      ),
    );
  }
}

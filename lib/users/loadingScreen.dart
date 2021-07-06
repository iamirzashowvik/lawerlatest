import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lawer/users/people/home__people.dart';
import 'package:lawer/users/userselection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'lawers/home__lawer.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
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
    getSharedData();
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

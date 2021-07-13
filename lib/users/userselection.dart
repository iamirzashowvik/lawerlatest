import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lawer/call.dart';
import 'package:lawer/users/lawers/signin__lawer.dart';
import 'package:lawer/users/lawers/signup__lawer.dart';
import 'package:lawer/users/people/SignInPeople.dart';

import 'package:lawer/users/people/signup__people.dart';

class UserSelection extends StatefulWidget {
  @override
  _UserSelectionState createState() => _UserSelectionState();
}

class _UserSelectionState extends State<UserSelection> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: GestureDetector(
        onTap: () {
          final callx = CallX();
          // double totalDistance = callx.calculateDistance(23.730727, 90.460339 ,23.727235, 90.460562);
          //
          // print(totalDistance);//in km
          callx.getLatlangfromSharedpref();

        },
        child: CircleAvatar(
          backgroundColor: Colors.red,
          child: Icon(Icons.call),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/background-with-advocacy-elements_23-2147820785.jpg',
            fit: BoxFit.fitHeight,
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () {
                      Get.to(SignInPeople());
                    },
                    child: Text('Need a Lawyer')),
                ElevatedButton(
                    onPressed: () {
                      Get.to(SignInLawer());
                    },
                    child: Text('As a Lawyer')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

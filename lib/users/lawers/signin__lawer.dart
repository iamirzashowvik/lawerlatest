import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lawer/model/textformfield.dart';
import 'package:lawer/users/lawers/signup__lawer.dart';
import 'package:lawer/users/people/home__people.dart';
import 'package:lawer/users/people/signup__people.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../forgetpassword.dart';
import 'home__lawer.dart';

class SignInLawer extends StatefulWidget {
  @override
  _SignInLawerState createState() => _SignInLawerState();
}

class _SignInLawerState extends State<SignInLawer> {
  TextEditingController _userName = TextEditingController();
  TextEditingController _password = TextEditingController();
  final firestoreInstance = FirebaseFirestore.instance;
  List<dynamic> userData = [];

  getUserData() {
    var dataFF2;
    setState(() {
      userData = [];
    });
    firestoreInstance.collection("Lawer").get().then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        dataFF2 = result.data();
        setState(() {
          userData.add(dataFF2);
          print(dataFF2);
        });
      });
    });
  }

  @override
  void initState() {
    getUserData();
    super.initState();
    getUserData();
  }

  final _loginForm = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height - 70,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Image.asset(
                  'assets/justice-concept-illustration_114360-2134.jpg',
                  height: 200,
                  width: 200,
                ),
                Text(
                  'Sign In',
                  style: TextStyle(
                      fontSize: 30, fontFamily: 'Gilroy', color: Colors.red),
                ),
                Form(
                  key: _loginForm,
                  child: Column(
                    children: [
                      TFFxM(_userName, 'Email'),
                      TFFxM(_password, 'Password'),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () async {
                            SharedPreferences pref =
                                await SharedPreferences.getInstance();
                            if (_loginForm.currentState.validate()) {
                              for (int i = 0; i < userData.length; i++) {
                                if (userData[i]['email'] == _userName.text &&
                                    userData[i]['password'] == _password.text) {
                                  pref.setBool('isLogInLawer', true);
                                  pref.setString('email', _userName.text);
                                  pref.setString('name', userData[i]['name']);
                                  pref.setString('phn', userData[i]['phn']);
                                  pref.setString('PresentAddress',
                                      userData[i]['OfficeAddress']);
                                  pref.setString('nid', userData[i]['nid']);
                                  pref.setString('profilePHOTO',
                                      userData[i]['profile']['picture']);
                                  // Navigator.pushReplacement(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (_) => HomeLawer()));
                                  Get.offAll(HomeLawer());
                                } else {
                                  Get.snackbar('Wrong',
                                      'Email/Password combination is wrong');
                                }
                              }
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.red,
                            ),
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  'Sign In ',
                                  style: TextStyle(
                                      fontFamily: 'Gilroy',
                                      fontSize: 20,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                            Get.to(ForgetPassword('lawyer'));
                          },
                          child: Text(
                            'Forgot password',
                            style: TextStyle(
                                fontFamily: 'Gilroy',
                                fontSize: 13,
                                color: Colors.red),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                            Get.to(SignUpLawer());
                          },
                          child: Text(
                            'Sign UP',
                            style: TextStyle(
                                fontFamily: 'Gilroy',
                                fontSize: 13,
                                color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

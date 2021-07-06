import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lawer/model/textformfield.dart';
import 'package:lawer/users/lawers/signin__lawer.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi_info_plugin/wifi_info_plugin.dart';

class SignUpLawer extends StatefulWidget {
  const SignUpLawer({Key key}) : super(key: key);

  @override
  _SignUpLawerState createState() => _SignUpLawerState();
}

class _SignUpLawerState extends State<SignUpLawer> {
  final List<DropdownMenuItem> items = [];
  final List<DropdownMenuItem> itemsX = [
    DropdownMenuItem(
      child: Text(
        'NID',
        //   'Passport', 'Driving License Number'
      ),
      value: 'NID',
    ),
    DropdownMenuItem(
      child: Text(
        'Passport',
        //   'Passport', 'Driving License Number'
      ),
      value: 'Passport',
    ),
    DropdownMenuItem(
      child: Text('Driving License Number'
          //   'Passport', 'Driving License Number'
          ),
      value: 'Driving License Number',
    ),
  ];
  final _loginForm = GlobalKey<FormState>();
  final fireStoreInstance = FirebaseFirestore.instance;
  TextEditingController fullName = TextEditingController();
  TextEditingController presentaddress = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController needs = TextEditingController();
  TextEditingController nid = TextEditingController();
  TextEditingController brNumber = TextEditingController();
  TextEditingController education = TextEditingController();
  TextEditingController training = TextEditingController();
  TextEditingController certifications = TextEditingController();
  TextEditingController others = TextEditingController();
  getData() async {
    var b =
        await fireStoreInstance.collection("Lawertype").doc('Lawertype').get();
    String string = b.data()['Lawertype'];
    setState(() {
      for (int i = 0; i < string.split(",").length; i++) {
        items.add(DropdownMenuItem(
          child: Text(string.split(",")[i]),
          value: string.split(",")[i],
        ));
      }
    });
  }

  final GoogleSignIn googleSignIn = GoogleSignIn();
  Future<UserCredential> signInWithGoogleee() async {
    // Trigger the authentication flow
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> signOutGoogle() async {
    await googleSignIn.signOut();
  }

  @override
  void initState() {
    getData();
    super.initState();
    getMac();
  }

  bool selectedid = false;
  String macAddress;
  bool authUser = true;
  WifiInfoWrapper _wifiObject;
  Future<void> getMac() async {
    WifiInfoWrapper wifiObject;

    try {
      wifiObject = await WifiInfoPlugin.wifiDetails;

      setState(() {
        _wifiObject = wifiObject;
        macAddress = _wifiObject.macAddress;
      });
    } on PlatformException {}
    if (!mounted) return;
  }

  List<String> _locations = ['A', 'B', 'C', 'D'];
  String _selectedLocation = 'Please choose a type';
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Form(
            key: _loginForm,
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    'Hi there, Lets know a bit about you!',
                    style: TextStyle(
                        fontFamily: 'Gilroy', color: Colors.blue, fontSize: 30),
                  ),
                ),
                TFFxM(fullName, 'Full Name'),
                TFFxM(email, 'Email'),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 30,
                  ),
                  child: SearchableDropdown.single(
                    displayClearIcon: false,
                    items: items,
                    value: 'Lawyer Service Type',
                    hint: 'Lawyer Service Type',
                    searchHint: "Search / Select one",
                    onChanged: (value) {
                      setState(() {
                        needs.text = value;
                        print(needs.text.toString());
                      });
                    },
                    dialogBox: true,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return '*required';
                      }
                      return null;
                    },
                    isExpanded: true,
                  ),
                ),
                TFFxM(password, 'Password'),
                TFFxM(presentaddress, 'Office Address'),
                TFFxM(phone, 'Phone Number'),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 30,
                  ),
                  child: SearchableDropdown.single(
                    displayClearIcon: false,
                    items: itemsX,
                    value: 'NID/Passport/Driving License Number',
                    hint: 'NID/Passport/Driving License Number',
                    searchHint: "Search / Select one",
                    onChanged: (value) {
                      setState(() {
                        selectedid = true;
                        // needs.text = value;
                        //  print(needs.text.toString());
                        _selectedLocation = value;
                      });
                    },
                    dialogBox: true,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return '*required';
                      }
                      return null;
                    },
                    isExpanded: true,
                  ),
                ),

                // DropdownButton<String>(
                //   hint: Text('NID/Passport/Driving License Number'),
                //   items: <String>['NID', 'Passport', 'Driving License Number']
                //       .map((String value) {
                //     return DropdownMenuItem<String>(
                //       value: value,
                //       child: new Text(
                //         value,
                //         style: TextStyle(color: Colors.black),
                //       ),
                //     );
                //   }).toList(),
                //   onChanged: (value) {
                //     setState(() {
                //       _selectedLocation = value;
                //     });
                //   },
                // ),
                selectedid ? TFFxM(nid, _selectedLocation) : Container(),
                TFFxM(brNumber, 'Bar Registration Number'),
                TFFxM(education, 'Educational Qualification'),
                TFFxM(certifications, 'Certifications'),
                TFFxM(training, 'Training Experience'),
                TFFxM(others, 'Others Experience'),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: GestureDetector(
                    onTap: () async {
                      if (_loginForm.currentState.validate()) {
                        EasyLoading.show(status: 'loading...');

                        signInWithGoogleee().then((result) async {
                          if (result != null) {
                            print(
                                'uid ${result.user.uid} ${result.credential} ${result.additionalUserInfo.providerId}');

                            try {
                              fireStoreInstance
                                  .collection("Lawer")
                                  .doc(result.user.email)
                                  .set({
                                'profile': result.additionalUserInfo.profile,
                                'name': fullName.text, // John Doe
                                'phn': phone.text, // Stokes and Sons
                                'password': password.text,
                                'service': needs.text,
                                'nid': nid.text,
                                'OfficeAddress': presentaddress.text,
                                'email': result.user.email,
                                'barresnumber': brNumber.text,
                                'education': education.text,
                                'certifications': certifications.text,
                                'trainig': training.text,
                                'others': others.text,
                                'phoneid': macAddress,
                                'usertype': 'Lawer'
                              }, SetOptions(merge: true)).then((_) async {
                                SharedPreferences pref =
                                    await SharedPreferences.getInstance();
                                pref.setString(
                                    'profilePHOTO', result.user.photoURL);
                                pref.setString('email', result.user.email);
                                pref.setString('name', result.user.displayName);

                                EasyLoading.dismiss();
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => SignInLawer()));
                              });
                            } catch (e) {}
                          } else {
                            signOutGoogle();
                          }
                        });
                      } else {
                        //  print("invalid");
                      }
                    },
                    child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 3,
                              offset:
                                  Offset(0, 1), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Continue',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontFamily: 'Gilroy',
                            ),
                          ),
                        )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// Full Name111111111111111111111111111111111111111111111111111
// - Lawyer Service Type>11111111111111111111111111111111111111
// lawyers will be able to choose111111111111111111111111111111
// one of the service type from here111111111111111111111111111
// which will added by the admin from admin panel.1111111111111
// - Bar Registration Number11111111111111111111111111111111111
// - Education1111111111111111111111111111111111111111111111111
// - Training11111111111111111111111111111111111111111111111111
// - Certifications11111111111111111111111111111111111111111111
// - Other Experience111111111111111111111111111111111111111111
// - Phone Number1111111111111111111111111111111111111111111111
// - Email11111111111111111111111111111111111111111111111111111
// - NID/Passport/Driving License111111111111111111111111111111
// - Office Address11111111111111111111111111111111111111111111
// - "GET APPOINTMENT"

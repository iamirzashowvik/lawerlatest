import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lawer/model/textformfield.dart';
import 'package:lawer/users/people/SignInPeople.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi_info_plugin/wifi_info_plugin.dart';

class SignUpPeople extends StatefulWidget {
  const SignUpPeople({Key key}) : super(key: key);

  @override
  _SignUpPeopleState createState() => _SignUpPeopleState();
}

class _SignUpPeopleState extends State<SignUpPeople> {
  final _loginForm = GlobalKey<FormState>();
  String _selectedLocation = 'Please choose a type';
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

  TextEditingController fullName = TextEditingController();
  TextEditingController presentaddress = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  bool selectedid = false;
  TextEditingController phone = TextEditingController();
  TextEditingController needs = TextEditingController();
  TextEditingController nid = TextEditingController();
  final firestoreInstance = FirebaseFirestore.instance;
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
    // TODO: implement initState
    super.initState();
    getMac();
  }

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
                TFFxM(password, 'Password'),
                TFFxM(presentaddress, 'Present Address'),
                TFFxM(phone, 'Phone Number'),
                TFFxM(needs, 'What Solution I\'m looking for in 100 words?'),
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
                selectedid ? TFFxM(nid, _selectedLocation) : Container(),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: GestureDetector(
                    onTap: () async {
                      if (_loginForm.currentState.validate()) {
                        EasyLoading.show(status: 'loading...');

                        // firestoreInstance
                        //     .collection("client")
                        //     .doc(email.text)
                        //     .set({
                        //   'name': fullName.text, // John Doe
                        //   'phn': phone.text, // Stokes and Sons
                        //   'password': password.text,
                        //   'needs': needs.text,
                        //   'nid': nid.text,
                        //   'PresentAddress': presentaddress.text,
                        //   'email': email.text,
                        //   'usertype':'client'
                        // }, SetOptions(merge: true)).then((_) async {
                        //   print("success!");
                        // });

                        signInWithGoogleee().then((result) async {
                          if (result != null) {
                            print(
                                'uid ${result.user.uid} ${result.credential} ${result.additionalUserInfo.providerId}');

                            try {
                              firestoreInstance
                                  .collection("client")
                                  .doc(result.user.email)
                                  .set({
                                'profile': result.additionalUserInfo.profile,
                                'name': fullName.text, // John Doe
                                'phn': phone.text, // Stokes and Sons
                                'password': password.text,
                                'needs': needs.text,
                                'nid': nid.text,
                                'PresentAddress': presentaddress.text,
                                'email': result.user.email,
                                'phoneid': macAddress,
                                'usertype': 'client'
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
                                        builder: (_) => SignInPeople()));
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

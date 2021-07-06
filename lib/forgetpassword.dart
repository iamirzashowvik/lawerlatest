import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import 'package:lawer/users/lawers/signin__lawer.dart';
import 'package:lawer/users/people/SignInPeople.dart';

import 'model/textformfield.dart';

class ForgetPassword extends StatefulWidget {
  final String userX;
  ForgetPassword(this.userX);

  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  TextEditingController password = TextEditingController();

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

  String email;
  bool auth = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getinfo();
  }

  getinfo() {
    EasyLoading.show(status: 'loading...');
    signInWithGoogleee().then((result) async {
      if (result != null) {
        print(result.user.email);
        if (widget.userX == 'lawyer') {
          var res = await FirebaseFirestore.instance
              .collection('Lawer')
              .where('email', isEqualTo: result.user.email)
              .get();

          print(res.docs.isEmpty);
          if (res.docs.isEmpty) {
            // Get.dialog(Text('No user available'));
            Get.snackbar('Opss', 'No user available');
          } else {
            res.docs.forEach((res) async {
              setState(() {
                auth = true;
                email = res.data()['email'];
              });
            });
          }
        } else {
          var res = await FirebaseFirestore.instance
              .collection('client')
              .where('email', isEqualTo: result.user.email)
              .get();

          print(res.docs.isEmpty);
          if (res.docs.isEmpty) {
            Get.snackbar('Opss', 'No user available');
          } else {
            res.docs.forEach((res) async {
              setState(() {
                auth = true;
                email = res.data()['email'];
              });
            });
          }
        }
      } else {}
    });
    EasyLoading.dismiss();
  }

  final _loginForm = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return auth == true
        ? Scaffold(
            body: Center(
              child: Form(
                key: _loginForm,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TFFxM(password, 'Password'),
                    GestureDetector(
                      onTap: () async {
                        if (_loginForm.currentState.validate()) {
                          EasyLoading.show(status: 'loading...');
                          if (widget.userX == 'lawyer') {
                            FirebaseFirestore.instance
                                .collection("Lawer")
                                .doc(email)
                                .set({
                              'password': password.text,
                            }, SetOptions(merge: true)).then((_) async {
                              Get.offAll(SignInLawer());
                              EasyLoading.dismiss();
                            });
                          } else {
                            FirebaseFirestore.instance
                                .collection("client")
                                .doc(email)
                                .set({
                              'password': password.text,
                            }, SetOptions(merge: true)).then((_) async {
                              Get.offAll(SignInPeople());
                              EasyLoading.dismiss();
                            });
                          }
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            color: Colors.green,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(child: Text('Reset Password')),
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: getinfo,
                child: Text('Retry'),
              ),
            ),
          );
  }
}

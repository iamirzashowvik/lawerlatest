import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

class ProfileLawer extends StatefulWidget {
  const ProfileLawer({Key key}) : super(key: key);

  @override
  _ProfileLawerState createState() => _ProfileLawerState();
}

class _ProfileLawerState extends State<ProfileLawer> {
  FirebaseStorage storage = FirebaseStorage.instance;
  Future<void> _upload(String inputSource) async {
    final picker = ImagePicker();
    PickedFile pickedImage;
    try {
      pickedImage = await picker.getImage(
          source: inputSource == 'camera'
              ? ImageSource.camera
              : ImageSource.gallery,
          maxWidth: 1920);

      final String fileName = path.basename(pickedImage.path);
      File imageFile = File(pickedImage.path);

      try {
        // Uploading the selected image with some custom meta data
        await storage.ref(fileName).putFile(
            imageFile,
            SettableMetadata(customMetadata: {
              'uploaded_by': 'A bad guy',
              'description': 'Some description...'
            }));

        fireStoreInstance.collection("Lawer").doc(email).set({
          'profile': {'picture': fileName},
        }, SetOptions(merge: true)).then((_) async {
          print('success');
          SharedPreferences preferences = await SharedPreferences.getInstance();
          preferences.setString('profilePHOTO',
              'https://firebasestorage.googleapis.com/v0/b/lawer-8613e.appspot.com/o/$fileName?alt=media&token=260e6756-d21b-43a6-9391-2270ff39f3f2');
          getLawerData();
        });
        // Refresh the UI
        setState(() {});
      } on FirebaseException catch (error) {
        print(error);
      }
    } catch (err) {
      print(err);
    }
  }

  var res, item;
  getLawerData() async {
    res = await FirebaseFirestore.instance
        .collection('Lawer')
        .where('email', isEqualTo: email)
        .get();
// print(res.data()['phn'].toString());
    res.docs.forEach((res) async {
      setState(() {
        item = res.data();
      });
    });
    print(item['name']);
  }

  final _loginForm = GlobalKey<FormState>();
  @override
  void initState() {
    getSharedData();
    // TODO: implement initState
    super.initState();
  }

  TextEditingController post = TextEditingController();
  final fireStoreInstance = FirebaseFirestore.instance;
  String email, name, photoURL;
  getSharedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      email = preferences.getString('email');
      print(email);
      name = preferences.getString('name');
      photoURL = preferences.getString('profilePHOTO');
      getLawerData();
    });
  }

  bool activeUpload = false;
  @override
  Widget build(BuildContext context) {
    return res == null
        ? Scaffold(body: Center(child: CircularProgressIndicator()))
        : SafeArea(
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                leading: GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black,
                    ),
                  ),
                ),
                title: Text(
                  'Profile',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(item['profile']
                                              ['picture']
                                          .toString()
                                          .substring(0, 3) ==
                                      'sca'
                                  ? 'https://firebasestorage.googleapis.com/v0/b/lawer-8613e.appspot.com/o/${item['profile']['picture']}?alt=media&token=260e6756-d21b-43a6-9391-2270ff39f3f2'
                                  : item['profile']['picture']
                              //item['profile']['picture']

                              ),
                          radius: MediaQuery.of(context).size.width / 4,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: activeUpload
                              ? Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.cyan.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 3,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            _upload('camera');
                                            setState(() {
                                              activeUpload = false;
                                            });
                                          },
                                          child: Icon(Icons.camera),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            _upload('gallery');
                                            setState(() {
                                              activeUpload = false;
                                            });
                                          },
                                          child: Icon(Icons.library_add),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      activeUpload = true;
                                    });
                                  },
                                  child: Icon(
                                    Icons.upload,
//                                   .. color: Colors.blue,
                                  )),
                        )
                      ],
                    ),
                    Text(
                      item == null ? '' : item['name'],
                      style: TextStyle(fontSize: 30),
                    ),
                    Text(
                      item == null ? '' : item['email'],
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      item == null ? '' : item['service'],
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      item == null ? '' : item['education'],
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      item == null
                          ? ''
                          : 'Bar Registration Number : ${item['barresnumber']}',
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      item == null
                          ? ''
                          : 'Office Address : ${item['OfficeAddress']}',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}

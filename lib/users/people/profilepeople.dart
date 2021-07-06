import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({Key key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  FirebaseStorage storage = FirebaseStorage.instance;
  final fireStoreInstance = FirebaseFirestore.instance;
  @override
  void initState() {
    getSharedData();
    // TODO: implement initState
    super.initState();
  }

  var res, item;
  bool activeUpload = false;
  getLawerData() async {
    res = await FirebaseFirestore.instance
        .collection('client')
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

        fireStoreInstance.collection("client").doc(email).set({
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

  String email, name, photoURL, phn, add, nid;
  getSharedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      email = preferences.getString('email');
      name = preferences.getString('name');
      photoURL = preferences.getString('profilePHOTO');
      phn = preferences.getString('phn');
      add = preferences.getString('PresentAddress');
      nid = preferences.getString('nid');
      getLawerData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              res == null
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(photoURL),
                      radius: MediaQuery.of(context).size.width / 4,
                    )
                  : Stack(
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
                name,
                style: TextStyle(fontSize: 30),
              ),
              Text(
                email,
                style: TextStyle(fontSize: 20),
              ),
              Text(
                phn,
                style: TextStyle(fontSize: 20),
              ),
              Text(
                add,
                style: TextStyle(fontSize: 20),
              ),
              Text(
                nid,
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

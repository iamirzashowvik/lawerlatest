import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lawer/model/textformfield.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';

class Room_lawer extends StatefulWidget {
  final String lawerphoto;
  final String lawername;
  final String laweremail;
  Room_lawer(this.laweremail, this.lawername, this.lawerphoto);

  @override
  _Room_lawerState createState() => _Room_lawerState();
}

class _Room_lawerState extends State<Room_lawer> {
  FirebaseStorage storage = FirebaseStorage.instance;

// Select and image from the gallery or take a picture with the camera
// Then upload to Firebase Storage
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

        fireStoreInstance
            .collection("Conversations")
            .doc(threadId)
            .collection('messages')
            .doc()
            .set({
          'url': fileName,
          'message': 'image',
          'user': 'lawer',
          'timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true)).then((_) {
          print('success');
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

// Retriew the uploaded images
// This function is called when the app launches for the first time or when an image is uploaded or deleted
  Future<List<Map<String, dynamic>>> _loadImages() async {
    List<Map<String, dynamic>> files = [];

    final ListResult result = await storage.ref().list();
    final List<Reference> allFiles = result.items;

    await Future.forEach<Reference>(allFiles, (file) async {
      final String fileUrl = await file.getDownloadURL();
      final FullMetadata fileMeta = await file.getMetadata();
      files.add({
        "url": fileUrl,
        "path": file.fullPath,
        "uploaded_by": fileMeta.customMetadata['uploaded_by'],
        "description": fileMeta.customMetadata['description']
      });
    });

    return files;
  }

  final _loginForm = GlobalKey<FormState>();
  TextEditingController post = TextEditingController();
  final fireStoreInstance = FirebaseFirestore.instance;
  String email, name, photoURL, threadId;
  getSharedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      email = preferences.getString('email');
      name = preferences.getString('name');
      photoURL = preferences.getString('profilePHOTO');
      threadId = email.toString().split('@')[0] +
          widget.laweremail.toString().split('@')[0];
      print(threadId);
    });
  }

  @override
  void initState() {
    getSharedData();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            photoURL == null
                ? CircularProgressIndicator()
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(//
                          widget.lawerphoto.toString().substring(0, 3) == 'sca'
                              ? 'https://firebasestorage.googleapis.com/v0/b/lawer-8613e.appspot.com/o/${widget.lawerphoto}?alt=media&token=260e6756-d21b-43a6-9391-2270ff39f3f2'
                              : widget.lawerphoto),
                      // radius: 20,
                    ),
                  ),
            Text(
              widget.lawername,
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height - 150,
        child: StreamBuilder<QuerySnapshot>(
          stream: fireStoreInstance
              .collection('Conversations')
              .doc(threadId)
              .collection('messages')
              .orderBy('timestamp')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.lightBlueAccent,
                ),
              );
            }

            return ListView.builder(
              //reverse: true,
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              itemCount: snapshot.data.docs.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment:
                          snapshot.data.docs[index]['user'] == 'client'
                              ? CrossAxisAlignment.start
                              : CrossAxisAlignment.end,
                      children: [
                        //image==null?Container():  Image.network('gs://lawer-8613e.appspot.com/scaled_image_picker3235912250554629774.jpg'),

                        snapshot.data.docs[index]['url'] == 'url nai'
                            ? Container()
                            : Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: snapshot.data.docs[index]['user'] ==
                                          'client'
                                      ? Color(0xff9CC2F4)
                                      : Color(0xfffeecbb),
                                ),
                                height: 205,
                                width: 205,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.network(
                                    'https://firebasestorage.googleapis.com/v0/b/lawer-8613e.appspot.com/o/${snapshot.data.docs[index]['url']}?alt=media&token=260e6756-d21b-43a6-9391-2270ff39f3f2',
                                    height: 200,
                                    width: 200,
                                  ),
                                )),
                        snapshot.data.docs[index]['message'] == 'image'
                            ? Container()
                            : Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: snapshot.data.docs[index]['user'] ==
                                          'client'
                                      ? Color(0xff9CC2F4)
                                      : Color(0xfffeecbb),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    snapshot.data.docs[index]['message'],
                                    style: TextStyle(
                                        fontSize: 25,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomSheet: Form(
          key: _loginForm,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            ElevatedButton(
              onPressed: () => _upload('camera'),
              child: Icon(Icons.camera),
            ),
            ElevatedButton(
              onPressed: () => _upload('gallery'),
              child: Icon(Icons.library_add),
            ),
            Container(width: 180, child: TFFxM(post, 'Aa')),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () async {
                    if (_loginForm.currentState.validate()) {
                      fireStoreInstance
                          .collection("Conversations")
                          .doc(threadId)
                          .set({
                        'message': post.text,
                        'timestamp': FieldValue.serverTimestamp(),
                      }, SetOptions(merge: true)).then((_) async {
                        print("success!");
                      });
                      fireStoreInstance
                          .collection("Conversations")
                          .doc(threadId)
                          .collection('messages')
                          .doc()
                          .set({
                        'message': post.text,
                        'url': 'url nai',
                        'user': 'lawer',
                        'timestamp': FieldValue.serverTimestamp(),
                      }, SetOptions(merge: true)).then((_) {
                        print('success');
                      });

                      setState(() {
                        post.text = '';
                      });

                      //Get.snackbar('Success', 'Request Sent');
                    } else {
                      //  print("invalid");
                    }
                  },
                  child: Icon(Icons.send)),
            )
          ])),
    );
  }
}

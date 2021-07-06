import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lawer/forum/forum.dart';
import 'package:lawer/model/textformfield.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

class PostDetails extends StatefulWidget {
  final String posteremail;
  final String name;
  final String photoUrl;
  final String post;
  final String id;

  PostDetails(this.posteremail, this.name, this.photoUrl, this.post, this.id);
  @override
  _PostDetailsState createState() => _PostDetailsState();
}

class _PostDetailsState extends State<PostDetails> {
  String email, name, photoURL;
  getSharedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      email = preferences.getString('email');
      name = preferences.getString('name');
      photoURL = preferences.getString('profilePHOTO');
    });
  }

  @override
  void initState() {
    getSharedData();
    // TODO: implement initState
    super.initState();
  }

  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  final fireStoreInstance = FirebaseFirestore.instance;
  TextEditingController post = TextEditingController();
  final _loginForm = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
            'Comments',
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(widget.photoUrl
                                    .toString()
                                    .substring(0, 3) ==
                                'sca'
                            ? 'https://firebasestorage.googleapis.com/v0/b/lawer-8613e.appspot.com/o/${widget.photoUrl}?alt=media&token=260e6756-d21b-43a6-9391-2270ff39f3f2'
                            : widget.photoUrl),
                        radius: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          widget.name,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ]),
                    email == widget.posteremail
                        ? ElevatedButton(
                            onPressed: () {
                              fireStoreInstance
                                  .collection("Forum")
                                  .doc(widget.id)
                                  .delete()
                                  .then((_) {
                                print("success!");
                                fireStoreInstance
                                    .collection("Forum")
                                    .doc(widget.id)
                                    .collection('comments')
                                    .doc()
                                    .delete()
                                    .then((_) {});
                                Get.back();
                                Get.snackbar('Success', 'Post Deleted');
                              });
                            },
                            child: Text('Delete'))
                        : Container()
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(widget.post),
                ),
                Divider(
                  thickness: 5,
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Comments'),
            ),
            Form(
                key: _loginForm,
                child: Row(children: [
                  Expanded(
                      flex: 1,
                      // width: MediaQuery.of(context).size.width - 150,
                      child: TFFxM(post, 'Type your comment?')),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        onPressed: () async {
                          if (_loginForm.currentState.validate()) {
                            String idx2 = getRandomString(10);
                            fireStoreInstance
                                .collection("Forum")
                                .doc(widget.id)
                                .collection("comments")
                                .doc(idx2)
                                .set({
                              'comment': post.text,
                              'name': name,
                              'email': email,
                              'count': idx2,
                              'photoUrl': photoURL,
                              'timestamp': FieldValue.serverTimestamp(),
                            }, SetOptions(merge: true)).then((_) {
                              print('success');
                              Get.snackbar('Success', 'Comment Updated');
                            });
                            setState(() {
                              post.text = '';
                            });
                          } else {
                            //  print("invalid");
                          }
                        },
                        child: Icon(Icons.send)),
                  ),
                ])),
            Expanded(
              flex: 1,
              child: StreamBuilder<QuerySnapshot>(
                stream: fireStoreInstance
                    .collection('Forum')
                    .doc(widget.id)
                    .collection('comments')
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
                  // final messages = snapshot.data.docs.reversed;
//  print(snapshot.data.docs[0]['comment']);
                  return ListView.builder(
                    reverse: true,
                    // padding:
                    //     EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(

                                        //   snapshot.data.docs[index]['photoUrl']
                                        snapshot.data.docs[index]['photoUrl']
                                                    .toString()
                                                    .substring(0, 3) ==
                                                'sca'
                                            ? 'https://firebasestorage.googleapis.com/v0/b/lawer-8613e.appspot.com/o/${snapshot.data.docs[index]['photoUrl']}?alt=media&token=260e6756-d21b-43a6-9391-2270ff39f3f2'
                                            : snapshot.data.docs[index]
                                                ['photoUrl']),
                                    radius: 25,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      constraints:
                                          BoxConstraints(maxWidth: 200),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.white54,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 2,
                                            blurRadius: 3,
                                            offset: Offset(0,
                                                1), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              snapshot.data.docs[index]['name'],
                                              style: TextStyle(
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(snapshot
                                                .data.docs[index]['comment']),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              email == snapshot.data.docs[index]['email']
                                  ? ElevatedButton(
                                      onPressed: () {
                                        fireStoreInstance
                                            .collection("Forum")
                                            .doc(widget.id)
                                            .collection('comments')
                                            .doc(snapshot.data.docs[index]
                                                ['count'])
                                            .delete()
                                            .then((_) {});

                                        Get.snackbar(
                                            'Success', 'Comment Deleted');
                                      },
                                      child: Icon(Icons.delete))
                                  : Container()
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ]),
        ),
      ),
    );
  }
}

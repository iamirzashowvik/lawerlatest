import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lawer/call.dart';
import 'package:lawer/users/lawers/conv_lawer/Room_lawe.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Conv_lawer extends StatefulWidget {
  const Conv_lawer({Key key}) : super(key: key);

  @override
  _Conv_lawerState createState() => _Conv_lawerState();
}

class _Conv_lawerState extends State<Conv_lawer> {
  String email, name, photoURL;
  getSharedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      email = preferences.getString('email');
      name = preferences.getString('name');
      photoURL = preferences.getString('profilePHOTO');
      print(photoURL);
    });
  }

  @override
  void initState() {
    getSharedData();
    // TODO: implement initState
    super.initState();
  }

  final fireStoreInstance = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(floatingActionButton: GestureDetector(
      onTap: () {
        final callx = CallX();
        callx.getLatlangfromSharedpref();
      },
      child: CircleAvatar(
        backgroundColor: Colors.red,
        child: Icon(Icons.call),
      ),
    ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: photoURL == null
            ? CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(photoURL
                              .toString()
                              .substring(0, 3) ==
                          'sca'
                      ? 'https://firebasestorage.googleapis.com/v0/b/lawer-8613e.appspot.com/o/$photoURL?alt=media&token=260e6756-d21b-43a6-9391-2270ff39f3f2'
                      : photoURL),
                  // radius: 20,
                ),
              ),
        title: Text(
          'Chats',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: fireStoreInstance
            .collection('Conversations')
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

          return ListView.builder(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            itemCount: snapshot.data.docs.length,
            itemBuilder: (BuildContext context, int index) {
              if (snapshot.data.docs[index]['receiver_lawer'] == email) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  // ignore: missing_return, missing_return
                  child: ListTile(
                    onTap: () {
                      print('hi');
                      Get.to(Room_lawer(
                          snapshot.data.docs[index]['sender_client'],
                          snapshot.data.docs[index]['sender_name'],
                          snapshot.data.docs[index]['sender_photo']));
                    },
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                  // snapshot.data.docs[index]['sender_photo']
                                  snapshot.data.docs[index]['sender_photo']
                                              .toString()
                                              .substring(0, 3) ==
                                          'sca'
                                      ? 'https://firebasestorage.googleapis.com/v0/b/lawer-8613e.appspot.com/o/${snapshot.data.docs[index]['sender_photo']}?alt=media&token=260e6756-d21b-43a6-9391-2270ff39f3f2'
                                      : snapshot.data.docs[index]
                                          ['sender_photo']),
                              radius: 30,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    snapshot.data.docs[index]['sender_name'],
                                    style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(snapshot.data.docs[index]['message']),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Divider(
                        //   thickness: 5,
                        // )
                      ],
                    ),
                  ),
                );
              } else {
                return Container();
              }
            },
          );
        },
      ),
    );
  }
}

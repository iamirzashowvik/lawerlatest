import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lawer/model/textformfield.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LawerDetails extends StatefulWidget {
  final String lawerEmail;
  LawerDetails(this.lawerEmail);

  @override
  _LawerDetailsState createState() => _LawerDetailsState();
}

class _LawerDetailsState extends State<LawerDetails> {
  var res, item;
  getLawerData() async {
    res = await FirebaseFirestore.instance
        .collection('Lawer')
        .where('email', isEqualTo: widget.lawerEmail)
        .get();
// print(res.data()['phn'].toString());
    res.docs.forEach((res) async {
      setState(() {
        item = res.data();
        getSharedData();
      });
    });
    print(item['name']);
  }

  final _loginForm = GlobalKey<FormState>();
  @override
  void initState() {
    getLawerData();

    // TODO: implement initState
    super.initState();
  }

  TextEditingController post = TextEditingController();
  final fireStoreInstance = FirebaseFirestore.instance;
  String email, name, photoURL, threadId;
  getSharedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      email = preferences.getString('email');
      name = preferences.getString('name');
      photoURL = preferences.getString('profilePHOTO');
      threadId = item['email'].toString().split('@')[0] +
          email.toString().split('@')[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    return res == null
        ? Scaffold(body: Center(child: CircularProgressIndicator()))
        : SafeArea(
            child: Scaffold(
              body: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height - 60,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(item['profile']['picture']
                                    .toString()
                                    .substring(0, 3) ==
                                'sca'
                            ? 'https://firebasestorage.googleapis.com/v0/b/lawer-8613e.appspot.com/o/${item['profile']['picture']}?alt=media&token=260e6756-d21b-43a6-9391-2270ff39f3f2'
                            : item['profile']['picture']),
                        radius: MediaQuery.of(context).size.width / 4,
                      ),
                      Text(
                        item == null ? '' : item['name'],
                        style: TextStyle(fontSize: 30),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(Icons.email),
                          Text(
                            item == null ? '' : item['email'],
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            'Lawyer Type',
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(
                            item == null ? '' : item['service'],
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            'Education',
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(
                            item == null ? '' : item['education'],
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
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
                      Form(
                          key: _loginForm,
                          child: Column(children: [
                            TFFxM(post, 'What\'s On Your Mind?'),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                        onPressed: () async {
                                          String x = item['email']
                                                  .toString()
                                                  .split('@')[0] +
                                              email.toString().split('@')[0];
                                          if (_loginForm.currentState
                                              .validate()) {
                                            fireStoreInstance
                                                .collection("Conversations")
                                                .doc(x)
                                                .set({
                                              'sender_client':
                                                  email, // John Doe
                                              'message': post.text,
                                              'threadId': x,
                                              'receiver_lawer': item['email'],
                                              'receiver_photo': item['profile']
                                                  ['picture'],
                                              'receiver_name': item['name'],
                                              'sender_name': name,
                                              'sender_photo': photoURL,
                                              'timestamp':
                                                  FieldValue.serverTimestamp(),
                                            }, SetOptions(merge: true)).then(
                                                    (_) async {
                                              fireStoreInstance
                                                  .collection("Conversations")
                                                  .doc(x)
                                                  .collection('messages')
                                                  .doc()
                                                  .set({
                                                'message': post.text,
                                                'url': 'url nai',
                                                'user': 'client',
                                                'timestamp': FieldValue
                                                    .serverTimestamp(),
                                              }, SetOptions(merge: true)).then(
                                                      (_) {
                                                print('success22');
                                              });
                                              setState(() {
                                                post.text = '';
                                              });
                                              print("success!");
                                            });

                                            Get.snackbar(
                                                'Success', 'Request Sent');
                                          } else {
                                            //  print("invalid");
                                          }
                                        },
                                        child:
                                            Text('Request for Appointment ')),
                                  ],
                                ),
                              ),
                            )
                          ])),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lawer/laws/lawjson.dart';

class Lawlists extends StatefulWidget {
  @override
  _LawlistsState createState() => _LawlistsState();
}

class _LawlistsState extends State<Lawlists> {
  final firestoreInstance = FirebaseFirestore.instance;
  var items;
  getUserData() async {
    var b =
        await FirebaseFirestore.instance.collection("Laws").doc('laws').get();
    setState(() {
      var g = b.data()['json'];
      print(g);
      final lawjson = lawjsonFromJson(g.toString());
      items = lawjson; // lawjson.laws[0].title;
      print(items);
    });
  }

  List<dynamic> userData = [];

  @override
  void initState() {
    getUserData();

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: missing_return
    return Scaffold(
      body: items == null
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemBuilder: (BuildContext context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white54,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 3,
                          offset: Offset(0, 1), // changes position of shadow
                        ),
                      ],
                    ),
                    child: ListTile(
                      onTap: () {
                        Get.defaultDialog(
                            //  cancel: Text('OK'),
                            title: items.laws[index].title,
                            content: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(3.0),
                                  child: Text('History'),
                                ),
                                Container(
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
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                          child:
                                              Text(items.laws[index].history)),
                                    )),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    items.laws[index].shortdes,
                                  ),
                                )
                              ],
                            ));
                      },
                      title: Text(items.laws[index].title),
                    ),
                  ),
                );
              },
              itemCount: items.laws.length),
    );
  }
}

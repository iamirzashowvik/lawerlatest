import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:lawer/call.dart';
import 'package:lawer/forum/forum.dart';
import 'package:lawer/laws/lawjson.dart';
import 'package:lawer/laws/lawlists.dart';
import 'package:lawer/users/lawers/conv_lawer/conv_lawer.dart';
import 'package:lawer/users/lawers/profilel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../userselection.dart';

class HomeLawer extends StatefulWidget {
  @override
  _HomeLawerState createState() => _HomeLawerState();
}

class _HomeLawerState extends State<HomeLawer> {
  String name = 'UserName';
  getSharedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      name = preferences.getString('name');
    });
  }

  @override
  void initState() {
    getSharedData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(floatingActionButton: GestureDetector(
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
          backgroundColor: Colors.red,
          bottom: TabBar(
            onTap: (index) {},
            tabs: [
              Tab(icon: Text('Forum')),
              Tab(icon: Text('Chats')),
              Tab(icon: Text('Laws')),
            ],
          ),
          actions: [],
          title: Text('BD Law'),
        ),
        drawer: Drawer(
          child: Column(
            children: [
              DrawerHeader(
                child: CircleAvatar(
                    radius: 100,
                    backgroundImage: AssetImage(
                        'assets/justice-concept-illustration_114360-2134.jpg')),
              ),
              ListTile(
                onTap: () {
                  Get.to(ProfileLawer());
                },
                title: Row(
                  children: [
                    Icon(FontAwesomeIcons.user),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('   Profile'),
                    )
                  ],
                ),
              ),
              ListTile(
                onTap: () async {
                  SharedPreferences preference =
                      await SharedPreferences.getInstance();
                  preference.setBool('isLogInPeople', false);
                  preference.setBool('isLogInLawer', false);
                  Get.offAll(UserSelection());
                },
                title: Row(
                  children: [
                    Icon(FontAwesomeIcons.signOutAlt),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('   Logout'),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        body: TabBarView(
          children: [Forum(), Conv_lawer(), Lawlists()],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_app/Screens/SignUp.dart';

class HomeScreenBuilder extends StatelessWidget {
  late Widget body;
  late ListView? listView;

  HomeScreenBuilder( {Key? key, required this.body, this.listView } ) : super( key: key );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Container(
        width: 180.0,
        child: Drawer(
          child: this.listView == null ? ListView(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [
                          Colors.blue,
                          Colors.blueAccent,
                          Colors.lightBlueAccent,
                        ]
                    )
                ),
                child: Icon(
                  Icons.account_circle,
                  color: Colors.white,
                ),
              ),
              ListTile(
                title: Text(
                    'Sign Out',
                ),
                onTap: () {
                  // Signing the User Out

                  FirebaseAuth auth = FirebaseAuth.instance;
                  auth.signOut().then((res) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SignUp()
                        ),
                            (Route<dynamic> route) => false
                    );
                  });
                },
              ),
            ],
          )
          : this.listView,
        ),
      ),
      appBar: AppBar(
          backgroundColor: Color(0xFF10B5FC),
          title: Text('Home'),
          // centerTitle: true,
      ),
      body: this.body,
    );
  }
}
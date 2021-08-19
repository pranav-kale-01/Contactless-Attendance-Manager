import 'package:flutter/material.dart';
import 'package:test_app/Screens/SignUp.dart';
import 'package:test_app/Templates/HomeScreenBuilder.dart';
import 'package:test_app/Templates/GradientContainer.dart';

import 'package:firebase_auth/firebase_auth.dart';

class BranchAdmin extends StatelessWidget {
  const BranchAdmin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HomeScreenBuilder(
      listView: ListView(
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
            title: Text( 'Sign Out', ),
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
      ),
      body: GradientContainer(
        child: Text('branch admin'),
      ),
    );
  }
}

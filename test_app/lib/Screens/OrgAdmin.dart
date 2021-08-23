import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:test_app/Cards/InsertBranch.dart';
import 'package:test_app/Cards/ViewBranch.dart';
import 'package:test_app/Screens/SignUp.dart';
import 'package:test_app/Templates/HomeScreenBuilder.dart';
import 'package:test_app/Templates/GradientContainer.dart';
import 'package:test_app/utils/CredentialController.dart';

class OrgAdmin extends StatelessWidget {
  const OrgAdmin({Key? key}) : super(key: key);

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
            title: Text( 'insert branch', ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InsertBranch(),
                  ),
              );
            },
          ),
          ListTile(
            title: Text( 'View branches', ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewBranch(),
                ),
              );
            },
          ),
          ListTile(
            title: Text( 'Sign Out', ),
            onTap: () async {
              // Signing the User Out
              if( !kIsWeb) {
                await CredentialController.clearFile();
              }

              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SignUp()
                  ),
                      (Route<dynamic> route) => false
              );
            },
          ),
        ],
      ),
      body: GradientContainer(
        child: Text('organization admin'),
      ),
    );
  }
}

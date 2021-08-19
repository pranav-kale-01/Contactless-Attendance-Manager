import 'package:flutter/material.dart';
import 'package:test_app/Screens/SignUp.dart';
import 'package:test_app/Templates/HomeScreenBuilder.dart';
import 'package:test_app/Templates/GradientContainer.dart';
import 'package:test_app/Cards/InsertOrganization.dart';
import 'package:test_app/Cards/ViewOrganizations.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class SuperAdmin extends StatelessWidget {
  // `org_name`, `org_email`, `db_name`, `db_user`
  late String org_name;
  late String org_email='';

  SuperAdmin({Key? key}) : super(key: key);

  Future<void> insertOrg( ) async {
    String url = "https://test-pranav-kale.000webhostapp.com/scripts/insert_org.php?name='${this.org_name}'&mail='${this.org_email}'";

    http.Response response = await http.get( Uri.parse( url ) );

    print("inserted");
    // Map<String,dynamic> jsonData = jsonDecode( response.body ) ;
    //
    // print( jsonDecode );
  }

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
            title: Text( 'View all Organizations', ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context)=> ViewOrganizations(),
                  )
              );
            },
          ),
          ListTile(
            title: Text( 'Add new Organization', ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context)=> InsertOrganization(),
                )
              );
            },
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
        child: null,
      ),
    );
  }
}

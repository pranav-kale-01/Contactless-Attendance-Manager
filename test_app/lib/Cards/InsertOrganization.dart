import 'package:flutter/material.dart';

import 'package:test_app/Cards/ViewOrganizations.dart';
import 'package:test_app/Cards/ManageOrganizationAdmins.dart';
import 'package:test_app/Screens/SignUp.dart';
import 'package:test_app/Templates/HomeScreenBuilder.dart';
import 'package:test_app/utils/CredentialController.dart';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;


class InsertOrganization extends StatefulWidget {
  const InsertOrganization({Key? key}) : super(key: key);

  @override
  _InsertOrganizationState createState() => _InsertOrganizationState();
}

class _InsertOrganizationState extends State<InsertOrganization> {
  late String org_name;
  late String org_email='';

  Future<void> insertOrg( ) async {
    String url = "https://test-pranav-kale.000webhostapp.com/scripts/insert_org.php?name='${this.org_name}'&mail='${this.org_email}'";

    http.Response response = await http.get( Uri.parse( url ) );
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreenBuilder(
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
              title: Text( 'Manage Organization admin', ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context)=> ManageOrganizationsAdmins(),
                    )
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
        body: Container(
            padding: EdgeInsets.all( 20.0 ),
            // `org_id`, `org_name`, `org_email`, `db_name`, `db_user`
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  width: 450,
                  child:TextField(
                    decoration: InputDecoration(
                      labelText: 'Organization Name',
                    ),
                    onChanged: (value) {
                      this.org_name = value;
                    },
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  width: 450,
                  child:TextField(
                    decoration: InputDecoration(
                      labelText: 'Organization Email',
                    ),
                    onChanged: (value) {
                      this.org_email = value;
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.all( 20.0 ),
                  child: MaterialButton(
                    color: Colors.blue,
                    onPressed: () async {
                      await insertOrg( );

                      // popping the current Screen
                      Navigator.pop(context);

                      // showing a AlertDialog
                      showDialog(
                        context: context,
                        builder: (BuildContext) {
                            return AlertDialog(
                              title: Text("Organization Added"),
                              content: Text("Organization added to the List"),
                            );
                        }
                      );
                    },
                    child: Text(
                      'Add New Organization',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            )
        ),
      ),
    );
  }
}
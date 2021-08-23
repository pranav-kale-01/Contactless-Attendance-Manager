import 'package:flutter/material.dart';

import 'package:test_app/Screens/SignUp.dart';
import 'package:test_app/Cards/InsertOrganization.dart';
import 'package:test_app/Cards/ViewOrganizations.dart';
import 'package:test_app/Templates/HomeScreenBuilder.dart';
import 'package:test_app/utils/CredentialController.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:convert';


class ManageOrganizationsAdmins extends StatefulWidget {
  const ManageOrganizationsAdmins({Key? key}) : super(key: key);

  @override
  _ManageOrganizationsAdminsState createState() => _ManageOrganizationsAdminsState();
}

class _ManageOrganizationsAdminsState extends State<ManageOrganizationsAdmins> {
  var nameController = TextEditingController();
  var emailController = TextEditingController();

  late String username;
  late String password;
  late String orgID;

  late dynamic jsonData;
  List<Container> organizations = [ ];

  Future<void> insertOrgAdmin( ) async {
    // adding the user details to the mysql database
    String url = "https://test-pranav-kale.000webhostapp.com/scripts/insert.php?user='${this.username}'&pass='${this.password}'&authority='org-admin'&orgid=${this.orgID}";

    http.Response response = await http.get( Uri.parse( url ) );
  }

  Future<void> viewOrgAdmins( ) async {
    organizations.clear();

    String url = "https://test-pranav-kale.000webhostapp.com/scripts/get.php?table=users";

    http.Response response = await http.get( Uri.parse( url ) );

    jsonData = jsonDecode( response.body ) ;

    // adding header
    organizations.add( containerBuilder( "ID", 'username', 'org_id', false , false ) );

    for (int j = 0; j < jsonData.length; j++) {
      Map<String, dynamic> data = jsonDecode(jsonData[j]);
      // adding the information to the organizations list for displaying
      if( data['authority'] == 'org-admin' )
        organizations.add( containerBuilder(data['UID'], data['username'], data['org_id'], true, true) );
    }

    // adding a add new organization admin button at the last
    organizations.add(
        Container(
          alignment: Alignment.center,
          child: MaterialButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context ) {
                    return AlertDialog(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            onChanged: (value) {
                              this.username = value;
                            },
                            decoration: InputDecoration(
                              labelText: "user email"
                            ),
                          ),
                          TextField(
                            onChanged: (value) {
                              this.orgID = value;
                            },
                            decoration: InputDecoration(
                                labelText: "organization ID"
                            ),
                          ),
                          TextField(
                            onChanged: (value) {
                              this.password = value;
                            },
                            decoration: InputDecoration(
                              labelText: "password",
                            ),
                          ),
                          MaterialButton(
                            onPressed: () {
                              // adding the user to the users table
                              insertOrgAdmin();

                              // closing the Popup
                              Navigator.pop(context);

                              // showing the confirmation message
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context ) {
                                    return AlertDialog(
                                      title: Text("User Added Successfully"),
                                    );
                                  }
                              );
                              
                              setState( ( ) {} );
                            },
                            child: Text("Add"),
                          )
                        ]
                      ),
                    );
                  }
              );
            },
            child: Row(
              children: [
                Icon(
                  Icons.add,
                  color: Colors.blue,
                ),
                Text("Add new Organization Admin"),
              ],
            ),
          ),
        )
    );
  }

  Container containerBuilder( UID , String username, String orgID , bool addEdit, bool addDelete ) {
    return Container(
      color: Colors.white60,
      padding: EdgeInsets.all( 20.0 ),
      margin: EdgeInsets.all( 2.5 ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
              width: 150.0,
              height: 50.0,
              margin: EdgeInsets.symmetric(horizontal: 20.0 ),
              child: Text( UID )
          ),
          Container(
              width: 150.0,
              height: 50.0,
              margin: EdgeInsets.symmetric(horizontal: 20.0 ),
              child: Text( username )
          ),
          Container(
              width: 150.0,
              height: 50.0,
              margin: EdgeInsets.symmetric(horizontal: 20.0 ),
              child: Text( orgID )
          ),
          addEdit ? MaterialButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context ) {
                      this.username = username;

                      return AlertDialog(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              onChanged: (value) {
                                this.username = value;
                              },
                              decoration: InputDecoration(
                                labelText: "username",
                              ),
                            ),
                            MaterialButton(
                              onPressed: () async {
                                String url = "https://test-pranav-kale.000webhostapp.com/scripts/edit_user.php?id=$UID&name='${this.username}'";
                                print( url );

                                http.Response response = await http.get( Uri.parse( url ) );

                                // if response.body == 1, editing user details was successful
                                if( response.body == '1') {
                                  Navigator.pop( context );

                                  setState(() { });
                                }
                              },
                              child: Text("Edit"),
                            ),
                          ],
                        ),
                      );
                    }
                );
              },
              child: Container(
                width: 150.0,
                margin: EdgeInsets.symmetric(horizontal: 20.0 ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(
                      Icons.edit,
                      color: Colors.black,
                    ),
                    Text(
                      'Edit',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    )
                  ],
                ),
              ),
          ) : Container(
            width: 210.0,
            height: 50.0,
          ),
          addDelete? MaterialButton(
              onPressed: () async {
                // delete the User
                String url = "https://test-pranav-kale.000webhostapp.com/scripts/delete_user.php?user='$username'";

                http.Response response = await http.get( Uri.parse( url ) );

                print( response.body );

                if( response.body == "1" ) {

                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Text("User Deleted.."),
                        );
                      }
                  );

                  setState( () {} );
                }
              },
              child: Container(
                width: 150.0,
                margin: EdgeInsets.symmetric(horizontal: 20.0 ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(
                      Icons.indeterminate_check_box_outlined,
                      color: Colors.red,
                    ),
                    Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.red,
                        decoration: TextDecoration.underline,
                      ),
                    )
                  ],
                ),
              )
          ) : Container(
            width: 210.0,
            height: 50.0,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: viewOrgAdmins(),
        builder: (context,snapshot) {
          if( snapshot.connectionState == ConnectionState.done ) {
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
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child : Container(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: organizations,
                        ),
                      ),
                    ),
                  )
              ),
            );
          }
          else if( snapshot.hasError ) {
            return Container(
              child: Text( snapshot.error.toString() ),
            );
          }
          else {
            return Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            );
          }
        }
    );
  }
}
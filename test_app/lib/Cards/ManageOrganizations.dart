import 'package:flutter/material.dart';

import 'package:test_app/Screens/SignUp.dart';
import 'package:test_app/Cards/ManageOrganizationAdmins.dart';
import 'package:test_app/Cards/ManageBranch.dart';
import 'package:test_app/Cards/ManageBranchAdmins.dart';
import 'package:test_app/Templates/HomeScreenBuilder.dart';
import 'package:test_app/utils/CredentialController.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:convert';

class ViewOrganizations extends StatefulWidget {
  bool showHamMenu = true;

  ViewOrganizations({Key? key, showHamMenu }) : super(key: key) {
    if( showHamMenu != null ) {
      this.showHamMenu = showHamMenu;
    }
  }

  @override
  _ViewOrganizationsState createState() => _ViewOrganizationsState();
}

class _ViewOrganizationsState extends State<ViewOrganizations> {
  var nameController = TextEditingController();
  var emailController = TextEditingController();

  late String orgName;
  late String orgEmail='';

  late dynamic jsonData;
  List<Widget> organizations = [ ];

  Future<void> insertOrg( ) async {
    String url = "https://test-pranav-kale.000webhostapp.com/scripts/org.php?function=0&name='${this.orgName}'&mail='${this.orgEmail}'";

    await http.get( Uri.parse( url ) );
  }

  Future<void> viewOrg( ) async {
    String url = "https://test-pranav-kale.000webhostapp.com/scripts/get.php?table=organization&condition&post&condition2&post2&custom";

    http.Response response = await http.get( Uri.parse( url ) );

    jsonData = jsonDecode( response.body ) ;

    if( jsonData == 'false') {
      return;
    }

    // clearing organizations list
    organizations.clear();

    for (int j = 0; j < jsonData.length; j++) {
      // adding the information to the organizations list for displaying
      organizations.add( containerBuilder(jsonData[j], true, true ) );
    }
  }

  Future<void> editOrg( String name, String email, String id ) async {
    if( name == "" ) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Invalid Data '),
              content: Text('Organization Name cannot be Empty'),
            );
          }
      );
      return;
    }

    String url = "https://test-pranav-kale.000webhostapp.com/scripts/org.php?function=2&id=$id&name='$name'&mail='$email'";

    http.Response response = await http.get( Uri.parse( url ) );

    if( response.body != '1' )
      print( response.body ) ;

    // closing the AlertBox
    Navigator.pop(context);

    // setting the State
    setState( () {} ) ;
  }

  Widget _buildPopupDialog( String name, String email, String id ) {
    this.orgName = name ;
    this.orgEmail = email ;

    return AlertDialog(
      content: Container(
          padding: EdgeInsets.all( 20.0 ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                width: 450,
                child:TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Organization Name',
                  ),
                  onChanged: (value) {
                    this.orgName = value;
                  },
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                width: 450,
                child:TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Organization Email',
                  ),
                  onChanged: (value) {
                    this.orgEmail = value;
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.all( 20.0 ),
                child: MaterialButton(
                  color: Colors.blue,
                  onPressed: () async {
                    await editOrg( this.orgName, this.orgEmail, id );
                  },
                  child: Text(
                    'Edit Organization',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          )
      ),
    );
  }

  Widget containerBuilder( var data , bool addEdit, bool addDelete ) {
    return Container(
      alignment: Alignment.centerLeft,
      color: Colors.white60,
      padding: EdgeInsets.all( 20.0 ),
      margin: EdgeInsets.symmetric(vertical: 2.5 ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
              width: 150.0,
              height: 50.0,
              margin: EdgeInsets.symmetric(horizontal: 20.0 ),
              child: Text( data['org_name'] )
          ),
          Container(
              width: 150.0,
              height: 50.0,
              margin: EdgeInsets.symmetric(horizontal: 20.0 ),
              child: Text( data['org_mail'] )
          ),
          addEdit? MaterialButton(
              onPressed: () {
                nameController.text= data['org_name'] ;
                emailController.text= data['org_mail'] ;

                showDialog(
                    context: context,
                    builder: (BuildContext context) => _buildPopupDialog( data['org_name'], data['org_mail'] , data['org_id'] ),
                );
              },
              child: Container(
                width: 150.0,
                margin: EdgeInsets.symmetric( horizontal: 20.0 ),
                padding: EdgeInsets.all(20.0),
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
              )
          ) : Container(
            width: 210.0,
            height: 50.0,
          ),
          addDelete? Container(
            width: 150.0,
            margin: EdgeInsets.symmetric( horizontal: 20.0 ),
            child: PopupMenuButton(
              padding: EdgeInsets.all(20.0),
              offset: Offset(10.0,0.0),
              icon: Icon( Icons.more_horiz ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 0,
                  child: Text("Manage Organization Admins"),
                ),
                PopupMenuItem(
                  value: 2,
                  child: Text("Manage Branches"),
                ),
                PopupMenuItem(
                  value: 3,
                  child: Text("Manage Branch Admins"),
                )
              ],
              onSelected: (int value) {
                if(value == 0) {
                  print("Manage Organization Admins");

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ManageOrganizationsAdmins( orgID: data['org_id'] , showHamMenu: false,),
                    )
                  );
                }
                else if( value == 2 ){
                  print("Manage Branch");

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ViewBranch( setState: setState, context: context, userInfo: data, showHamMenu: false,  ),
                    ),
                  );
                }
                else if( value == 3 ) {
                  print("Manage Branch Admins");

                  Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ManageBranchAdmins( userInfo: data, context: context,  setState: setState, showHamMenu: false, ),
                      )
                  );
                }
              },
            ),
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
        future: viewOrg(),
        builder: (context,snapshot) {
          if( snapshot.connectionState == ConnectionState.done ) {
            Map<String,dynamic> header = {
              'org_name': "Name",
              'org_id': "ID",
              'org_mail': "Mail",
            };

            return HomeScreenBuilder(
              appbar: AppBar(
                backgroundColor: Color(0xFF10B5FC),
                actions: [
                  Container(
                    margin: EdgeInsets.symmetric( horizontal: 20.0 ),
                    child: IconButton(
                      icon: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        // showing the dialog box to add the new user
                        showDialog(
                          context: context,
                          builder: (BuildContext context ) {
                            return AlertDialog(
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    decoration: InputDecoration(
                                      labelText: "Organization Name"
                                    ),
                                    onChanged: (value) {
                                      this.orgName = value;
                                    },
                                  ),
                                  TextField(
                                    decoration: InputDecoration(
                                      labelText: "Organization Email"
                                    ),
                                    onChanged: (value) {
                                      this.orgEmail = value;
                                    },
                                  ),
                                  MaterialButton(
                                    onPressed: () async {
                                      await insertOrg( );

                                      // popping the current Screen
                                      Navigator.pop(context);

                                      // reloading current screen
                                      setState( () {} );

                                      // showing a AlertDialog
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text("Organization Added"),
                                              content: Text("Organization added to the List"),
                                            );
                                          }
                                      );
                                    },
                                    child: Text("Add"),
                                  ),
                                ],
                              ),
                            );
                          }
                        );
                      },
                    ),
                  )
                ],
              ),
              listView: widget.showHamMenu ? ListView(
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
                            builder: (context)=> ViewOrganizations( ),
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
              ) : null ,
              body: Container(
                  color: Colors.blueAccent,
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Container(
                        width: 1400.0,
                        alignment: Alignment.center,
                        child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: containerBuilder( header , false, false ),
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height - 165.0 ,
                        child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child : Container(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: organizations,
                              ),
                            ),
                        ),
                ),
                      ),
                    ],
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
import 'package:flutter/material.dart';

import 'package:test_app/Screens/SignUp.dart';
import 'package:test_app/Cards/InsertOrganization.dart';
import 'package:test_app/Cards/ManageOrganizationAdmins.dart';
import 'package:test_app/Templates/HomeScreenBuilder.dart';
import 'package:test_app/utils/CredentialController.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:convert';

class ViewOrganizations extends StatefulWidget {
  const ViewOrganizations({Key? key}) : super(key: key);

  @override
  _ViewOrganizationsState createState() => _ViewOrganizationsState();
}

class _ViewOrganizationsState extends State<ViewOrganizations> {
  var nameController = TextEditingController();
  var emailController = TextEditingController();

  late String org_name;
  late String org_email='';

  late dynamic jsonData;
  List<Widget> organizations = [ ];


  Future<void> viewOrg( ) async {
    String url = "https://test-pranav-kale.000webhostapp.com/scripts/get.php?table=organization";

    http.Response response = await http.get( Uri.parse( url ) );


    jsonData = jsonDecode( response.body ) ;

    // clearing organizations list
    organizations.clear();

    // adding header
    organizations.add( ContainerBuilder( "ID", "NAME", "MAIL",false, false ) );

    for (int j = 0; j < jsonData.length; j++) {
      Map<String, dynamic> data = jsonDecode(jsonData[j]);
      // adding the information to the organizations list for displaying
      organizations.add( ContainerBuilder(data['org_id'], data['org_name'], data['org_mail'], true, true ) );
    }
  }

  Future<void> editOrg( String name, String email, String ID ) async {
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

    String url = "https://test-pranav-kale.000webhostapp.com/scripts/edit_org.php?id=$ID&name='$name'&mail='$email'";

    http.Response response = await http.get( Uri.parse( url ) );

    if( response.body != '1' )
      print( response.body ) ;

    // closing the AlertBox
    Navigator.pop(context);

    // setting the State
    setState( () {} ) ;
  }

  Widget _buildPopupDialog( String name, String email, String ID ) {
    this.org_name = name ;
    this.org_email = email ;

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
                    this.org_name = value;
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
                    this.org_email = value;
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.all( 20.0 ),
                child: MaterialButton(
                  color: Colors.blue,
                  onPressed: () async {
                    await editOrg( this.org_name, this.org_email, ID );
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

  Widget ContainerBuilder( ID , String name, String mail , bool addEdit, bool addDelete ) {
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
              child: Text( ID )
          ),
          Container(
              width: 150.0,
              height: 50.0,
              margin: EdgeInsets.symmetric(horizontal: 20.0 ),
              child: Text( name )
          ),
          Container(
              width: 150.0,
              height: 50.0,
              margin: EdgeInsets.symmetric(horizontal: 20.0 ),
              child: Text( mail )
          ),
          addEdit? MaterialButton(
              onPressed: () {
                nameController.text= name ;
                emailController.text= mail ;

                showDialog(
                    context: context,
                    builder: (BuildContext context) => _buildPopupDialog( name , mail , ID),
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
              )
          ) : Container(
            width: 210.0,
            height: 50.0,
          ),
          addDelete ? MaterialButton(
              onPressed: () {
                // delete the User
                // String url = "https://test-pranav-kale.000webhostapp.com/scripts/delete_user.php?user='${}'";
                //
                // http.Response response = await http.get( Uri.parse( url ) );
                //
                // print( response.body );
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
        future: viewOrg(),
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
                          mainAxisAlignment: MainAxisAlignment.start,
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
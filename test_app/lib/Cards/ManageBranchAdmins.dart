import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:test_app/Screens/SignUp.dart';
import 'package:test_app/Templates/HomeScreenBuilder.dart';
import 'package:test_app/Templates/GradientContainer.dart';
import 'package:test_app/Cards/ManageBranch.dart';
import 'package:test_app/utils/CredentialController.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class ManageBranchAdmins extends StatefulWidget {
  final userInfo;

  ManageBranchAdmins({Key? key, required this.userInfo }) : super( key: key);

  @override
  _ManageBranchAdminsState createState() => _ManageBranchAdminsState();
}

class _ManageBranchAdminsState extends State<ManageBranchAdmins>  {

  List<Widget> users = [];

  Future<void> _init() async {
    String url = "https://test-pranav-kale.000webhostapp.com/scripts/get.php?table=users&condition=authority&post='branch-admin';";

    http.Response response = await http.get( Uri.parse( url ) ) ;

    if( response.body == 'false' ) {
      print("something went wrong");
    }
    else {
      // decoding the data
      var data = jsonDecode( response.body );

      // clearing the previous list
      users.clear();

      // insert the data to the branches list
      for (int j = 0; j < data.length ; j++) {
        Map<String, dynamic> jsonData = jsonDecode( data[j]);

        // checking if the org_id of current record is equal to the org_id of the user
        users.add( containerBuilder( jsonData['UID'], jsonData['username'], jsonData['org_id'], jsonData['authority'], true , true ) );
      }
    }
  }

  Widget containerBuilder( String id , String  username, String orgID ,String authority , bool addEdit, bool addDelete ) {
    return Container(
      alignment: Alignment.centerLeft,
      color: Colors.white60,
      padding: EdgeInsets.all( 20.0 ),
      margin: EdgeInsets.symmetric(vertical: 2.5 ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
              width: 50.0,
              height: 50.0,
              margin: EdgeInsets.symmetric(horizontal: 20.0 ),
              child: Text( id )
          ),
          Container(
              width: 200.0,
              height: 50.0,
              margin: EdgeInsets.symmetric(horizontal: 20.0 ),
              child: Text( username )
          ),
          Container(
              width: 100.0,
              height: 50.0,
              margin: EdgeInsets.symmetric(horizontal: 20.0 ),
              child: Text( orgID )
          ),
          Container(
              width: 100.0,
              height: 50.0,
              margin: EdgeInsets.symmetric(horizontal: 20.0 ),
              child: Text( authority )
          ),
          addEdit ? MaterialButton(
              onPressed: () {
                // edit user
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
            width: 205.0,
          ),
          addDelete ? MaterialButton(
              onPressed: () {
                // delete user
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
            width: 205.0,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context ) {
    return FutureBuilder(
        future: _init(),
        builder: ( context, snapshot ) {
          if( snapshot.connectionState == ConnectionState.done ) {
            return HomeScreenBuilder(
              appbar: AppBar(
                actions: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
                    child: IconButton(
                      icon: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        // showing the insert user popup

                      },
                    ),
                  )
                ],
                backgroundColor: Color(0xFF10B5FC),
                title: Text( "View Branch Admins" ),
              ),
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
                    title: Text( 'Manage branches', ),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewBranch( userInfo: widget.userInfo ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: Text( 'Manage Branch Admins', ),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(

                          builder: (context) => ManageBranchAdmins( userInfo: widget.userInfo, ),
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
                          child: containerBuilder( "ID", 'Username', 'Organization ID', 'Authority' , false, false)
                      ),
                    ),
                    Container(
                        height: MediaQuery.of(context).size.height - 151.0 ,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child : Container(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: users,
                              ),
                            ),
                          ),
                        )
                    ),
                  ],
                ),
              ),
            );
          }
          else {
            return HomeScreenBuilder(
                appbar: AppBar(
                  backgroundColor: Color(0xFF10B5FC),
                  title: Text( "View Branch Admins" ),
                ),
                body: Center(
                  child: GradientContainer(
                      child: CircularProgressIndicator()
                  ),
                )
            );
          }
        }
    );
  }
}
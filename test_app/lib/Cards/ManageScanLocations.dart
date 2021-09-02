import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:test_app/Cards/ManageBranch.dart';
import 'package:test_app/Cards/ManageBranchAdmins.dart';
import 'package:test_app/Cards/ManageEmployee.dart';
import 'package:test_app/Screens/SignUp.dart';
import 'package:test_app/Templates/GradientContainer.dart';
import 'package:test_app/Templates/HomeScreenBuilder.dart';
import 'package:test_app/utils/CredentialController.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'AddScannerLocation.dart';

class ManageScanLocations extends StatefulWidget {
  final userInfo ;

  ManageScanLocations( {Key? key, required this.userInfo }) : super(key : key ) ;

  @override
  _ManageScanLocationsState createState() => _ManageScanLocationsState();
}

class _ManageScanLocationsState extends State<ManageScanLocations> {
  List<Container> scanPoints = [];

  Future<bool> _getScanPoints( ) async {
    // checking if the user is Organization admin, if so taking the branch Id from the Dropdown menu
    if( widget.userInfo['authority'] == 'org-admin') {

    }

    String url = "https://test-pranav-kale.000webhostapp.com/scripts/get.php?table=scan_locations&condition&post&condition2&post2&custom= * FROM `scan_locations` WHERE `org_id`=10%20AND%20`branch_id`=40";

    http.Response response = await http.get(  Uri.parse( url ) );

    print( response.body );

    return true;
  }

  Future<void> init() async {
    await _getScanPoints();
  }

  Future<void> insertScanLocation() async {
    String url = "https://test-pranav-kale.000webhostapp.com/scripts/insert_scanpoint.php?org_id=10&branch_id=31&location=12345kajsdflkjsaldfjka&qr=m658n32nl7k68nlk453l745kn73.;";

    http.Response response = await http.get( Uri.parse( url ) );

    if( response.body == 'false') {
      print("something went wrong");
    }
    else {
      print("Scan Location added successfully");
    }
  }

  Future<void> removeScanPoint( String branchID ) async {}

  Widget containerBuilder( data  ,bool addDelete ) {
    return Container(
      alignment: Alignment.centerLeft,
      color: Colors.white60,
      padding: EdgeInsets.all( 20.0 ),
      margin: EdgeInsets.symmetric(vertical: 2.5 ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
              width: 100.0,
              height: 50.0,
              margin: EdgeInsets.symmetric(horizontal: 20.0 ),
              child: Text( data['branch_id'] )
          ),
          Container(
              width: 200.0,
              height: 50.0,
              margin: EdgeInsets.symmetric(horizontal: 20.0 ),
              child: Text( data['branch_name'] )
          ),
          Container(
              width: 300.0,
              height: 50.0,
              margin: EdgeInsets.symmetric(horizontal: 20.0 ),
              child: Text( data['address'] )
          ),
          addDelete ? MaterialButton(
              onPressed: () {
                // delete branch
                removeScanPoint( data['branch_id'] );

                setState(() { });
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

  Container scanLocationViewBuilder( ) {
    Map<String, dynamic> header = {
      'branch_id': 'BRANCH ID',
      'branch_name': 'BRANCH NAME',
      'address': 'ADDRESS',
    };

    return Container(
      color: Colors.blueAccent,
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            width: 1400.0,
            alignment: Alignment.center,
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: containerBuilder( header ,false)
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
                      children: scanPoints,
                    ),
                  ),
                ),
              )
          ),
        ],
      ),
    );
  }

  @override
  Widget build( BuildContext context ) {
    return FutureBuilder(
      future: init(),
      builder: (context, snapshot ) {
        if(snapshot.connectionState == ConnectionState.done ) {
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
                    onPressed: () async {
                      // redirecting to the AddScannerLocation Page
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          opaque: false,
                          pageBuilder: (context, _ , __ ) => AddScannerLocation( userInfo: widget.userInfo, ),
                        ),
                      );
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
                widget.userInfo['authority'] == 'org-admin' ?
                ListTile(
                  title: Text( 'Manage branches', ),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewBranch( context: context, setState: setState, userInfo: widget.userInfo ),
                      ),
                    );
                  },
                ) : Container(),
                widget.userInfo['authority'] == 'org-admin'?
                ListTile(
                  title: Text( 'Manage Branch Admins', ),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ManageBranchAdmins( context: context, setState: setState,  userInfo: widget.userInfo ),
                      ),
                    );
                  },
                ) : Container(),
                ListTile(
                  title: Text( 'Manage Employees', ),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ManageEmployee( setState1:  setState, context: context , userInfo: widget.userInfo, ),
                      ),
                    );
                  },
                ),
                ListTile(
                    title: Text("Manage Scan Locations"),
                    onTap: () {
                      // redirecting the user to ManageScanLocations Page
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManageScanLocations( userInfo: widget.userInfo ),
                        ),
                      );
                    }
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
              child: Container(
                alignment: Alignment.center,
                child: Text("Manage Scan Locations"),
              ),
            ),
          );
        }
        else {
          return HomeScreenBuilder(
              body: Center(
                child: GradientContainer(
                  child: CircularProgressIndicator(),
                ),
              )
          );
        }
      }
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:test_app/Cards/ManageBranch.dart';
import 'package:test_app/Cards/ManageBranchAdmins.dart';
import 'package:test_app/Cards/ManageEmployee.dart';
import 'package:test_app/Cards/ManageScanLocations.dart';
import 'package:test_app/Cards/ManageShifts.dart';
import 'package:test_app/Screens/SignUp.dart';

import 'package:test_app/utils/CredentialController.dart';

import 'package:test_app/Templates/HomeScreenBuilder.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class  ManageScanHistory extends StatefulWidget {
  final userInfo;
  bool showHamMenu = true;
  late String branchID;

  bool changedFromDropdown = false;
  bool showAllValue = true;

  ManageScanHistory( {Key? key, required this.userInfo, showHamMenu } ) : super( key: key ) {
    if( showHamMenu != null ){
      this.showHamMenu = showHamMenu ;
    }
  }

  @override
  ManageScanHistoryState createState() => ManageScanHistoryState();
}

class ManageScanHistoryState extends State<ManageScanHistory> {
  List<Widget> employees = [];
  List<List> records = [];
  int? index2;

  Future<void> init( ) async {
    await getEmployeesScanHistory();
  }

  Future<void> getEmployeesScanHistory() async {
    String url;
    url = "https://test-pranav-kale.000webhostapp.com/scripts/get.php?table=users&condition=&post=&condition2=&post2=&custom= * FROM `scans` WHERE `UID` = ${widget.userInfo['UID']}";

    http.Response response = await http.get( Uri.parse( url ) );

    print( response.body );

    List<dynamic> jsonData = jsonDecode( response.body );

    if( response.body == '') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text("Failed to Load"),
        ),
      );
    }
    else {
      // clearing the previous list of Employees
      employees.clear();
      records.clear();

      for( int i=0 ; i < jsonData.length ; i++ ) {
        Map<String,dynamic> data = jsonData[i];
        employees.add( containerBuilder( data, true , true , ) );
        records.add( [ data['UID'], data['coordinates'], data['time'], data['scanner_location'], data['start_time'], data['end_time'] ] );
      }
    }
  }

  Widget containerBuilder( var data, bool addEdit,bool addDelete) {
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
              padding: EdgeInsets.all( 10.0 ),
              child: Text( data['coordinates'] )
          ),
          Container(
              width: 200.0,
              height: 50.0,
              margin: EdgeInsets.symmetric(horizontal: 20.0 ),
              padding: EdgeInsets.all( 10.0 ),
              child: Text( data['time'] )
          ),
          Container(
              width: 200.0,
              height: 50.0,
              margin: EdgeInsets.symmetric(horizontal: 20.0 ),
              padding: EdgeInsets.all( 10.0 ),
              child: Text( data['scanner_location'] )
          ),
          Container(
              width: 200.0,
              height: 50.0,
              margin: EdgeInsets.symmetric(horizontal: 20.0 ),
              padding: EdgeInsets.all( 10.0 ),
              child: Text( data['start_time'] )
          ),
          Container(
              width: 200.0,
              height: 50.0,
              margin: EdgeInsets.symmetric(horizontal: 20.0 ),
              padding: EdgeInsets.all( 10.0 ),
              child: Text( data['end_time'] )
          ),
          addEdit ? MaterialButton(
              onPressed: () { },
              child: Container(
                width: 150.0,
                margin: EdgeInsets.symmetric(horizontal: 20.0 ),
                padding: EdgeInsets.all( 10.0 ),
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
              onPressed: () { },
              child: Container(
                width: 150.0,
                margin: EdgeInsets.symmetric(horizontal: 20.0 ),
                padding: EdgeInsets.all( 10.0 ),
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

  Container _employeeViewBuilder(){
    Map<String, String> header = {
      'UID' : "User ID",
      'coordinates' : "Coordinates",
      'time' : "Scan Time",
      'scanner_location' : "Scanner Location",
      'start_time' : "Start Time",
      'end_time' : "End Time"
    };

    return Container(
      color: Colors.blueAccent,
      alignment: Alignment.center,
      child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState1 ) {
            return Column(
              children: [
                Container(
                  width: 1400.0,
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: containerBuilder( header ,false, false, ),
                  ),
                ),
                Container(
                    height: MediaQuery.of(context).size.height - 200.0 ,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child : Container(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: employees,
                          ),
                        ),
                      ),
                    )
                ),
              ],
            );
          }
      ),
    );
  }

  @override
  Widget build( BuildContext context ) {
    return FutureBuilder(
      future: this.init(),
      builder: ( context, snapshot ) {
        if( snapshot.connectionState == ConnectionState.done ) {
          return HomeScreenBuilder(
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
                // checking if the user is Organization Admin
                widget.userInfo['authority'] == 'org-admin' ? ListTile(
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
                widget.userInfo['authority'] == 'org-admin' ? ListTile(
                  title: Text( 'Manage Branch Admins', ),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ManageBranchAdmins( context: context, setState: setState, userInfo: widget.userInfo, ),
                      ),
                    );
                  },
                ) : Container(),
                ListTile(
                  title: Text( 'Manage Employees', ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context)=> ManageEmployee( context: context, setState1: setState, userInfo: widget.userInfo,),
                        )
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
                    title: Text( 'Manage Shifts' ),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ManageShifts( userInfo: widget.userInfo )
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
            ) : null ,
            appbar: AppBar(
              actions: [
                IconButton(
                  onPressed: () {

                  },
                  icon: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            body: Container(
              alignment: Alignment.center,
              child: _employeeViewBuilder(),
            ),
          );
        }
        else if( snapshot.hasError ) {
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
              ]
            ),
            body: Container(
              alignment: Alignment.center,
              child: Text( snapshot.error.toString() ),
            ),
          );
        }
        else {
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
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          );
        }
      }

    );
  }
}
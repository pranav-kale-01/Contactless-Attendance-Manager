import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:test_app/Screens/SignUp.dart';
import 'package:test_app/Templates/HomeScreenBuilder.dart';
import 'package:test_app/utils/CredentialController.dart';

import 'package:test_app/Cards/ManageBranch.dart';
import 'package:test_app/Cards/ManageBranchAdmins.dart';
import 'package:test_app/Cards/ManageEmployee.dart';
import 'package:test_app/Cards/ManageScanLocations.dart';
import 'package:test_app/Cards/DateTimePicker.dart';

class ManageShifts extends StatefulWidget {
  final userInfo;

  ManageShifts( {Key? key, required this.userInfo }) : super( key: key );

  @override
  _ManageShiftsState createState() => _ManageShiftsState( );
}

class _ManageShiftsState extends State<ManageShifts> {
  late String _id;

  Future<void> _insertShift( ) async {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Container(
            child: Column(
              children: [
                // id, start_time, end_time,
                Container(
                  width: 100.0,
                  child: TextField(
                    onChanged: (value) {
                      this._id = value;
                    },
                    decoration: InputDecoration(
                      labelText: "ID",
                    )
                  ),
                ),
                TextField(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                          opaque: false,
                          pageBuilder: (context, _ , __ ) => DateTimePicker(),
                      ),
                    );
                  },
                  decoration: InputDecoration(
                    labelText: "Start-Time",
                  )
                ),
                TextField(
                    onTap: () {
                      var result = Navigator.push(
                        context,
                        PageRouteBuilder(
                          opaque: false,
                          pageBuilder: (context, _ , __ ) => DateTimePicker(),
                        ),
                      );

                      print( result );
                    },
                    decoration: InputDecoration(
                      labelText: "End-Time",
                    ),
                ),
                // org_id, branch_id will be fetched from widget.userInfo
              ],
            )
          )
        ),
      );
  }

  @override
  Widget build( BuildContext context ) {
    return HomeScreenBuilder(
      appbar: AppBar(
        actions: [
          Container(
            margin: EdgeInsets.symmetric( horizontal: 20.0 ),
            child: IconButton(
              icon: Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () {
                // adding a new shift to the shift table
                _insertShift( );
              }
            ),
          )
        ]
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
                  builder: (context) => ViewBranch( context: context, setState: setState, userInfo: widget.userInfo, ),
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
                  builder: (context) => ManageBranchAdmins( context: context, setState: setState, userInfo: widget.userInfo, ),
                ),
              );
            },
          ),
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
            Navigator.push(
            context,
            MaterialPageRoute(
            builder: (context) => ManageShifts(userInfo: widget.userInfo,)
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
        ]
      ),
      body: Container(
        alignment: Alignment.center,
        child: Text("Manage Shifts"),
      )
    );
  }
}
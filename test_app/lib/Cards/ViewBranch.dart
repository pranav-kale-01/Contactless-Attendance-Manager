import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:test_app/Screens/SignUp.dart';
import 'package:test_app/Templates/GradientContainer.dart';
import 'package:test_app/Templates/HomeScreenBuilder.dart';
import 'package:test_app/utils/CredentialController.dart';
import 'InsertBranch.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class ViewBranch extends StatefulWidget {
  const ViewBranch({Key? key}) : super(key: key);

  @override
  _ViewBranchState createState() => _ViewBranchState();
}

class _ViewBranchState extends State<ViewBranch> {

  List<Widget> branches = [];

  // initialize the branches list
  Future<void> _init() async {
    String url = "https://test-pranav-kale.000webhostapp.com/scripts/get.php?table=branches";

    http.Response response = await http.get( Uri.parse( url ) ) ;

    if( response.body == 'false' ) {
      print("something went wrong");
    }
    else {
      // decoding the data
      var data = jsonDecode( response.body );
      print(data);

      // insert the data to the branches list
      for (int j = 0; j < data.length; j++) {
        Map<String, dynamic> jsonData = jsonDecode( data[j]);

        branches.add(
            ContainerBuilder( jsonData['org_id'], jsonData['branch_id'], jsonData['branch_name'], jsonData['address'], false, false )
        );
      }
    }
  }

  Widget ContainerBuilder( ID , branchID, branchName , address , addEdit, addDelete ) {
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
              child: Text( branchID )
          ),
          Container(
              width: 150.0,
              height: 50.0,
              margin: EdgeInsets.symmetric(horizontal: 20.0 ),
              child: Text( branchName )
          ),Container(
              width: 150.0,
              height: 50.0,
              margin: EdgeInsets.symmetric(horizontal: 20.0 ),
              child: Text( address )
          ),
          addEdit? MaterialButton(
              onPressed: () {
                // nameController.text= name ;
                // emailController.text= mail ;
                //
                // showDialog(
                //   context: context,
                //   builder: (BuildContext context) => _buildPopupDialog( name , mail , ID),
                // );
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
              onPressed: () { },
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
      future: _init(),
      builder: ( context, snapshot ) {
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
                  title: Text( 'insert branch', ),
                  onTap: () {
                    Navigator.pushReplacement(
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
                    Navigator.pushReplacement(
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
            body:  Container(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child : Container(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: branches,
                        ),
                      ),
                    ),
                  )
              ),
          );
        }
        else {
          return HomeScreenBuilder(
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

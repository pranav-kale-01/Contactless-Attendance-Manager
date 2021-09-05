import 'package:flutter/material.dart';

import 'package:test_app/Screens/BranchAdmin.dart';
import 'package:test_app/Screens/OrgAdmin.dart';
import 'package:test_app/utils/Location.dart';
import 'package:test_app/Templates/GradientContainer.dart';
import 'package:test_app/Templates/HomeScreenBuilder.dart';
import 'package:test_app/Screens/Employee.dart';
import 'package:test_app/Screens/SuperAdmin.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class Home extends StatefulWidget {
  final String email;
  final String uid;

  Home({Key? key, required this.email, required this.uid }) : super( key: key );

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late String email;
  late String rangeStatus;
  late Map<String, String> coords;
  late Map<String,dynamic> data;
  Location locator = Location();
  bool interrupt = false;

  late String qrString='';

  @override
  void initState() {
    super.initState();

    this.email = widget.email;
  }

  Future<void> loadMainScreen( ) async {
    // creating the url to send the data
    String url = "https://test-pranav-kale.000webhostapp.com/scripts/get_user.php?UID='${widget.uid}'";

    http.Response response = await http.get(
        Uri.parse(url),
        headers: {
          "Access-Control-Allow-Origin": "*",
        }
    );
    if( response.body != 'false' ){
      this.data = jsonDecode( response.body );


      // checking the authority of the user
      if( this.data['authority'] == 's-admin' ){
        Navigator.pushReplacement(
            context,
            MaterialPageRoute( builder: (context) => SuperAdmin() ),
        );
      }
      else if( this.data['authority'] == 'org-admin' ){
        Navigator.pushReplacement(
            context,
            MaterialPageRoute( builder: (context) => OrgAdmin( data: this.data) ),
        );
      }
      else if( this.data['authority'] == 'br-admin' ){
        Navigator.pushReplacement(
            context,
            MaterialPageRoute( builder: (context) => BranchAdmin( data: this.data ) ),
        );
      }
      else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute( builder: (context) => Employee( data: this.data) ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadMainScreen(),
      builder: (context, snapshot) {
         if( snapshot.hasError == true ) {
          // failed to fetch the location
          return MaterialApp(
              home: HomeScreenBuilder(
                body: GestureDetector(
                  onTap: ()  async {
                    setState(() { });
                  },
                  child: GradientContainer(
                    child: Text( snapshot.error.toString(), ),
                  ),
                ),
              )
          );
        }
        else {
          return SafeArea(
            child: GradientContainer(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
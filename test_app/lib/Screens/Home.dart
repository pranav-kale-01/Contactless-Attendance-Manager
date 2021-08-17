import 'package:flutter/material.dart';
import 'package:test_app/utils/Location.dart';
import 'package:test_app/Templates/GradientContainer.dart';
import 'package:test_app/Templates/HomeScreenBuilder.dart';
import 'package:test_app/Screens/SignUp.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';

class Home extends StatefulWidget {
  late String email;

  Home({Key? key, required this.email }) : super( key: key );

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

  late String QRString='';

  @override
  void initState() {
    super.initState();

    this.email = widget.email;
  }

  Future<void> loadMainScreen( ) async {
    // FirebaseAuth.instance.currentUser.uid

    // creating the url to send the data
    String url = "https://test-pranav-kale.000webhostapp.com/get_user.php?uid=${FirebaseAuth.instance.currentUser!.uid}";
    print( url ) ;

    http.Response response = await http.get( Uri.parse(url) );
    this.data = jsonDecode( response.body );

    print(this.data);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadMainScreen(),
      builder: (context, snapshot) {
        if( snapshot.connectionState == ConnectionState.done ){
          // data fetched successfully, perform further processes
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
                    title: Text( 'Sign Out', ),
                    onTap: () {
                      // Signing the User Out

                      FirebaseAuth auth = FirebaseAuth.instance;
                      auth.signOut().then((res) {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUp()
                            ),
                                (Route<dynamic> route) => false
                        );
                      });
                    },
                  ),
                ],
              ),
              body: GradientContainer(
                  child: null,
              ),
            ),
          );
        }
        else if( snapshot.hasError == true ) {
          // failed to fetch the location
          return MaterialApp(
              home: HomeScreenBuilder(
                body: GestureDetector(
                  onTap: ()  async {
                    setState(() { });
                  },
                  child: GradientContainer(
                    child: Text( "couldn't load location, tap to retry", ),
                  ),
                ),
              )
          );
        }
        else{
          return HomeScreenBuilder(
            body: SafeArea(
              child: GradientContainer(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
      },
    );
  }
}
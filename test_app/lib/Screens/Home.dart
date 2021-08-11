import 'package:firebase_auth/firebase_auth.dart';

import 'package:test_app/Screens/SignUp.dart';

import 'package:test_app/Templates/GradientContainer.dart';

import 'package:flutter/material.dart';

import 'package:test_app/utils/Location.dart';


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
  Location locator = Location();
  bool interrupt = false;

  @override
  void initState() {
    this.email = widget.email;
  }

  Future<bool> loadCoordinates() async {
    // flags the interrupt so another loadCoordinates method cannot be executed
    interrupt = true;

    coords = await locator.getLocation();

    // checking if the co-ordinates are between a certain value
    if( double.parse( double.parse( coords['lat']! ).toStringAsFixed(4) ) >= 19.8885
        && double.parse( double.parse( coords['lat']! ).toStringAsFixed(4) ) <= 19.8895
        &&  double.parse( double.parse( coords['lon']! ).toStringAsFixed(4) ) >= 75.3680
        && double.parse( double.parse( coords['lon']! ).toStringAsFixed(4) ) <= 75.3700 ) {

      rangeStatus = 'in range';
    }
    else{
      rangeStatus = 'out of range';
    }

    interrupt = false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: loadCoordinates(),
        builder: (context, snapshot) {
          if( snapshot.connectionState == ConnectionState.done ){
              // data fetched successfully, perform further processes
              return MaterialApp(
                home: Scaffold(
                  appBar: AppBar(
                      title: Text('Home'),
                      actions: [
                        IconButton(
                            icon: Icon(
                              Icons.exit_to_app,
                              color: Colors.white,
                            ),
                            onPressed: () {
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
                            }
                        ),
                      ]
                  ),
                  body: GradientContainer(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'latitude - ${coords['lat']}',
                                  textDirection: TextDirection.ltr,
                                ),
                                Text(
                                  'longitude - ${coords['lon']}',
                                  textDirection: TextDirection.ltr,
                                ),
                                Text(
                                  'range status : $rangeStatus',
                                  textDirection: TextDirection.ltr,
                                ),
                                Text(
                                  'User email - ${FirebaseAuth.instance.currentUser!.email}',
                                  textDirection: TextDirection.ltr,
                                ),
                              ],
                            ),
                          ),

                          // adding a button which onPressed will print the new location
                          Expanded(
                            child: Container(
                              alignment: Alignment.bottomCenter,
                              child: MaterialButton(
                                padding: EdgeInsets.all(20.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all( Radius.circular( 20.0) ),
                                ),
                                color: Colors.blueAccent,
                                onPressed: ()  async {
                                  if( interrupt == false ) {
                                    await loadCoordinates();
                                  }
                                  setState( () {} );
                                },
                                child: Text("refresh"),
                              ),
                            ),
                          )
                        ],
                      )
                  ),
                ),
              );
          }
          else if( snapshot.hasError == true ) {
            // failed to fetch the location
            return MaterialApp(
                home: Scaffold(
                  body: GestureDetector(
                    onTap: ()  async {
                      setState(() { });
                    },
                    child: GradientContainer(
                      child: Text(
                        "couldn't load location, tap to retry",
                        textDirection: TextDirection.ltr,
                      ),
                    ),
                  ),
                )
            );
          }
          else{
            return Scaffold(
                appBar: AppBar(
                  title: Text('Home'),
                  actions: [
                    IconButton(
                        icon: Icon(
                          Icons.exit_to_app,
                          color: Colors.white,
                        ),
                        onPressed: () {
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
                        }
                    ),
                  ]
              ),
              body: SafeArea(
                child: Container(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }
        },
    );
  }
}
import 'package:flutter/material.dart';

import 'package:test_app/Templates/GradientContainer.dart';
import 'package:test_app/Templates/UserCredentials.dart';

import 'package:test_app/utils/Location.dart';

import 'package:test_app/Screens/LoginScreen.dart';

import 'package:firebase_auth/firebase_auth.dart';

class UserLogin extends StatefulWidget {
  static final String id = '/UserLogin';

  UserLogin( {Key? key }) : super( key: key) ;

  @override
  _UserLoginState createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  late String rangeStatus;
  late Map<String, String> coords;
  Location locator = Location();
  bool interrupt = false;

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

  Future<void> _signOut() async{
    await FirebaseAuth.instance.signOut();

    print(FirebaseAuth.instance.currentUser!.email );

    // changing the user screen to LoginScreen
    Navigator.pushReplacementNamed(context, LoginScreen.id );
  }

  @override
  Widget build(BuildContext context) {
    print('new page');

    return FutureBuilder(
      future: loadCoordinates(),
      builder: (context, snapshot) {

        final creds = ModalRoute.of(context)!.settings.arguments as UserCredentials;

        if( interrupt == false ) {
          // data fetched successfully, perform further processes
          return MaterialApp(
            home: Scaffold(
              body: GradientContainer(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      MaterialButton(
                        onPressed: () {
                            // logging the user out
                            // _signOut( );
                        },
                        child: Text('Log Out'),
                      ),
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
                            // Text(
                            //   'User email - ${creds.user.email}',
                            //   textDirection: TextDirection.ltr,
                            // ),
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
        else {
          // fetching the data
          return MaterialApp(
            home: Scaffold(
              body: GradientContainer(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
      },
    );
  }
}
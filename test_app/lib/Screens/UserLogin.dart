import 'package:flutter/material.dart';
import 'package:test_app/templates/GradientContainer.dart';
import 'package:test_app/utils/Location.dart';

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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadCoordinates(),
      builder: (context, snapshot) {
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
                            )
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
import 'package:flutter/material.dart';
import 'package:test_app/utils/Location.dart';
import 'package:test_app/Templates/GradientContainer.dart';
import 'package:test_app/Templates/HomeScreenBuilder.dart';
import 'package:test_app/Screens/SignUp.dart';
import 'package:test_app/Screens/BarCode.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import 'package:vector_math/vector_math.dart' as VMath;
import 'dart:math';

class Home extends StatefulWidget {
  late String email;

  Home({Key? key, required this.email }) : super( key: key );

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  // coordinates stored in the database which represent the location where the QR code is installed
  String _lat="0.0";
  String _lon="0.0";

  late String email;
  late String rangeStatus;
  late Map<String, String> coords;
  Location locator = Location();
  bool interrupt = false;

  late String QRString='';

  @override
  void initState() {
    super.initState();

    this.email = widget.email;
  }

  double calcDistance( double lat1, double lon1, double lat2, double lon2 ) {
    // creating new VMath object
    double _lat1 = VMath.radians(lat1);
    double _lon1 = VMath.radians(lon1);
    double _lat2 = VMath.radians(lat2);
    double _lon2 = VMath.radians(lon2);

    // Haversine formula
    double dlon = _lon2 - _lon1 ;
    double dlat = _lat2 - _lat1;
    double a = pow( sin(dlat/2),2)
        + cos( _lat1 ) * cos( _lat2)
            * pow( sin(dlon/2 ),2 );

    double c = 2 * asin( sqrt(a) );

    // radius of earth in kilometers
    double r = 6371*1000;

    // calculate the result
    return ( c * r ) ;
  }

  Future<bool> loadCoordinates() async {
    // flags the interrupt so another loadCoordinates method cannot be executed
    interrupt = true;

    coords = await locator.getLocation();

    double distance = calcDistance(
        double.parse( this._lat),
        double.parse( this._lon ),
        double.parse(coords['lat']!),
        double.parse( coords['lon']!)
    );

    print( 'stored latitude - ${this._lat}' );
    print( 'stored longitude - ${this._lon}' );
    print( 'new longitude - ${coords['lat']}' );
    print( 'new longitude - ${coords['lon']}' );
    print( 'distance - ${distance.toString()}' );

    print( distance < 5.0 );

    // checking if the co-ordinates are between a certain value
    if( distance <= 3.0 ){
      print("in range");
      rangeStatus = 'in range';
    }
    else{
      print('out of range');
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
                    title: Text( 'Set Current Location', ),
                    onTap: () {
                      // setting users current location as the destination location
                      this._lat = coords['lat']!;
                      this._lon = coords['lon']!;


                      print( this._lat );
                      print( this._lon );
                    },
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
                  ListTile(
                      title: Text(
                          'Scan'
                      ),
                      onTap: () async {
                        this.QRString = await FlutterBarcodeScanner.scanBarcode( '#fcba03', "cancel" , false , ScanMode.QR );
                        if( this.QRString == "-1" )
                          this.QRString = "No data!";
                        setState( () { });
                      }
                  ),
                  ListTile(
                      title: Text(
                          'Generate new barcode'
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BarCode(generatorString: FirebaseAuth.instance.currentUser!.uid ),
                            )
                        );
                      }
                  ),
                ],
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
                            Text( 'latitude - ${coords['lat']}', ),
                            Text( 'longitude - ${coords['lon']}', ),
                            Text( 'range status : $rangeStatus', ),
                            Text( 'User email - ${FirebaseAuth.instance.currentUser!.email}', ),
                            Text( 'User ID - ${FirebaseAuth.instance.currentUser!.uid}', ),
                            Text( 'Scanned Text - ${this.QRString}', ),
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
                            child: Text("Refresh"),
                          ),
                        ),
                      ),
                    ],
                  )
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
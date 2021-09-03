import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:test_app/utils/Location.dart';
import 'package:test_app/Templates/GradientContainer.dart';
import 'package:test_app/Templates/HomeScreenBuilder.dart';

import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import 'package:vector_math/vector_math.dart' as VMath;
import 'dart:math';

class ManageScan extends StatefulWidget {
  final userInfo;

  ManageScan({Key? key, required this.userInfo }) : super( key: key );

  @override
  _ManageScanState createState() => _ManageScanState();
}

class _ManageScanState extends State<ManageScan> {

  // coordinates stored in the database which represent the location where the QR code is installed
  String _lat="0.0";
  String _lon="0.0";

  late String email;
  late String rangeStatus;
  late Map<String, String> coords;
  Location locator = Location();
  bool interrupt = false;

  late String qrString='';


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

  Future<void> scanQR() async {
    // checking if the application is running in a browser, if so we cannot perform location related work so showing the message for this instance
    if( kIsWeb ) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Cannot perform location related tasks on webpage, \nPlease download the app to continue.."),
        ),
      );

      return;
    }

    this.qrString = await FlutterBarcodeScanner.scanBarcode( '#fcba03', "cancel" , false , ScanMode.QR );
    if( this.qrString == "-1" )
      this.qrString = "No data!";
    setState( () { });
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
              appbar: AppBar(
                title: Text( "Employee", ),
                actions: [
                  Container(
                    margin: EdgeInsets.symmetric( horizontal: 20.0 ),
                    child: IconButton(
                        icon: Icon(
                          Icons.qr_code_scanner_sharp,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          await scanQR();
                        }
                    ),
                  ),
                ],
              ),
              body: !kIsWeb ? GradientContainer(
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
                            Text( 'User email - ${ widget.userInfo['username']}', ),
                            Text( 'User ID - ${ widget.userInfo['UID']}', ),
                            Text( 'Scanned Text - ${this.qrString}', ),
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
              ) : Container(
                alignment: Alignment.center,
                child: Text("cannot load this page on web")
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
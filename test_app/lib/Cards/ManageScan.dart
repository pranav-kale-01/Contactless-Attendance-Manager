import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import 'package:test_app/utils/Location.dart';
import 'package:test_app/Templates/GradientContainer.dart';
import 'package:test_app/Templates/HomeScreenBuilder.dart';

import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import 'package:vector_math/vector_math.dart' as VMath;
import 'dart:math';

import 'package:http/http.dart' as http ;

class ManageScan extends StatefulWidget {
  final userInfo;

  ManageScan({Key? key, required this.userInfo }) : super( key: key );

  @override
  _ManageScanState createState() => _ManageScanState();
}

class _ManageScanState extends State<ManageScan> {

  // coordinates stored in the database which represent the location where the QR code is installed
  double _lat= 0.0;
  double _lon= 0.0;

  late String email;
  late String rangeStatus;
  late Map<String, String> coords;
  Location locator = Location();
  bool interrupt = false;

  late String qrString= '' ;


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

    // checking if the co-ordinates are between a certain value
    rangeStatus = "out of range";

    print( rangeStatus );

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

  Future<void> _insertScan( ) async {
    // getting the current Datetime
    String formattedDateTime = DateFormat('yyyy-MM-dd kk:mm:ss').format(DateTime.now()).toString();

    // print( widget.userInfo['UID'] );
    // print( this._lat.toString() + '-' + this._lon.toString() );
    // print( formattedDateTime );
    // print( coords['lat'].toString() + '-' + coords['lon'].toString() );

    //checking the user with same UId has scanned in the previous minute
    String url = "https://test-pranav-kale.000webhostapp.com/scripts/get.php?table=scans&condition&post&condition2&post2&custom=* FROM `scans` WHERE `scans`.`UID`=${widget.userInfo['UID']} AND `scans`.`time` LIKE '${formattedDateTime.substring(0, formattedDateTime.length - 2) }%'";

    http.Response response = await http.get( Uri.parse( url ) );

    if( response.body != '[]' ) {
      // this means that the user has scanned in the previous minute
      print("user already marked as attendee") ;
    }
    else {
      // inserting the scan data into the scans table
      url = "https://test-pranav-kale.000webhostapp.com/scripts/insert_scan.php?uid=${widget.userInfo['UID']}&coordinates=${this._lat.toString() + '-' + this._lon.toString() }&time=$formattedDateTime&scanner_location=${coords['lat'].toString() + '-' + coords['lon'].toString()}";

      response = await http.get( Uri.parse( url ) );

      print( response.body );

      if( response.body == 'true' ) {
        print('user attendance marked');
      }
      else {
        print('user attendance not marked');
      }
    }


  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
      body: HomeScreenBuilder(
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
                  // sets the data into qrString
                  await scanQR();

                  var list =  qrString.split(':');

                  this._lat = double.parse( list[0] ) ;
                  this._lon = double.parse( list[1] ) ;

                  // getting the current user location
                  await loadCoordinates( );

                  // calculating the distance of the device from the scanning location
                  double distance = calcDistance( this._lat , this._lon , double.parse( coords['lat']! )  , double.parse( coords['lon']! ) ) / 100;

                  if( distance < 5.0 ) {
                    // if the device is in the range then adding the scan to the scans list..
                    rangeStatus = "In Range" ;

                    // inserting the data into scans table
                    _insertScan( );
                  }
                  else {
                    print( distance );
                    rangeStatus = "Out of Range" ;
                  }
                }
              ),
            ),
          ],
        ),
        body: !kIsWeb ? Container(
          height: 700.0,
          width: 450.0 ,
          color: Colors.white,
          child: Column (
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                padding: EdgeInsets.all( 20.0 ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular( 20.0 ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset( 0.0, 5.0),
                      blurRadius: 10.0,
                    ),
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset( 2.0, 0.0),
                      blurRadius: 10.0,
                    ),
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset( -2.0, 0.0),
                      blurRadius: 10.0,
                    ),
                  ]
                ),
                child: Container(
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric( vertical: 20.0 ),
                        child: Text(
                            "Select You shift : ",
                            style: TextStyle(
                              fontSize: 30.0,
                              fontWeight: FontWeight.w300,
                            )
                        ),
                      ),
                      Container(
                        width: 300.0 ,
                        height: 50.0,
                        alignment: Alignment.center,
                        child: DropdownButton(
                          isExpanded: true,
                          value: 0 ,
                          items: [],
                        ),
                      ),
                    ]
                  ),
                ),
              ),
              Text(
                  "OR",
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w400,
                  ),
              ),
              Container(
                padding: EdgeInsets.symmetric( vertical: 20.0 ),
                margin: EdgeInsets.all( 10.0 ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular( 20.0 ),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset( 0.0 , 5.0 ),
                        blurRadius: 10.0,
                      ),
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset( 2.0 , 0.0 ),
                        blurRadius: 10.0,
                      ),
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset( -2.0 , 0.0 ),
                        blurRadius: 10.0,
                      ),
                    ]
                ),
                child: Column(
                  children: [
                    Text(
                        "Enter Start & End Time ",
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w300,
                        ),
                        textAlign: TextAlign.center,
                    ) ,
                    Container(
                      width: 400.0,
                      margin: EdgeInsets.symmetric( vertical: 20.0 ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            width: 140.0,
                            child: TextField(
                              decoration: InputDecoration(
                                filled: true,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.blue,
                                  ),
                                  borderRadius: BorderRadius.circular( 20.0 ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 140.0,
                            child: TextField(
                              decoration: InputDecoration(
                                filled: true,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.blue,
                                  ),
                                  borderRadius: BorderRadius.circular( 20.0 ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            child: Text(
                                "Start-Time",
                                style: TextStyle(
                                  fontSize: 18.0,
                                ),
                            ) ,
                          ),
                          Container(
                            alignment: Alignment.center,
                            child: Text(
                                "End-Time",
                                style: TextStyle(
                                  fontSize: 18.0,
                                )
                            ),
                          ),
                        ]
                    ),
                  ]
                ),
              ),
              MaterialButton(
                onPressed: () {
                  print("Done button was pressed ");
                },
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular( 20.0 ),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset( 2.0, 0.0 ),
                          blurRadius: 5.0,
                        ),
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset( -2.0, 0.0 ),
                          blurRadius: 5.0,
                        ),
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset( 0.0, 2.0 ),
                          blurRadius: 5.0,
                        ),
                      ]
                    ),
                    padding: EdgeInsets.symmetric( vertical: 10.0, horizontal: 35.0 ),
                    child: Text(
                        "Done",
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w400,
                        ),
                    )
                ),
              )
            ],
          ),
        ) : Container(
          alignment: Alignment.center,
          child: Text("cannot load this page on web")
        ),
      ),
      ),
    );
  }
}
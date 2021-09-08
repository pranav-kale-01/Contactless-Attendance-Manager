import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import 'package:test_app/utils/Location.dart';
import 'package:test_app/Templates/HomeScreenBuilder.dart';

import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import 'package:vector_math/vector_math.dart' as VMath;
import 'dart:math';

import 'package:http/http.dart' as http ;
import 'dart:convert';

import 'DateTimePicker.dart';

class ManageScan extends StatefulWidget {
  final userInfo;
  late String shiftID;

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
  late Map<String, String>? coords;
  Location locator = Location();
  bool interrupt = false;

  late String qrString= '' ;

  List<Widget> shifts = [];
  List<List> records = [];
  List<DropdownMenuItem<int>> _shifts = [ DropdownMenuItem(value:0, child: Text("") ) ];
  List<String> shiftIDs = [];
  int? index2;

  TextEditingController _timeController1 = TextEditingController();
  TextEditingController _timeController2 = TextEditingController();

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
  }

  Future<void> _insertScan( ) async {

    // checking if the qrString's organization id and the user's organization id matches
    if( qrString.substring(0 , qrString.length -1 ).split(":")[2] == widget.userInfo['org_id'] ) {
      // getting the current Datetime
      String formattedDateTime = DateFormat('yyyy-MM-dd kk:mm:ss').format(DateTime.now()).toString();

      //checking the user with same UId has scanned in the previous minute
      String url = "https://test-pranav-kale.000webhostapp.com/scripts/get.php?table=scans&condition&post&condition2&post2&custom=* FROM `scans` WHERE `scans`.`UID`=${widget.userInfo['UID']} AND `scans`.`time` LIKE '${formattedDateTime.substring(0, formattedDateTime.length - 2) }%'";

      http.Response response = await http.get( Uri.parse( url ) );

      if( response.body != '[]' ) {
        // this means that the user has scanned in the previous minute
        print("user already marked as attendee") ;
      }
      else {
        // inserting the scan data into the scans table
        url = "https://test-pranav-kale.000webhostapp.com/scripts/insert_scan.php?uid=${widget.userInfo['UID']}&coordinates=${this._lat.toString() + '-' + this._lon.toString() }&time=$formattedDateTime&scanner_location=${coords!['lat'].toString() + '-' + coords!['lon'].toString()}&start_time=${this._timeController1.text}&end_time=${this._timeController2.text}";

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
    else {
      print("Invalid QR Code ") ;
    }
  }

  Future<void> setBranches( bool addEmpty ) async {
    int i;

    // getting all the branches of the current organization
    String url = "https://test-pranav-kale.000webhostapp.com/scripts/get.php?table=shifts&condition=org_id&post=${widget.userInfo['org_id']}&condition2=&post2=&custom";

    http.Response response = await http.get( Uri.parse(url) );

    List<dynamic> jsonData = jsonDecode( response.body );

    // clearing the previous list
    _shifts.clear();
    shiftIDs.clear();

    // checking if there are no branches, then adding an empty branch
    if( jsonData.length == 0 ) {
      // adding a blank entry
      _shifts.add(
        DropdownMenuItem(
          value: 0,
          child: Text(''),
        ),
      ) ;

      return;
    }

    int index;

    if( addEmpty ) {
      index =1 ;

      _shifts.add(
          DropdownMenuItem(
            value: 0,
            child: Text(""),
          )
      );
      shiftIDs.add( '' );
    }
    else index =0;

    // adding the data to _branches
    for( i=0; i< jsonData.length ; i++ ) {
      Map<String,dynamic> data = jsonData[i];
      _shifts.add(
        DropdownMenuItem(
          value: index,
          child: Text( data['start_time'] + ' - ' + data['end_time'] ),
        ),
      ) ;

      shiftIDs.add( data['id'] );
      index+=1;
    }

    // setting the default value for branchID
    widget.shiftID = shiftIDs[0];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: setBranches( true ),
      builder: (context, snapshot ) {
        if( snapshot.connectionState == ConnectionState.done ) {
          return HomeScreenBuilder(
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

                          print( qrString ) ;

                          if( qrString != '-1' ) {
                            var list = qrString.split(':');

                            this._lat = double.parse( list[0] ) ;
                            this._lon = double.parse( list[1] ) ;

                            // getting the current user location
                            await loadCoordinates( );

                            // calculating the distance of the device from the scanning location
                            double distance = calcDistance( this._lat , this._lon , double.parse( coords!['lat']! )  , double.parse( coords!['lon']! ) ) / 100;

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
                        }
                    ),
                  ),
                ],
              ),
              body: !kIsWeb ? StatefulBuilder(
                builder: (context, setContentsState ) {
                  return Container(
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
                                    padding: EdgeInsets.zero,
                                    margin: EdgeInsets.zero,
                                    child: DropdownButton(
                                      isExpanded: true,
                                      value: index2,
                                      items: _shifts,
                                      onChanged: (int? value) {
                                        if( _shifts[value!].child.toString() == "Text(\"\")" ) {
                                          widget.shiftID = '';

                                          setContentsState( ( ) {
                                            this.index2 = 0;

                                            // assigning 00:00 to timeControllers
                                            this._timeController1.text = "00:00:0";
                                            this._timeController2.text = "00:00:0";
                                          } );

                                        }
                                        else {
                                          widget.shiftID = this.shiftIDs[value];

                                          setContentsState(() {
                                            this.index2 = this._shifts[value].value;

                                            // setting the timeControllers according to the shift selected
                                            String timeString = _shifts[index2!].child.toString();

                                            // the tempArr will hold [start_time, end_time ]
                                            var tempArr = timeString.substring(6, timeString.length - 2 ).split(" - ");

                                            // assigning the shift timings to timeControllers
                                            this._timeController1.text = tempArr[0] ;
                                            this._timeController2.text = tempArr[1] ;
                                          } );
                                        }

                                      },
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
                                        child: DateTimePicker(
                                            text: '',
                                            timeController: _timeController1,
                                            initialTime: _timeController1.text ,
                                            onTapInkWell: () {
                                              setContentsState(() {
                                                  this.index2 = 0;
                                              });
                                            }
                                        ),
                                      ),
                                      Container(
                                        width: 140.0,
                                        child: DateTimePicker(
                                          text: '',
                                          timeController: _timeController2 ,
                                          initialTime: _timeController2.text,
                                          onTapInkWell: () {
                                            setContentsState(() {
                                              this.index2 = 0;
                                            });
                                          }),
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
                          onPressed: () async {
                            // adding the data to scans table

                            print( _timeController1.text );
                            print( _timeController2.text );
                            print( widget.userInfo['org_id'] );
                            print( widget.userInfo['branch_id'] );

                            // checking if the user has scanned the qr-Code
                            if( this.coords == null ) {
                              print("scan the code");
                              return;
                            }

                            await _insertScan();
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
                  );
                }
              ) : Container(
                  alignment: Alignment.center,
                  child: Text("cannot load this page on web")
              ),
          );
        }
        else if( snapshot.hasError ) {
          return HomeScreenBuilder(
            body: Container(
              alignment: Alignment.center,
              child: Text( snapshot.error.toString() ),
            ),
          );
        }
        else {
          return HomeScreenBuilder(
            body: Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          );
        }
      }
    );
  }
}
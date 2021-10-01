import 'package:flutter/material.dart';
import 'package:test_app/utils/Location.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';


class AddScannerLocation extends StatefulWidget {
  final userInfo;
  late String branchID;
  int? index2;
  late int temp;

  TextEditingController descriptionController = TextEditingController();

  AddScannerLocation( {Key? key, required this.userInfo}) : super(key: key );

  @override
  _AddScannerLocationState createState() => _AddScannerLocationState();
}

class _AddScannerLocationState extends State<AddScannerLocation>{
  String scanStatus = 'not-scanning';
  late List<String> branchIDs = [];
  late List<DropdownMenuItem<int>> _branches = [];
  int pageNumber = 0;

  Future<void> setBranches( ) async {
    int i;

    // getting all the branches of the current organization
    String url = "https://test-pranav-kale.000webhostapp.com/scripts/get.php?table=branches&condition=org_id&post=${widget.userInfo['org_id']}&condition2=&post2=&custom";

    http.Response response = await http.get( Uri.parse(url) );
    List<dynamic> jsonData =  jsonDecode( response.body );

    // clearing the previous list
    _branches.clear();
    branchIDs.clear();

    // checking if there are no branches, then adding an empty branch
    if( jsonData.length == 0 ) {
      // adding a blank entry
      _branches.add(
        DropdownMenuItem(
          value: 0,
          child: Text(''),
        ),
      ) ;

      return;
    }

    // adding the data to _branches
    for( i=0; i< jsonData.length ; i++ ) {
      Map<String,dynamic> data = jsonData[i] ;

      _branches.add(
        DropdownMenuItem(
          value: i,
          child: Text( data['branch_name'] ),
        ),
      ) ;

      branchIDs.add( data['branch_id'] );
    }

    // setting the default values
    widget.index2=0 ;
    widget.branchID = branchIDs[0];
  }

  Future<void> _addScannerLocation(String lat,String lon) async {
    String qr = lat +  ":" + lon + ":" + widget.userInfo['org_id'];

    // checking the if the current user is a branch admin, if so taking the branch admin's branchID.
    if( widget.userInfo['authority'] == 'br-admin' ) {
      widget.temp= widget.userInfo['branch_id'] ;
    }

    // adding the scanLocation to database
    String url = "https://test-pranav-kale.000webhostapp.com/scripts/scanpoint.php?function=0&org_id=${widget.userInfo['org_id']}&branch_id=${widget.temp}&description=${widget.descriptionController.text}&qr=$qr&created='${widget.userInfo['username']}'&created_dt='${DateTime.now()}'&mod=NULL&mod_dt='00:00:00'";

    http.Response response = await http.get( Uri.parse( url ) );
    print( response.body );
  }

  Future<void> init( ) async {
    await setBranches( );
  }

  Column _Page1() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all( 5.0, ),
          child: Text(
            "Please Enter a Description for the scan location",
          ),
        ),
        Container(
            width: MediaQuery.of(context).size.width > 700 ? MediaQuery.of(context).size.width / 3 : MediaQuery.of(context).size.width,
            margin: EdgeInsets.only( bottom: 20.0, left: 10.0, right: 10.0),
            child: TextField(
              textDirection: TextDirection.ltr,
              controller: widget.descriptionController,
              onChanged: (String value) { },
            )
        ),
        // if the user is a organization admin, then providing a dropdown menu of branches to select from
        widget.userInfo['authority'] == 'org-admin' ? Container(
          padding: EdgeInsets.all(5.0),
          child: Text(
            "Select the Branch..",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
        ) : Container(),
        widget.userInfo['authority'] == 'org-admin' ? StatefulBuilder(
            builder: (BuildContext context, StateSetter setDropdownState ) {
              return DropdownButton(
                value:  widget.index2,
                items: _branches,
                onChanged: (int? value) {
                  if( value != null ) {
                    setDropdownState( () {
                      widget.branchID =  branchIDs[value];
                      widget.index2 = value;
                    });
                  }
                },
              );
            }
        ) : Container() ,
        SizedBox(
          height: 50.0,
        ),
        Container(
          child: MaterialButton(
            color: Colors.blueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular( 10.0, ),
            ),
            onPressed: () {
              this.pageNumber = 1;
              widget.temp = int.parse( widget.branchID );
              setState( () {} );
            },
            child: Text("Next"),
          ),
        ),
      ],
    );
  }

  Column _Page2() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(5.0),
          child: Text(
            "Please take the device to the scan point..",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 30.0 ),
          child: MaterialButton(
            color: Colors.tealAccent,
            onPressed: () async {
              setState( () {
                this.scanStatus = 'scanning';
              });

              // getting the current location
              Location locator = Location();

              try {
                dynamic coordinates =  await locator.getLocation();

                // adding new Scanner Location point
                await _addScannerLocation( coordinates['lat'] , coordinates['lon'] );

                setState( () {
                  this.scanStatus = 'done';
                });
              }
              catch( e ) {
                print( e.toString() );
              }
            },
            padding: EdgeInsets.symmetric(vertical: 5.0 , horizontal:20.0 ),
            child: Text(
              "Confirm",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context  ){
    return FutureBuilder(
      future: setBranches(),
      builder: (BuildContext context, snapshot ) {
        if( snapshot.connectionState == ConnectionState.done ) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            body: GestureDetector(
              onTap: ( ) {
                Navigator.of(context).pop();
              },
              child: Container(
                color: Colors.black38,
                child:
                GestureDetector(
                  onTap: () {},
                  child: StatefulBuilder(
                      builder : (BuildContext context, StateSetter setState ) {
                        if( this.scanStatus == 'not-scanning' ) {
                          return Container(
                            width: double.maxFinite,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0 ),
                              color: Colors.white,
                            ),
                            margin: EdgeInsets.only( top: 300.0 ),
                            child: pageNumber == 0 ? _Page1() : _Page2(),
                          );
                        }
                        else if( this.scanStatus == 'scanning' ) {
                          return Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0 ),
                              color: Colors.white,
                            ),
                            margin: EdgeInsets.only( top: 300.0 ),
                            child: CircularProgressIndicator(),
                          );
                        }
                        else {
                          return Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0 ),
                              color: Colors.white,
                            ),
                            margin: EdgeInsets.only( top: 300.0 ),
                            child: Text( "Scan point added "),
                          );
                        }
                      }
                  ),
                ),
              ),
            ),
          );
        }
        else {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.black38,
            body: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: GestureDetector(
                onTap: () { },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0 ),
                    color: Colors.white,
                  ),
                  margin: EdgeInsets.only( top: 300.0 ),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          );
        }
      }
    );
  }
}
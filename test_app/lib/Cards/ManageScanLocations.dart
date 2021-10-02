import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:test_app/Cards/ManageBranch.dart';
import 'package:test_app/Cards/ManageBranchAdmins.dart';
import 'package:test_app/Cards/ManageEmployee.dart';
import 'package:test_app/Cards/AddScannerLocation.dart';
import 'package:test_app/Cards/ManageShifts.dart';
import 'package:test_app/Screens/SignUp.dart';
import 'package:test_app/Templates/GenerateScreen.dart';
import 'package:test_app/Templates/GradientContainer.dart';
import 'package:test_app/Templates/HomeScreenBuilder.dart';
import 'package:test_app/Templates/GenerateScreenWeb.dart';
import 'package:test_app/utils/CredentialController.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class ManageScanLocations extends StatefulWidget {
  final userInfo ;
  List< String > branchIDs = [];
  late String branchID;

  ManageScanLocations( {Key? key, required this.userInfo }) : super(key : key ) ;

  @override
  _ManageScanLocationsState createState() => _ManageScanLocationsState();
}

class _ManageScanLocationsState extends State<ManageScanLocations> {
  List<Widget> scanPoints = [];
  List< Map<String,dynamic> > _displayData = [];

  List< DropdownMenuItem<int> > _branches = [] ;

  int? index;

  Map<String, dynamic> header = {
    'org_id': 'Organization ID',
    'branch_id': 'BRANCH ID',
    'qr': 'ADDRESS',
    'branch_name': 'Branch Name',
    'description': 'Description',
    'address' : 'address'
  };

  Future<void> init() async {
    await _setBranches();
    await _getScanPoints();
  }

  Future<bool> _getScanPoints( ) async {
    String url = "https://test-pranav-kale.000webhostapp.com/scripts/get.php?table=scan_locations&condition&post&condition2&post2&custom= `scan_locations`.`org_id`, `scan_locations`.`branch_id`, `scan_locations`.`description`, `scan_locations`.`qr`, `branches`.`branch_name`, `branches`.`address` FROM `scan_locations` LEFT JOIN `branches` ON `branches`.`branch_id` = `scan_locations`.`branch_id` WHERE `scan_locations`.`org_id`=${widget.userInfo['org_id']}";
    http.Response response = await http.get(  Uri.parse( url ) );
    List<dynamic> jsonData = jsonDecode( response.body );

    // clearing the scanPoints list
    scanPoints.clear();
    _displayData.clear();

    // adding the scan points to the list of scanPoints
    for( int i=0 ; i< jsonData.length ; i++ ) {
      Map<String, dynamic> data = jsonData[i];

      _displayData.add( data );
      scanPoints.add( containerBuilder( data, true, true ) );
    }

    return true;
  }

  void  _resetScanPointsList( ) {
    // clearing the scanPoints list
    scanPoints.clear();

    // iterating over the _displayData list and selecting only the required organization
    for( var i in _displayData ) {
      if( i['branch_id'] == widget.branchID || widget.branchID == '') {
        scanPoints.add( containerBuilder( i , true, true  ) );
      }
    }
  }

  Future<void> _setBranches() async {
    int i;

    // getting all the branches of the current organization
    String url = "https://test-pranav-kale.000webhostapp.com/scripts/get.php?table=branches&condition=org_id&post=${widget.userInfo['org_id']}&condition2=&post2=&custom";
    http.Response response = await http.get(Uri.parse(url));
    List<dynamic> jsonData = jsonDecode(response.body);

    // clearing the previous list
    _branches.clear();
    widget.branchIDs.clear();

    // checking if there are no branches, then adding an empty branch
    if (jsonData.length == 0) {
      // adding a blank entry
      _branches.add(
        DropdownMenuItem(
          value: 0,
          child: Text(''),
        ),
      );
      return;
    }

    int index=1;

    _branches.add(
      DropdownMenuItem(
        value: 0,
        child: Text("All"),
      )
    );

    // adding the data to _branches
    for (i = 0; i < jsonData.length; i++) {
      Map<String, dynamic> data = jsonData[i];

      _branches.add(
        DropdownMenuItem(
          value: index,
          child: Text(data['branch_name']),
        ),
      );

      widget.branchIDs.add(data['branch_id']);
      index+=1;
    }

    // setting the default values
    this.index = 0;
    widget.branchID = widget.branchIDs[0];
  }

  Future<void> _editScanPoints( String qr, String description ) async {
    TextEditingController descriptionController = TextEditingController( text: description );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: "Description",
                ),
              ),
            ),
            Container(
              child: MaterialButton(
                onPressed: () async {
                  // saving changes
                  String url = "https://test-pranav-kale.000webhostapp.com/scripts/scanpoint.php?function=2&qr=$qr&desc=${descriptionController.text}&mod='${widget.userInfo['username']}'&mod_dt='${DateTime.now()}'";
                  await http.get( Uri.parse( url ) );

                  setState( () {
                    Navigator.of(context).pop();
                  } );
                },
                child: Text("Save"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> removeScanPoint( String qr) async {
    String url = "https://test-pranav-kale.000webhostapp.com/scripts/scanpoint.php?function=1&qr=$qr";
    await http.get( Uri.parse( url ) );

    setState(() {
      _getScanPoints( );
    });
  }

  Widget containerBuilder( var data, bool addQRCreate,bool addDelete ) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric( horizontal: MediaQuery.of(context).size.width > 725 ? 7.0 : 0.0, vertical: 6.0 ),
      padding: EdgeInsets.symmetric( vertical: 15.0 ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular( 20.0 ),
        color: Colors.white,
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
        ],
      ),
      child: Container(
        width: MediaQuery.of(context).size.width > 725 ? MediaQuery.of(context).size.width / 1.5  : MediaQuery.of(context).size.width,
        margin: EdgeInsets.only( top: 20.0, ),
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width > 725 ? MediaQuery.of(context).size.width / 2 : MediaQuery.of(context).size.width,
              child: Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width > 725 ? MediaQuery.of(context).size.width / 4 : MediaQuery.of(context).size.width/2,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          // color: Colors.red,
                          margin: EdgeInsets.symmetric( vertical: 4.0 ),
                          child: Text( this.header['branch_name'].toString() ),
                        ),
                        Container(
                          // color: Colors.red,
                          margin: EdgeInsets.symmetric( vertical: 4.0 ),
                          child: Text( this.header['description'] ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric( vertical: 4.0, ),
                          child: Text( this.header['address'] ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width > 725 ? MediaQuery.of(context).size.width / 4 : MediaQuery.of(context).size.width/2,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.symmetric( vertical: 4.0 ),
                          child: Text(
                              data['branch_name'],
                              style: TextStyle(
                                fontSize: 22.0,
                              ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.symmetric( vertical: 4.0 ),
                          child: Text(
                            data['description'] == null ? '-' : data['description'],
                            textAlign: TextAlign.start,
                          ),
                        ),
                        Container(
                          height: 15.0,
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.symmetric( vertical: 4.0, ),
                          child: Text(
                            data['address'],
                            textAlign: TextAlign.start,
                          )
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric( vertical: 2.0 ),
              width: MediaQuery.of(context).size.width > 725 ? MediaQuery.of(context).size.width / 2 : MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MaterialButton(
                    onPressed: () async {
                      await _editScanPoints( data['qr'], data['description']  );
                    },
                    child: Container(
                      padding: EdgeInsets.all( 5.0 ),
                      child: Icon(
                        Icons.edit,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  addQRCreate? MaterialButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          opaque: false,
                          pageBuilder: (context, _ , __ ) => kIsWeb? GenerateScreenWeb(qrString: data['qr']) : GenerateScreen( qrString: data['qr'] ),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all( 5.0 ),
                      child: Icon(
                        Icons.qr_code_scanner,
                      ),
                    ),
                  ) : Container( ),
                  addDelete ? MaterialButton(
                      onPressed: () {
                        // delete branch
                        removeScanPoint( data['qr'] );

                        setState(() { });
                      },
                      child: Container(
                        padding: EdgeInsets.all( 5.0, ),
                        child: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      )
                  ) : Container(
                    width: 205.0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container scanLocationViewBuilder( ) {
    return Container(
      child: StatefulBuilder(
        builder: (context, setListViewState ) {
          return Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                widget.userInfo['authority'] == 'org-admin' ? StatefulBuilder(
                    builder: (context , setDropdownState ) {
                      return DropdownButton(
                          value: index,
                          items: _branches,
                          onChanged: (int? value ){
                            if( value != null ) {
                              setDropdownState( () {
                                if( value == 0  ) {
                                  widget.branchID = '';
                                  this.index = 0;
                                }
                                else {
                                  widget.branchID = widget.branchIDs[value-1];
                                  this.index = value;
                                }
                              });

                              setListViewState( () {
                                _resetScanPointsList();
                              });
                            }
                          }
                      );
                    }
                ) : Container(),
                Container(
                    height: MediaQuery.of(context).size.height - 128.0 ,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child : Container(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            setState( () {} );
                          },
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: scanPoints,
                            ),
                          ),
                        ),
                      ),
                    )
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  @override
  Widget build( BuildContext context ) {
    return FutureBuilder(
      future: init(),
      builder: (context, snapshot ) {
        if(snapshot.connectionState == ConnectionState.done ) {
          return HomeScreenBuilder(
            appbar: AppBar(
              iconTheme: IconThemeData(color: Colors.blueAccent),
              elevation: 0,
              backgroundColor: Colors.transparent,
              actions: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
                  child: IconButton(
                    icon: Icon(
                      Icons.add,
                      color: Colors.blueAccent,
                    ),
                    onPressed: () async {
                      // redirecting to the AddScannerLocation Page
                      await Navigator.of(context).push(
                        PageRouteBuilder(
                          opaque: false,
                          pageBuilder: (context, _ , __ ) => AddScannerLocation( userInfo: widget.userInfo, ),
                        ),
                      );

                      setState( () {} );
                    },
                  ),
                )
              ],
              title: Text(
                  "Scan Locations",
                  style: TextStyle(
                    color: Colors.blueAccent,
                  )
              ),
            ),
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
                widget.userInfo['authority'] == 'org-admin' ?
                ListTile(
                  title: Text( 'Manage branches', ),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewBranch( context: context, setState: setState, userInfo: widget.userInfo ),
                      ),
                    );
                  },
                ) : Container(),
                widget.userInfo['authority'] == 'org-admin'?
                ListTile(
                  title: Text( 'Manage Branch Admins', ),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ManageBranchAdmins( context: context, setState: setState,  userInfo: widget.userInfo ),
                      ),
                    );
                  },
                ) : Container(),
                ListTile(
                  title: Text( 'Manage Employees', ),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ManageEmployee( setState1:  setState, context: context , userInfo: widget.userInfo, ),
                      ),
                    );
                  },
                ),
                ListTile(
                    title: Text("Manage Scan Locations"),
                    onTap: () {
                      // redirecting the user to ManageScanLocations Page
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManageScanLocations( userInfo: widget.userInfo ),
                        ),
                      );
                    }
                ),
                ListTile(
                  title: Text("Manage Shifts"),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ManageShifts( userInfo: widget.userInfo ),
                      ),
                    );
                  }
                ),
                ListTile(
                  title: Text( 'Sign Out', ),
                  onTap: () async {
                    // Signing the User Out
                    if( !kIsWeb) {
                      await CredentialController.clearFile();
                    }

                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SignUp()
                        ),
                            (Route<dynamic> route) => false
                    );
                  },
                ),
              ],
            ),
            body: scanLocationViewBuilder(),
          );
        }
        else {
          return HomeScreenBuilder(
            appbar: AppBar(
              iconTheme: IconThemeData(color: Colors.blueAccent),
              elevation: 0,
              backgroundColor: Colors.transparent,
            ),
              body: Center(
                child: CircularProgressIndicator(),
              )
          );
        }
      }
    );
  }
}
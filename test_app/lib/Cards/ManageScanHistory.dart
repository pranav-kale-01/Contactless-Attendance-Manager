import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:test_app/Cards/ManageBranch.dart';
import 'package:test_app/Cards/ManageBranchAdmins.dart';
import 'package:test_app/Cards/ManageEmployee.dart';
import 'package:test_app/Cards/ManageScanLocations.dart';
import 'package:test_app/Cards/ManageShifts.dart';
import 'package:test_app/Cards/DateTimePicker.dart';
import 'package:test_app/Screens/SignUp.dart';
import 'package:test_app/Templates/HomeScreenBuilder.dart';
import 'package:test_app/utils/CredentialController.dart';
import 'package:test_app/utils/Location.dart';

import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class  ManageScanHistory extends StatefulWidget {
  final userInfo;
  bool showHamMenu = true;
  late String branchID;
  final uid;

  bool changedFromDropdown = false;
  bool showAllValue = true;


  ManageScanHistory( {Key? key, required this.userInfo, required this.uid, showHamMenu } ) : super( key: key ) {
    if( showHamMenu != null ){
      this.showHamMenu = showHamMenu ;
    }
  }

  @override
  ManageScanHistoryState createState() => ManageScanHistoryState();
}

class ManageScanHistoryState extends State<ManageScanHistory> {
  List<Widget> employees = [];
  List<List> records = [];
  int? index2;

  TextEditingController _timeController1 = TextEditingController();
  TextEditingController _timeController2 = TextEditingController();

  DateTime selectedDate1 = DateTime.now();
  DateTime selectedDate2 = DateTime.now();

  bool getScanHistory = true;

  Map<String, String> header = {
    'UID' : "User ID",
    'coordinates' : "Coordinates",
    'time' : "Scan Time",
    'start_time' : "Shift Start Time",
    'end_time' : "Shift End Time",
    'description' : "Description",
    'branch_name' : "Branch Name",
  };

  Future<void> init( ) async {
    if( getScanHistory ) {
      await getEmployeesScanHistory(widget.uid);
    }
  }

  Future<void> _insertTimeDetails( String id, String start_time, String end_time ) async {
    // setting up the TextEditingControllers with the provided values
    _timeController1.text = start_time ;
    _timeController2.text = end_time ;

    showDialog(
        context: context,
        builder: (BuildContext context ) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.symmetric( vertical: 10.0 ),
                  child: DateTimePicker( text: "Start Time" , timeController: _timeController1, initialTime: start_time, ),
                ),
                DateTimePicker( text: "End Time" , timeController: _timeController2, initialTime: end_time, ),
                Container(
                  child: MaterialButton(
                    color: Colors.blue,
                    onPressed: () async {
                      // checking if the startTime == endTime
                      if( _timeController1.text == _timeController2.text ) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context ) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                content: Text("Shift Start Time and End Time cannot be same"),
                              );
                            }
                        );

                        // popping the Dialog after 3 seconds
                        Future.delayed( Duration( seconds: 3 ), () => Navigator.pop(context) );
                      }
                      else {
                        // getting current time
                        DateTime currentTime = DateTime.now();

                        // getting current location
                        Location locator = Location();
                        Map<String, dynamic> coords = await locator.getLocation();
                        String currentLocation = coords['lat'].toString() + '-' + coords['lon'].toString() ;

                        // validation succeeded, inserting the values
                        String url = "https://test-pranav-kale.000webhostapp.com/scripts/scan.php?function=0&uid=$id&coordinates=$currentLocation&time=$currentTime&scanner_location=-&start_time=${_timeController1.text}&end_time=${_timeController2.text}";

                        http.Response response = await http.get( Uri.parse( url ) );

                        // popping the current Window
                        Navigator.of( context ).pop();

                        // showing the dialog according to the operation
                        showDialog(
                            context: context,
                            builder: (BuildContext context ) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                content: Text( response.body == 'true' ? "Entry Added" : "Something Went Wrong" ),
                              );
                            }
                        );

                        setState(() {
                          this.index2 =0 ;
                        });
                      }
                    },
                    child: Text("Ok"),
                  ),
                ),
              ],
            ),
          );
        }
    );
  }

  Future<void> _deleteTimeDetails( String id , String time ) async {
    String url = "https://test-pranav-kale.000webhostapp.com/scripts/scan.php?function=1&id=$id&time=$time";
    http.Response response = await http.get( Uri.parse( url ) );

    if( response.body != '1' ) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text("Something Went Wrong"),
        ),
      );
    }
    else{
      // reloading the screen
      setState( () {} );
    }
  }

  Future<void> _editTimeDetails ( String start_time, String end_time, String id, String time ) async {
    // setting up the TextEditingControllers with the provided values
    _timeController1.text = start_time ;
    _timeController2.text = end_time ;

    showDialog(
        context: context,
        builder: (BuildContext context ) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.symmetric( vertical: 10.0 ),
                  child: DateTimePicker( text: "Start Time" , timeController: _timeController1, initialTime: start_time, ),
                ),
                DateTimePicker( text: "End Time" , timeController: _timeController2, initialTime: end_time, ),
                Container(
                  child: MaterialButton(
                    color: Colors.blue,
                    onPressed: () async {
                      // checking if the startTime == endTime
                      if( _timeController1.text == _timeController2.text ) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context ) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                content: Text("Shift Start Time and End Time cannot be same"),
                              );
                            }
                        );

                        // popping the Dialog after 3 seconds
                        Future.delayed( Duration( seconds: 3 ), () => Navigator.pop(context) );
                      }
                      else {
                        String url = "https://test-pranav-kale.000webhostapp.com/scripts/scan.php?function=2&id=$id&time=$time&s_time='${_timeController1.text}'&e_time='${_timeController2.text}'&mod='${widget.userInfo['username']}'&mod_dt='${DateTime.now()}'";
                        http.Response response = await http.get( Uri.parse( url ) );

                        if( response.body != '1' ) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              content: Text("Something Went Wrong"),
                            ),
                          );
                        }
                        else {
                          // removing the popup
                          Navigator.pop(context);

                          // reloading the page
                          setState( () {} );
                        }
                      }
                    },
                    child: Text("Ok"),
                  ),
                ),
              ],
            ),
          );
        }
    );
  }

  Future<void> getEmployeesScanHistory( String uid ) async {
    String url;

    url = "https://test-pranav-kale.000webhostapp.com/scripts/get.php?table=users&condition=&post=&condition2=&post2=&custom= `scans`.`UID`, `scans`.`coordinates`, `scans`.`time`, `scans`.`start_time`, `scans`.`end_time`, `scan_locations`.`description`, `branches`.`branch_name` FROM `scans` INNER JOIN `scan_locations` ON ( SELECT SUBSTRING(`scan_locations`.`qr`, LENGTH(`scan_locations`.`qr`)*-1 , LENGTH(`scan_locations`.`qr`)-4 ) AS Scanner_location ) = `scans`.`scanner_location` LEFT JOIN `branches` ON `branches`.`branch_id` = `scan_locations`.`branch_id` WHERE `scans`.`UID` = $uid";
    http.Response response = await http.get( Uri.parse( url ) );
    List<dynamic> jsonData = jsonDecode( response.body );

    if( response.body == '') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text("Failed to Load"),
        ),
      );
    }
    else {
      // clearing the previous list of Employees
      employees.clear();
      records.clear();

      for( int i=0 ; i < jsonData.length ; i++ ) {
        Map<String,dynamic> data = jsonData[i];

        employees.add( containerBuilder( data, true , true  ) );
        records.add( [ data['UID'], data['coordinates'], data['time'], data['scanner_location'], data['start_time'], data['end_time'], data['description'], data['branch_name'] ] );
      }
    }
  }

  Widget containerBuilder( var data, bool addEdit,bool addDelete) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric( horizontal: MediaQuery.of(context).size.width > 725 ? 7.0 : 0.0, vertical: 6.0 ),
      padding: EdgeInsets.symmetric( vertical: 5.0 ),
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
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only( top: 25.0, ),
              width: MediaQuery.of(context).size.width > 725 ? MediaQuery.of(context).size.width / 2 : MediaQuery.of(context).size.width,
              child: Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width > 725 ? MediaQuery.of(context).size.width / 4 : MediaQuery.of(context).size.width/2,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                            margin: EdgeInsets.symmetric( vertical: 6.0 ),
                            child: Text( this.header['branch_name'].toString() ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric( vertical: 6.0 ),
                            child: Text( this.header['description'].toString() ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric( vertical: 6.0 ),
                            child: Text( this.header['coordinates'].toString() ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric( vertical: 6.0 ),
                            child: Text( this.header['time'].toString() ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric( vertical: 6.0 ),
                            child: Text( this.header['start_time'].toString() ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric( vertical: 6.0 ),
                            child: Text( this.header['end_time'].toString() ),
                          ),
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
                          // color: Colors.red,
                          margin: EdgeInsets.symmetric( vertical: 6.0 ),
                          child: Text( data['branch_name'] ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          // color: Colors.red,
                          margin: EdgeInsets.symmetric( vertical: 6.0 ),
                          child: Text( data['description'] ),
                        ),
                        Container(
                          height: 16.0,
                          alignment: Alignment.centerLeft,
                          // color: Colors.red,
                          margin: EdgeInsets.symmetric( vertical: 6.0 ),
                          child: Text( data['coordinates'] )
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          // color: Colors.red,
                          margin: EdgeInsets.symmetric( vertical: 6.0 ),
                          child: Text( data['time'] ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          // color: Colors.red,
                          margin: EdgeInsets.symmetric( vertical: 6.0 ),
                          child: Text( data['start_time'] ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          // color: Colors.red,
                          margin: EdgeInsets.symmetric( vertical: 6.0 ),
                          child: Text( data['end_time'] ),
                        ),
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
                  addEdit? MaterialButton(
                      onPressed: () async {
                        await _editTimeDetails( data['start_time'] , data['end_time'] , data['UID'], data['time'] );
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 20.0 ),
                        padding: EdgeInsets.all( 10.0 ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              Icons.edit,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      )
                  ) : Container(
                    width: 205.0,
                  ),
                  addDelete ?  MaterialButton(
                      onPressed: ()  async {
                        await _deleteTimeDetails( data['UID'], data['time'] );
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 20.0 ),
                        padding: EdgeInsets.all( 10.0 ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                          ],
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

  Future<void> _selectDate1(BuildContext context ) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate1,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101)
    );

    if (picked != null && picked != selectedDate1) {
      selectedDate1 = picked;

      String _selectedDate1 = DateFormat("yyyy-M-dd").format(selectedDate1);
      String _selectedDate2 = DateFormat("yyyy-M-dd").format(selectedDate2);

      // getting all the scans from the start date to end date
      String url;
      url = "https://test-pranav-kale.000webhostapp.com/scripts/get.php?table=users&condition=&post=&condition2=&post2=&custom= `scans`.`UID`, `scans`.`coordinates`, `scans`.`time`, `scans`.`start_time`, `scans`.`end_time`, `scan_locations`.`description`, `branches`.`branch_name` FROM `scans` INNER JOIN `scan_locations` ON ( SELECT SUBSTRING(`scan_locations`.`qr`, LENGTH(`scan_locations`.`qr`)*-1 , LENGTH(`scan_locations`.`qr`)-4 ) AS Scanner_location ) = `scans`.`scanner_location` LEFT JOIN `branches` ON `branches`.`branch_id` = `scan_locations`.`branch_id` WHERE `scans`.`UID` = ${widget.uid} AND `scans`.`time` > '${_selectedDate1}' AND `scans`.`time` < '${_selectedDate2}' OR `scans`.`time` LIKE '$_selectedDate1%' OR `scans`.`time` LIKE '$_selectedDate2%'";
      http.Response response = await http.get( Uri.parse( url ) );

      List<dynamic> jsonData = jsonDecode( response.body );

      if( response.body == '') {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Text("Failed to Load"),
          ),
        );
      }
      else {
        // clearing the previous list of Employees
        employees.clear();
        records.clear();

        for( int i=0 ; i < jsonData.length ; i++ ) {
          Map<String,dynamic> data = jsonData[i];

          employees.add( containerBuilder( data, true , true  ) );
          records.add( [ data['UID'], data['coordinates'], data['time'], data['scanner_location'], data['start_time'], data['end_time'], data['description'], data['branch_name'] ] );
        }
      }

      setState(() {
        getScanHistory = false;
      });
    }
  }

  Future<void> _selectDate2(BuildContext context ) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate2,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101)
    );

    if (picked != null && picked != selectedDate1) {
      selectedDate2 = picked;

      String _selectedDate1 = DateFormat("yyyy-MM-dd").format(selectedDate1);
      String _selectedDate2 = DateFormat("yyyy-MM-dd").format(selectedDate2);

      // getting all the scans from the start date to end date
      String url;

      url = "https://test-pranav-kale.000webhostapp.com/scripts/get.php?table=users&condition=&post=&condition2=&post2=&custom= `scans`.`UID`, `scans`.`coordinates`, `scans`.`time`, `scans`.`start_time`, `scans`.`end_time`, `scan_locations`.`description`, `branches`.`branch_name` FROM `scans` INNER JOIN `scan_locations` ON ( SELECT SUBSTRING(`scan_locations`.`qr`, LENGTH(`scan_locations`.`qr`)*-1 , LENGTH(`scan_locations`.`qr`)-4 ) AS Scanner_location ) = `scans`.`scanner_location` LEFT JOIN `branches` ON `branches`.`branch_id` = `scan_locations`.`branch_id` WHERE `scans`.`UID` = ${widget.uid} AND `scans`.`time` > '${_selectedDate1}' AND `scans`.`time` < '${_selectedDate2}' OR `scans`.`time` LIKE '$_selectedDate1%' OR `scans`.`time` LIKE '$_selectedDate2%'";
      http.Response response = await http.get( Uri.parse( url ) );
      List<dynamic> jsonData = jsonDecode( response.body );

      if( response.body == '') {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Text("Failed to Load"),
          ),
        );
      }
      else {
        // clearing the previous list of Employees
        employees.clear();
        records.clear();

        for( int i=0 ; i < jsonData.length ; i++ ) {
          Map<String,dynamic> data = jsonData[i];

          employees.add( containerBuilder( data, true , true  ) );
          records.add( [ data['UID'], data['coordinates'], data['time'], data['scanner_location'], data['start_time'], data['end_time'], data['description'], data['branch_name'] ] );
        }
      }

      setState(() {
        getScanHistory = false;
      });
    }
  }

  Container _employeeViewBuilder(){
    return Container(
      child: Stack(
        children: [
          Container(
            color: Colors.white,
            alignment: Alignment.center,
            child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState1 ) {
                  return Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width > 725 ? MediaQuery.of(context).size.width / 1.5  : MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only( top: 50.0, ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text( 'From' ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: ElevatedButton(
                                    onPressed: () => _selectDate1(context ),
                                    child: Text("${selectedDate1.toLocal()}".split(' ')[0]),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text( 'To' ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: ElevatedButton(
                                    onPressed: () => _selectDate2(context),
                                    child: Text("${selectedDate2.toLocal()}".split(' ')[0]),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                          height: MediaQuery.of(context).size.height - 86,
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
                                    children: employees,
                                  ),
                                ),
                              ),
                            ),
                          )
                      ),
                    ],
                  );
                }
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: EdgeInsets.all( 5.0 ),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular( 10.0 ),
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.blue,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all( 5.0 ),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular( 10.0 ),
                ),
                child: IconButton(
                  onPressed: () async {
                    await _insertTimeDetails( widget.uid , "00:00:00" , "00:00:00" );
                  },
                  icon: Icon(
                    Icons.add,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build( BuildContext context ) {
    return FutureBuilder(
      future: this.init(),
      builder: ( context, snapshot ) {
        if( snapshot.connectionState == ConnectionState.done ) {
          return HomeScreenBuilder(
            listView: widget.showHamMenu ? ListView(
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
                // checking if the user is Organization Admin
                widget.userInfo['authority'] == 'org-admin' ? ListTile(
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
                widget.userInfo['authority'] == 'org-admin' ? ListTile(
                  title: Text( 'Manage Branch Admins', ),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ManageBranchAdmins( context: context, setState: setState, userInfo: widget.userInfo, ),
                      ),
                    );
                  },
                ) : Container(),
                ListTile(
                  title: Text( 'Manage Employees', ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context)=> ManageEmployee( context: context, setState1: setState, userInfo: widget.userInfo,),
                        )
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
                    title: Text( 'Manage Shifts' ),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ManageShifts( userInfo: widget.userInfo )
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
            ) : null ,
            appbar: null,
            body: SafeArea(
              child: Container(
                alignment: Alignment.center,
                child: _employeeViewBuilder( ),
              ),
            ),
          );
        }
        else if( snapshot.hasError ) {
          return HomeScreenBuilder(
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
              ]
            ),
            body: Container(
              alignment: Alignment.center,
              child: Text( snapshot.error.toString() ),
            ),
          );
        }
        else {
          return HomeScreenBuilder(
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
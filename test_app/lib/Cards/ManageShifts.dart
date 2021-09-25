import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:test_app/Screens/SignUp.dart';
import 'package:test_app/Templates/HomeScreenBuilder.dart';
import 'package:test_app/utils/CredentialController.dart';

import 'package:test_app/Cards/ManageBranch.dart';
import 'package:test_app/Cards/ManageBranchAdmins.dart';
import 'package:test_app/Cards/ManageEmployee.dart';
import 'package:test_app/Cards/ManageScanLocations.dart';
import 'package:test_app/Cards/DateTimePicker.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'ManageScanHistory.dart';

class ManageShifts extends StatefulWidget {
  final userInfo;
  late String branchID;

  ManageShifts( {Key? key, required this.userInfo }) : super( key: key );

  @override
  _ManageShiftsState createState() => _ManageShiftsState( );
}

class _ManageShiftsState extends State<ManageShifts> {
  List<Widget> shifts = [];
  List<List> records = [];
  List<DropdownMenuItem<int>> _branches = [ DropdownMenuItem(value:0, child: Text("All") ) ];
  List<String> branchIDs = [];

  late String username;
  late String password;

  int? index2;

  // creating required controllers
  TextEditingController _timeController1 =  TextEditingController();
  TextEditingController _timeController2 =  TextEditingController();

  Map<String,dynamic> header = {
    'id' : "ID",
    'start_time' : "Start Time",
    'end_time' : "End Time",
    'org_id' : "Organization ID",
    'branch_id' : "Branch ID",
    'branch_name' : "Branch Name",
  };


  Future<void> init( ) async {
    // checking if the current user is a Organization admin, if not then setting the branchID tu the Branch Admins associated branch
    if( widget.userInfo['authority'] == 'br-admin') {
      widget.branchID = widget.userInfo['branch_id'] ;
    }

    // initializing the branches
    await setBranches( true );

    // initializing the shifts list
    await getShifts();
  }

  Future<void> setBranches( bool addEmpty ) async {
    int i;

    // getting all the branches of the current organization
    String url = "https://test-pranav-kale.000webhostapp.com/scripts/get.php?table=branches&condition=org_id&post=${widget.userInfo['org_id']}&condition2=&post2=&custom";

    http.Response response = await http.get( Uri.parse(url) );

    List<dynamic> jsonData = jsonDecode( response.body );

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

    int index;

    if( addEmpty ) {
      index =1 ;

      _branches.add(
          DropdownMenuItem(
            value: 0,
            child: Text("All"),
          )
      );
      branchIDs.add( '' );
    }
    else index =0;

    // adding the data to _branches
    for( i=0; i< jsonData.length ; i++ ) {
      Map<String,dynamic> data = jsonData[i];
      _branches.add(
        DropdownMenuItem(
          value: index,
          child: Text( data['branch_name'] ),
        ),
      ) ;

      branchIDs.add( data['branch_id'] );
      index+=1;
    }

    // setting the default value for branchID
    widget.branchID = branchIDs[0];
  }

  Future<void> getShifts() async {
    // checking if the user currently signed in is a branch admin, if it is then changing the branch ID to branchID of the branchAdmin
    if( widget.userInfo['authority'] == 'br-admin') {
      widget.branchID = widget.userInfo['branch_id'];
    }

    String url;

    // checking if the branch ID is empty, if empty then showing all the employees
    if( widget.branchID == '' ) {
      url = "https://test-pranav-kale.000webhostapp.com/scripts/get.php?table=users&condition=&post=&condition2=&post2=&custom= `shifts`.`id`, `shifts`.`start_time`, `shifts`.`end_time`, `shifts`.`org_id`, `shifts`.`branch_id`, `branches`.`branch_name` FROM `shifts` LEFT JOIN `branches` ON `branches`.`branch_id` = `shifts`.`branch_id` WHERE `shifts`.`org_id` = ${widget.userInfo['org_id']}";
    }
    else {
      url = "https://test-pranav-kale.000webhostapp.com/scripts/get.php?table=users&condition=&post=&condition2=&post2=&custom= `shifts`.`id`, `shifts`.`start_time`, `shifts`.`end_time`, `shifts`.`org_id`, `shifts`.`branch_id`, `branches`.`branch_name` FROM `shifts` LEFT JOIN `branches` ON `branches`.`branch_id` = `shifts`.`branch_id` WHERE `shifts`.`org_id` = ${widget.userInfo['org_id']} AND `shifts`.`branch_id`=${widget.branchID}";
    }

    http.Response response = await http.get( Uri.parse( url ) );

    print( response.body );

    List<dynamic> jsonData = jsonDecode( response.body );

    if( response.body == '') {
      print('failed to load');
    }
    else {
      // clearing the previous list of Employees
      shifts.clear();
      records.clear();

      for( int i=0 ; i < jsonData.length ; i++ ) {
        Map<String,dynamic> data = jsonData[i];
        shifts.add( containerBuilder( data, true , true ) );
        records.add( [data['id'], data['start_time'], data['end_time'], data['org_id'], data['branch_id'], data['branch_name']] );
      }
    }
  }

  Future<void> _insertShift( ) async {
    // if the user is not org-admin then setting the widget.branchID to user's branch ID
    if( widget.userInfo['authority'] != 'org-admin' ) {
      widget.branchID = widget.userInfo['branch_id'];
    }
    else {
      widget.branchID = branchIDs[0];
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular( 20.0 ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // checking if the user if org-admin, if so then adding a new Dropdown to select Branch for which the shift will be applied
              widget.userInfo['authority'] == 'org-admin' ? MediaQuery.of(context).size.width < 500 ? Column (
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: Text("Select Branch"),
                  ),
                  Container(
                    width: 180 ,
                    child: StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState ) {
                          return Container(
                            padding: EdgeInsets.zero,
                            margin: EdgeInsets.zero,
                            child: DropdownButton(
                              isExpanded: true,
                              value: index2,
                              items: _branches,
                              onChanged: (int? value) {
                                if( _branches[value!].child.toString() == "Text(\"\")" ) {
                                  widget.branchID = '';
                                  setState( ( ) => this.index2 = 0 );
                                }
                                else {
                                  widget.branchID = this.branchIDs[value];
                                  setState(() => this.index2 = this._branches[value].value );
                                }
                              },
                            ),
                          );
                        }
                    ),
                  ),
                ],
              ) : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: Text("Select Branch"),
                  ),
                  Container(
                    width: 180 ,
                    child: StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState ) {
                          return Container(
                            padding: EdgeInsets.zero,
                            margin: EdgeInsets.zero,
                            child: DropdownButton(
                              isExpanded: true,
                              value: index2,
                              items: _branches,
                              onChanged: (int? value) {
                                if( _branches[value!].child.toString() == "Text(\"\")" ) {
                                  widget.branchID = '';
                                  setState( ( ) => this.index2 = 0 );
                                }
                                else {
                                  widget.branchID = this.branchIDs[value];
                                  setState(() => this.index2 = this._branches[value].value );
                                }
                              },
                            ),
                          );
                        }
                    ),
                  ),
                ],
              ) : Container(),
              Container(
                  margin: EdgeInsets.symmetric( vertical: 10.0 ),
                  child: DateTimePicker( text: "Start Time" , timeController: _timeController1 ),
              ),
              DateTimePicker( text: "End Time" , timeController: _timeController2, ),
              Container(
                margin: EdgeInsets.all( 10.0 ),
                alignment: Alignment.centerRight,
                child: MaterialButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular( 20.0 ),
                  ),
                  color: Colors.blue,
                  padding: EdgeInsets.all( 20.0 ),
                  onPressed: ( ) async {
                    // checking if the shift start-time and end time is not equal
                    if( _timeController1.text == _timeController2.text ) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context ) {
                          return AlertDialog(
                            backgroundColor: Colors.white,
                            content: Text("Shift Start Time and End Time Cannot be the same"),
                          );
                        }
                      );
                    }
                    else if( widget.branchID == '' ) {
                      showDialog(
                          context: context,
                          builder: (BuildContext context ) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              content: Text("Please Select a Branch"),
                            );
                          }
                      );
                    }
                    else {
                      // inserting the values to the shifts table
                      String url = "https://test-pranav-kale.000webhostapp.com/scripts/shift.php?function=0&start_time='${_timeController1.text}'&end_time='${_timeController2.text}'&org_id=${widget.userInfo['org_id']}&branch_id=${widget.branchID}";

                      http.Response response = await http.get( Uri.parse( url ) );

                      // popping the current Window
                      Navigator.of( context ).pop();

                      // showing the dialog according to the operation
                      showDialog(
                          context: context,
                          builder: (BuildContext context ) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              content: Text( response.body == 'true' ? "Shift Added" : "Something Went Wrong" ),
                            );
                          }
                      );

                      setState(() {
                        this.index2 =0 ;
                      });
                    }
                  },
                  child: Text(
                      "Done",
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.white,
                      ),
                  ),
                )
              )
            ],
          )
        )
      ),
    );
  }

  Future<void> _editShift( String start_time, String end_time, String id ) async {
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
                      String url = "https://test-pranav-kale.000webhostapp.com/scripts/shift.php?function=2&id=$id&s_time='${_timeController1.text}'&e_time='${_timeController2.text}'";

                      http.Response response = await http.get( Uri.parse( url ) );

                      if( response.body != '1' ) {
                        print( "Something Went Wrong ");
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

  Future<void> _deleteShift( String id ) async {
    String url = "https://test-pranav-kale.000webhostapp.com/scripts/shift.php?function=1&id=$id";

    http.Response response = await http.get( Uri.parse( url ) );

    if( response.body != '1' ) {
      print("Something went wrong");
    }
    else{
      // reloading the screen
      setState( () {} );
    }
  }

  Widget containerBuilder( var data, bool addQRCreate,bool addDelete ) {
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
                          child: Text( this.header['branch_name'] ),
                        ),
                        Container(
                          // color: Colors.red,
                          margin: EdgeInsets.symmetric( vertical: 4.0 ),
                          child: Text( this.header['start_time'] ),
                        ),
                        Container(
                          // color: Colors.red,
                          margin: EdgeInsets.symmetric( vertical: 4.0 ),
                          child: Text( this.header['end_time'] ),
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
                          height: 16.0,
                          alignment: Alignment.centerLeft,
                          // color: Colors.red,
                          margin: EdgeInsets.symmetric( vertical: 4.0 ),
                          child: Text( data['branch_name'] == null ? '-' : data['branch_name'] ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          // color: Colors.red,
                          margin: EdgeInsets.symmetric( vertical: 4.0 ),
                          child: Text(
                            data['start_time'],
                            textAlign: TextAlign.start,
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          // color: Colors.red,
                          margin: EdgeInsets.symmetric( vertical: 4.0 ),
                          child: Text(
                            data['end_time'],
                            textAlign: TextAlign.start,
                          ),
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
                  addQRCreate? MaterialButton(
                    onPressed: () async {
                      await _editShift( data['start_time'] , data['end_time'] , data['id'] );
                    },
                    child: Container(
                      padding: EdgeInsets.all( 5.0 ),
                      child: Icon(
                        Icons.edit,
                        color: Colors.black,
                      ),
                    ),
                  ) : Container( ),
                  addDelete ? MaterialButton(
                      onPressed: () async {
                        // delete branch
                        await _deleteShift( data['id'] );
                      },
                      child: Container(
                        padding: EdgeInsets.all( 5.0, ),
                        width: 150.0,
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

  Container _shiftViewBuilder() {
    return Container(
      child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState1 ) {
            return Column(
              children: [
                widget.userInfo['authority'] == 'org-admin' ?
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        minWidth: 180.0,
                      ),
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.center,
                      child: StatefulBuilder(
                          builder: (BuildContext context, StateSetter setState ) {
                            return Container(
                              alignment: Alignment.center,
                              width: 200.0,
                              child: DropdownButton(
                                isExpanded: true,
                                dropdownColor: Colors.white,
                                value: index2,
                                items: _branches,
                                onChanged: (int? value) {
                                  if( _branches[value!].child.toString() == "Text(\"\")" ) {
                                    widget.branchID = '';
                                    setState( ( ) => this.index2 = 0 );
                                  }
                                  else {
                                    widget.branchID = this.branchIDs[value];
                                    setState(() => this.index2 = this._branches[value].value );
                                  }

                                  // clearing the previous list of employees
                                  shifts.clear();

                                  // checking the branchID and making changes to the shifts list accordingly
                                  if( widget.branchID == '' ) {
                                    for( var i in records ) {
                                      Map<String, String> data = {
                                        'id' : i[0],
                                        'start_time' : i[1],
                                        'end_time' : i[2],
                                        'org_id' : i[3],
                                        'branch_id' : i[4],
                                        'branch_name' : i[5],
                                      };

                                      shifts.add( containerBuilder( data , true, true ) );
                                    }
                                  }
                                  else {
                                    for( var i in records ) {
                                      if( i[4].toString() == widget.branchID) {
                                        Map<String, String> data = {
                                          'id' : i[0],
                                          'start_time' : i[1],
                                          'end_time' : i[2],
                                          'org_id' : i[3],
                                          'branch_id' : i[4],
                                          'branch_name' : i[5],
                                        };

                                        shifts.add( containerBuilder( data , true, true ) );
                                      }
                                    }
                                  }

                                  // reloading the page
                                  setState1(() { });
                                },
                              ),
                            );
                          }
                      ),
                    ),
                  ],
                ) : Container(),
                Container(
                    height: MediaQuery.of(context).size.height - 128.0 ,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child : Container(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: shifts,
                          ),
                        ),
                      ),
                    )
                ),
              ],
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
        if( snapshot.connectionState == ConnectionState.done ) {
          return HomeScreenBuilder(
              appbar: AppBar(
                  iconTheme: IconThemeData(color: Colors.blueAccent),
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  actions: [
                    Container(
                      margin: EdgeInsets.symmetric( horizontal: 20.0 ),
                      child: IconButton(
                          icon: Icon(
                            Icons.add,
                            color: Colors.blueAccent,
                          ),
                          onPressed: () async {
                            // adding a new shift to the shift table
                            await _insertShift();
                          }
                      ),
                    )
                  ]
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
                    // checking if the user is an Organization Admin
                    widget.userInfo['authority'] == 'org-admin' ? ListTile(
                      title: Text( 'Manage branches', ),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewBranch( context: context, setState: setState, userInfo: widget.userInfo, ),
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ManageShifts(userInfo: widget.userInfo,)
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
                  ]
              ),
              body: Container(
                alignment: Alignment.center,
                child: _shiftViewBuilder(),
              )
          );
        }
        else if( snapshot.hasError ) {
          return HomeScreenBuilder(
            appbar: AppBar(
              iconTheme: IconThemeData(color: Colors.blueAccent),
              elevation: 0,
              backgroundColor: Colors.transparent,
            ),
            body: Container(
              alignment: Alignment.center,
              child: Text( snapshot.error.toString() ),
            ),
          );
        }
        else{
          return HomeScreenBuilder(
            appbar: AppBar(
              iconTheme: IconThemeData(color: Colors.blueAccent),
              elevation: 0,
              backgroundColor: Colors.transparent,
            ),
            body: Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            ),
          );
        }
      }
    );
  }
}
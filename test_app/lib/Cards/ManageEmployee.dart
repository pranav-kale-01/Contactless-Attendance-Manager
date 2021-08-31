import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:test_app/Screens/SignUp.dart';
import 'package:test_app/Templates/HomeScreenBuilder.dart';
import 'package:test_app/Templates/GradientContainer.dart';
import 'package:test_app/utils/CredentialController.dart';

class ManageEmployee extends StatefulWidget {
  final userInfo;

  final BuildContext context;
  final StateSetter setState;

  ManageEmployee({required this.context, required this.setState, required this.userInfo} ) : super();

  @override
  _ManageEmployeeState createState() => _ManageEmployeeState();
}

class _ManageEmployeeState extends State<ManageEmployee> {

  List<Widget>employees = [];
  List<DropdownMenuItem<int>> _branches = [ DropdownMenuItem(value:0, child: Text("") ) ];
  List<String> branchIDs = [];

  late String username;
  late String password;
  late String branchID;

  int? index2;

  Future<void> init() async {
    // initializing the Employees list
    await getEmployees();

    // initializing the Branches list
    await setBranches();
  }

  Future<void> getEmployees() async {
    String url = "https://test-pranav-kale.000webhostapp.com/scripts/get.php?table=users&condition=org_id&post=${widget.userInfo['org_id']}&condition2=authority&post2='emp'&custom";
    http.Response response = await http.get( Uri.parse( url ) );

    List<dynamic> jsonData = jsonDecode( response.body );

    if( response.body == '') {
      print('failed to load');
    }
    else {
      // clearing the previous list of Employees
      employees.clear();

      for( int i=0 ; i < jsonData.length ; i++ ) {
        Map<String,dynamic> data = jsonData[i];
        employees.add( containerBuilder( data['UID'], data['branch_id'], data['username'], true , true ) );
      }
    }
  }

  Future<void> setBranches( ) async {
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

    // adding the data to _branches
    for( i=0; i< jsonData.length ; i++ ) {
      Map<String,dynamic> data = jsonData[i];
      _branches.add(
        DropdownMenuItem(
          value: i,
          child: Text( data['branch_name'] ),
        ),
      ) ;

      branchIDs.add( data['branch_id'] );
    }

    // setting the default value for branchID
    branchID = branchIDs[0];
  }

  Future<void> _insertEmployee() async {
    // confirming that username is not empty
    if( this.username == '' ) {
      showDialog(
          context: context,
          builder: (BuildContext context ) {
            return AlertDialog(
              title: Text("Field Username cannot be empty"),
            );
          }
      );
      return;
    }
    else if( this.password == '' ) {
      showDialog(
          context: context,
          builder: (BuildContext context ) {
            return AlertDialog(
              title: Text("Field Password cannot be empty"),
            );
          }
      );
      return;
    }
    else{
      // adding the user details to the mysql database
      String url = "https://test-pranav-kale.000webhostapp.com/scripts/insert.php?user='${this.username}'&pass='${this.password}'&authority='emp'&orgid=${widget.userInfo['org_id']}&br_id=${this.branchID}";

      await http.get( Uri.parse( url ) );

      // closing the Popup
      Navigator.pop(context);

      // showing the confirmation message
      showDialog(
          context: context,
          builder: (BuildContext context ) {
            return AlertDialog(
              title: Text("User Added Successfully"),
            );
          }
      );

      setState( ( ) {} );
    }
  }

  void _deleteEmployee(  String id, String name ) {
    print(name);

    // asking for confirmation
    showDialog(
        context: context,
        builder: (BuildContext context ) {
          return AlertDialog(
            title: Container(
              child: Text("Are You Sure You want to delete user: $name?"),
            ),
            content: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MaterialButton(
                    onPressed: () async {
                      // Deleting the user
                      String url = "https://test-pranav-kale.000webhostapp.com/scripts/delete_user.php?user='$name'";

                      http.Response response = await http.get( Uri.parse( url ) );

                      // if response.body == 1, then something went wrong
                      if( response.body == 'false') {
                        // showing the confirmation message
                        showDialog(
                          context: context,
                          builder: (BuildContext context ) => AlertDialog(
                            content: Text("Something went wrong"),
                          ),
                        );

                        setState(() { });

                        Navigator.pop( context );
                      }
                      else {
                        // reloading the page
                        setState( () {} );

                        // removing the current dialog box
                        Navigator.pop(context);

                        // showing the confirmation message
                        showDialog(
                          context: context,
                          builder: (BuildContext context ) => AlertDialog(
                            content: Text("User Deleted"),
                          ),
                        );
                      }
                    },
                    child: Text("Yes"),
                  ),
                  MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("No"),
                  ),
                ]
            ),
          );
        }
    );
  }

  void _editEmployee( String id , String name ) {
    // edit user
    showDialog(
        context: context,
        builder: (BuildContext context ) {
          // creating a controller for Username TextField
          TextEditingController usernameController = TextEditingController( text: name );

          this.username = name ;

          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  onChanged: (value) {
                    this.username = value;
                  },
                  decoration: InputDecoration(
                    labelText: "username",
                  ),
                ),
                MaterialButton(
                  onPressed: () async {
                    // cheking if username has been left empty
                    if( this.username == '' ) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Field Username cannot be empty"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                alignment: Alignment.centerRight,
                                child: MaterialButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text("OK"),
                                ),
                              ),
                            ],
                          ),
                        )
                      );
                      return;
                    }

                    String url = "https://test-pranav-kale.000webhostapp.com/scripts/edit_user.php?id=$id&name=${this.username}&branch_id=${ widget.userInfo['branch_id'] }";

                    http.Response response = await http.get( Uri.parse( url ) );

                    // if response.body == 1, editing user details was successful
                    if( response.body == '1') {
                      setState(() { });

                      Navigator.pop( context );
                    }
                  },
                  child: Text("Edit"),
                ),
              ],
            ),
          );
        }
    );
  }

  Widget containerBuilder( String id , String? branchID, String name, bool addEdit,bool addDelete ) {
    return Container(
      alignment: Alignment.centerLeft,
      color: Colors.white60,
      padding: EdgeInsets.all( 20.0 ),
      margin: EdgeInsets.symmetric(vertical: 2.5 ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
              width: 50.0,
              height: 50.0,
              margin: EdgeInsets.symmetric(horizontal: 20.0 ),
              padding: EdgeInsets.all( 10.0 ),
              child: Text( id )
          ),
          Container(
              width: 100.0,
              height: 50.0,
              margin: EdgeInsets.symmetric(horizontal: 20.0 ),
              padding: EdgeInsets.all( 10.0 ),
              child: Text( branchID == null ? 'NULL' : branchID )
          ),
          Container(
              width: 200.0,
              height: 50.0,
              margin: EdgeInsets.symmetric(horizontal: 20.0 ),
              padding: EdgeInsets.all( 10.0 ),
              child: Text( name )
          ),
          addEdit ? MaterialButton(
              onPressed: () {
                _editEmployee(id, name );
              },
              child: Container(
                width: 150.0,
                margin: EdgeInsets.symmetric(horizontal: 20.0 ),
                padding: EdgeInsets.all( 10.0 ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(
                      Icons.edit,
                      color: Colors.black,
                    ),
                    Text(
                      'Edit',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    )
                  ],
                ),
              )
          ) : Container(
            width: 205.0,
          ),
          addDelete ? MaterialButton(
              onPressed: () {
                _deleteEmployee( id, name );
              },
              child: Container(
                width: 150.0,
                margin: EdgeInsets.symmetric(horizontal: 20.0 ),
                padding: EdgeInsets.all( 10.0 ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(
                      Icons.indeterminate_check_box_outlined,
                      color: Colors.red,
                    ),
                    Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.red,
                        decoration: TextDecoration.underline,
                      ),
                    )
                  ],
                ),
              )
          ) : Container(
            width: 205.0,
          ),
        ],
      ),
    );
  }

  Container _employeeViewBuilder(){
    return Container(
      color: Colors.blueAccent,
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            width: 1400.0,
            alignment: Alignment.center,
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: containerBuilder( "ID", 'BRANCH ID', 'NAME' ,false, false)
            ),
          ),
          Container(
              height: MediaQuery.of(context).size.height - 151.0 ,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child : Container(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: employees,
                    ),
                  ),
                ),
              )
          ),
        ],
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
                actions: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
                    child: IconButton(
                      icon: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        // showing the popup to insert users
                        showDialog(
                            context: context,
                            builder: (BuildContext context ) {
                              return AlertDialog(
                                  content:Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          onChanged: (value) {
                                            username = value;
                                          },
                                          decoration: InputDecoration(
                                              labelText: "user email"
                                          ),
                                        ),
                                        StatefulBuilder(
                                            builder: (BuildContext context, StateSetter setState ) {
                                              return Container(
                                                padding: EdgeInsets.zero,
                                                margin: EdgeInsets.zero,
                                                child: DropdownButton(
                                                  isExpanded: true,
                                                  value: index2,
                                                  items: _branches,
                                                  onChanged: (int? value) {
                                                    if(value != null ) {
                                                      index2 = value;
                                                    }
                                                    setState( () {} );
                                                  },
                                                ),
                                              );
                                            }
                                        ),
                                        TextField(
                                          onChanged: (value) {
                                            password = value;
                                          },
                                          decoration: InputDecoration(
                                            labelText: "password",
                                          ),
                                        ),
                                        MaterialButton(
                                          onPressed: () {
                                            // confirming that user has selected a branch
                                            if( _branches[0].child.toString() == 'Text("")' ) {
                                              showDialog(
                                                  context: context,
                                                  builder: (BuildContext context ) {
                                                    return AlertDialog(
                                                      content: Text("No branch available"),
                                                    );
                                                  }
                                              );
                                            }
                                            else {
                                              // adding the user to the users table
                                              _insertEmployee();
                                            }
                                          },
                                          child: Text("Add"),
                                        )
                                      ]
                                  )

                              );
                            }
                        );
                      },
                    ),
                  )
                ],
            ),
            listView:  ListView(
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
                  title: Text( 'Manage Employees', ),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ManageEmployee( setState:  setState, context: context , userInfo: widget.userInfo, ),
                      ),
                    );
                  },
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
            body: _employeeViewBuilder(),
          );
        }
        else if( snapshot.hasError == true ) {
          return HomeScreenBuilder(
              appbar: AppBar(
                backgroundColor: Color(0xFF10B5FC),
                title: Text( "Error" ),
              ),
              body: Center(
                child: Text( snapshot.error.toString() ),
              )
          );
        }
        else {
            return HomeScreenBuilder(
              appbar: AppBar(
                backgroundColor: Color(0xFF10B5FC),
                title: Text( "View Branch Admins" ),
              ),
              body: Center(
                child: GradientContainer(
                  child: CircularProgressIndicator()
                  ),
              )
            );
        }
      }
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:test_app/Screens/SignUp.dart';
import 'package:test_app/Templates/HomeScreenBuilder.dart';
import 'package:test_app/Templates/GradientContainer.dart';
import 'package:test_app/utils/CredentialController.dart';

import 'ManageBranch.dart';
import 'ManageBranchAdmins.dart';

class ManageEmployee extends StatefulWidget {
  final userInfo;

  final BuildContext context;
  final StateSetter setState1;

  late bool changedFromDropdown= false;
  late String branchID;

  ManageEmployee({required this.context, required this.setState1, required this.userInfo} ) : super();

  @override
  _ManageEmployeeState createState() => _ManageEmployeeState();
}

class _ManageEmployeeState extends State<ManageEmployee> {

  List<Widget> employees = [];
  List<List> records = [];
  List<DropdownMenuItem<int>> _branches = [ DropdownMenuItem(value:0, child: Text("") ) ];
  List<String> branchIDs = [];

  late String username;
  late String password;

  int? index2;

  Future<void> init() async {
    // checking if the current user is a Organization admin, if not then setting the branchID tu the Branch Admins associated branch
    if( widget.userInfo['authority'] == 'br-admin') {
      widget.branchID = widget.userInfo['branch_id'] ;
    }

    // initializing the Branches list
    await setBranches( true );

    if( widget.changedFromDropdown == false ) {
      // initializing the Employees list,
      await getEmployees();

      widget.changedFromDropdown = true;
    }
  }

  Future<void> getEmployees() async {
    String url;
    // checking if the branch ID is empty, if empty then showing all the employees
    if( widget.branchID == '' ) {
     url = "https://test-pranav-kale.000webhostapp.com/scripts/get.php?table=users&condition=&post=&condition2=&post2=&custom= * FROM `users` WHERE `users`.`org_id` = ${widget.userInfo['org_id']} AND `users`.`authority`='emp'";
    }
    else {
      url = "https://test-pranav-kale.000webhostapp.com/scripts/get.php?table=users&condition=&post=&condition2=&post2=&custom= * FROM `users` WHERE `users`.`org_id` = ${widget.userInfo['org_id']} AND `users`.`authority`='emp' AND `users`.`branch_id`=${widget.branchID}";
    }

    http.Response response = await http.get( Uri.parse( url ) );

    List<dynamic> jsonData = jsonDecode( response.body );

    if( response.body == '') {
      print('failed to load');
    }
    else {
      // clearing the previous list of Employees
      employees.clear();
      records.clear();

      for( int i=0 ; i < jsonData.length ; i++ ) {
        Map<String,dynamic> data = jsonData[i];
        employees.add( containerBuilder( data['UID'], data['branch_id'], data['username'], true , true ) );
        records.add( [data['UID'], data['branch_id'], data['username'], ] );
      }
    }
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
            child: Text(""),
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
      String url = "https://test-pranav-kale.000webhostapp.com/scripts/insert.php?user='${this.username}'&pass='${this.password}'&authority='emp'&orgid=${widget.userInfo['org_id']}&br_id=${widget.branchID}";

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

      getEmployees();
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
                        getEmployees();

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
          this.index2 = 0;

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
                widget.userInfo['authority'] == 'org-admin' ?
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
                            if( _branches[value!].child.toString() == "Text(\"\")" ) {
                              widget.branchID = '';
                              setState( ( ) => this.index2 = 0 );
                            }
                            else {
                              print('changed to' + this.branchIDs[value] );
                              widget.branchID = this.branchIDs[value];
                              setState(() => this.index2 = this._branches[value].value );
                            }
                          },
                        ),
                      );
                    }
                ) : Container(),
                MaterialButton(
                  onPressed: () async {
                    // checking if username has been left empty
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

                    String url;

                    print( widget.branchID );

                    // checking if the user has selected the 'None' option for branches
                    if( widget.branchID == '' ) {
                      url = "https://test-pranav-kale.000webhostapp.com/scripts/edit_user.php?id=$id&name=${this.username}&branch_id=";
                    }
                    else {
                      url = "https://test-pranav-kale.000webhostapp.com/scripts/edit_user.php?id=$id&name=${this.username}&branch_id=${widget.branchID}";
                    }

                    http.Response response = await http.get( Uri.parse( url ) );

                    // if response.body == 1, editing user details was successful
                    if( response.body == '1') {
                      getEmployees();

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
      child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState1 ) {
            return Column(
              children: [
                widget.userInfo['authority'] == 'org-admin' ?
                Container(
                  width: 1000,
                  alignment: Alignment.center,
                  child: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState ) {
                        return Container(
                          alignment: Alignment.topRight,
                          padding: EdgeInsets.zero,
                          margin: EdgeInsets.zero,
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
                              employees.clear();

                              // checking the branchID and making changes to the employees list accordingly
                              if( widget.branchID == '' ) {
                                for( var i in records ) {
                                  employees.add( containerBuilder( i[0], i[1], i[2], true, true ) );
                                }
                              }
                              else {
                                for( var i in records ) {
                                  if( i[1].toString() == widget.branchID) {
                                    employees.add( containerBuilder( i[0], i[1], i[2], true, true ) );
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
                ) : Container(),
                Container(
                  width: 1400.0,
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: containerBuilder( "ID", 'BRANCH ID', 'NAME' ,false, false)
                  ),
                ),
                Container(
                    height: MediaQuery.of(context).size.height - 200.0 ,
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
                                        widget.userInfo['authority'] == 'org-admin' ?
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
                                        ) : Container(),
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
                                            // adding the user to the users table
                                            _insertEmployee();
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
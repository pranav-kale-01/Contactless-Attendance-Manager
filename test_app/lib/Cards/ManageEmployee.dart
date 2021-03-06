import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:test_app/Cards/ManageBranch.dart';
import 'package:test_app/Cards/ManageBranchAdmins.dart';
import 'package:test_app/Cards/ManageScanHistory.dart';
import 'package:test_app/Cards/ManageScanLocations.dart';
import 'package:test_app/Cards/ManageShifts.dart';
import 'package:test_app/Screens/SignUp.dart';
import 'package:test_app/Templates/HomeScreenBuilder.dart';
import 'package:test_app/utils/CredentialController.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';


class ManageEmployee extends StatefulWidget {
  final userInfo;

  final BuildContext context;
  final StateSetter setState1;

  late bool changedFromDropdown= false;
  late String branchID;

  bool showAllValue = false;

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
  late String rec_mob;

  int? index2;
  bool CheckboxValue = false ;

  Map<String, dynamic> header = {
    "UID" : "User ID",
    'branch_id' : "Branch ID",
    'username' : "UserName",
    "branch_name" : "Branch Name",
    "recovery_mob" : "Recovery Mobile Number",
  };

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  Future<void> init( ) async {
    // checking if the current user is a Organization admin, if not then setting the branchID tu the Branch Admins associated branch
    if( widget.userInfo['authority'] == 'br-admin') {
      widget.branchID = widget.userInfo['branch_id'] ;
    }

    // initializing the Branches list
    await setBranches( true );

    if( widget.changedFromDropdown == false ) {
      // initializing the Employees list,
      await getEmployees( );

      widget.changedFromDropdown = true;
    }
  }

  Future<void> getEmployees() async {
    // checking if the user currently signed in is a branch admin, if it is then changing the branch ID to branchID of the branchAdmin
    if( widget.userInfo['authority'] == 'br-admin') {
      widget.branchID = widget.userInfo['branch_id'];
    }

    String url;

    // checking if the branch ID is empty, if empty then showing all the employees
    if( widget.branchID == '' || widget.showAllValue == true  ) {
     url = "https://test-pranav-kale.000webhostapp.com/scripts/get.php?table=users&condition=&post=&condition2=&post2=&custom= `users`.`UID`, `users`.`username`, `users`.`org_id`, `users`.`branch_id`, `users`.`authority`, `branches`.`branch_name`, `users`.`recovery_mob` FROM `users` LEFT JOIN `branches` ON `branches`.`branch_id` = `users`.`branch_id` WHERE `users`.`org_id` = ${widget.userInfo['org_id']} AND `users`.`authority`='emp'";
    }
    else {
      // else showing employees of the current branch and employees with no branch assigned
      url = "https://test-pranav-kale.000webhostapp.com/scripts/get.php?table=users&condition=&post=&condition2=&post2=&custom= `users`.`UID`, `users`.`username`, `users`.`org_id`, `users`.`branch_id`, `users`.`authority`, `branches`.`branch_name`,`users`.`recovery_mob` FROM `users` LEFT JOIN `branches` ON `branches`.`branch_id` = `users`.`branch_id` WHERE  ( `users`.`org_id` = ${widget.userInfo['org_id']} AND `users`.`authority`='emp' AND  (`users`.`branch_id`=${widget.branchID} OR `users`.`branch_id` IS NULL ) )";
    }

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
        // employees.add( containerBuilder( data['UID'], data['branch_id'], data['username'], true , true , true ) );
        employees.add( containerBuilder( data, true , true , true ) );

        records.add( [ data['UID'], data['branch_id'] == null ? '-' : data['branch_id'], data['username'], data['branch_name'] == null ? '-' : data['branch_name'] ] );
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
    else {
      index =0;
    }

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
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        rec_mob = value;
                      },
                      decoration: InputDecoration(
                        labelText: "recovery Mobile Number",
                      ),
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
                      onPressed: () async {
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
                        else if( this.rec_mob.length != 10 || isNumeric(this.rec_mob) == false ) {
                          showDialog(
                              context: context,
                              builder: (BuildContext context ) {
                                return AlertDialog(
                                  title: Text("Invalid Mobile Number"),
                                );
                              }
                          );
                          return;
                        }
                        else{
                          String url = "https://test-pranav-kale.000webhostapp.com/scripts/get.php?table=&condition=&post=&condition2=&post2=&custom= * FROM `users` WHERE `users`.`username` = '${this.username}' ";
                          http.Response response = await http.get( Uri.parse( url ) );

                          if( response.body != '[]' ){
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                content: Text("Username Already taken please try another one"),
                              ),
                            );
                          }
                          else {
                            // adding the user details to the mysql database
                            url = "https://test-pranav-kale.000webhostapp.com/scripts/user.php?function=0&user='${this.username}'&pass='${this.password}'&authority='emp'&orgid=${widget.userInfo['org_id']}&br_id=${widget.branchID}&rec_mob='${this.rec_mob}'&created='${widget.userInfo['username']}'&created_dt='${DateTime.now()}'&mod=NULL&mod_dt='00:00:00'";

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

                            // resetting the value of index2 to 0
                            this.index2 = 0 ;
                            widget.showAllValue = true;

                            getEmployees();
                            setState( ( ) {} );
                          }
                        }
                      },
                      child: Text("Add"),
                    )
                  ]
              )

          );
        }
    );
  }

  void _deleteEmployee(  String id, String name , String uid) {
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
                      String url = "https://test-pranav-kale.000webhostapp.com/scripts/user.php?function=1&UID='$uid'";
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
                        widget.showAllValue =  true ;
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

  void _editEmployee( String id , String name , String rec_mob ) {
    // edit user
    showDialog(
        context: context,
        builder: (BuildContext context ) {
          // creating a controller for Username TextField
          TextEditingController usernameController = TextEditingController( text: name );
          TextEditingController recEmailController = TextEditingController( text: rec_mob );

          this.username = name ;
          this.index2 = 0;
          this.rec_mob = recEmailController.text;

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
                TextField(
                  controller: recEmailController,
                  onChanged: (value) {
                    this.rec_mob = value;
                  },
                  decoration: InputDecoration(
                    labelText: "recovery Email",
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
                            this.CheckboxValue = true;
                            widget.showAllValue = false;

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
                ) : Container(
                  child: Row(
                   children: [
                     StatefulBuilder(
                       builder: (context, setCheckboxState ) {
                         return Checkbox(
                             value: CheckboxValue,
                             onChanged: (bool? value ) {
                               if( value != null ) {
                                 setCheckboxState( () {
                                   this.CheckboxValue = value;
                                 } );
                               }
                             }
                         );
                        }
                     ),
                     Text("Assign user with this branch? "),
                   ]
                  ),
                ),
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

                    // checking if the userName is too long
                    if( this.username.length >= 26 ) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: Text("UserName too Long!"),
                          ),
                        );

                        return;
                    }
                    else if( this.rec_mob.length != 10 || isNumeric(this.rec_mob) == false ) {
                      showDialog(
                          context: context,
                          builder: (BuildContext context ) {
                            return AlertDialog(
                              title: Text("Invalid Mobile Number"),
                            );
                          }
                      );
                      return;
                    }

                    url = "https://test-pranav-kale.000webhostapp.com/scripts/get.php?table=&condition=&post=&condition2=&post2=&custom= * FROM `users` WHERE `users`.`username` = '${this.username}' AND `users`.`UID` != $id";
                    http.Response response = await http.get( Uri.parse( url ) );

                    if( response.body != '[]' ){
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          content: Text("Username Already taken please try another one"),
                        ),
                      );
                    }
                    else {
                      // checking if the user has selected the 'None' option for branches OR for an employee has checked the checkbox to keep the branch id null
                      if( widget.branchID == ''  || this.CheckboxValue == false  ) {
                        url = "https://test-pranav-kale.000webhostapp.com/scripts/user.php?function=2&id=$id&name=${this.username}&rec_mob='${this.rec_mob}'&branch_id=&mod='${widget.userInfo['username']}'&mod_dt='${DateTime.now()}'";
                      }
                      else {
                        url = "https://test-pranav-kale.000webhostapp.com/scripts/user.php?function=2&id=$id&name=${this.username}&rec_mob='${this.rec_mob}'&branch_id=${widget.branchID}&mod='${widget.userInfo['username']}'&mod_dt='${DateTime.now()}'";
                      }

                      http.Response response = await http.get( Uri.parse( url ) );

                      // if response.body == 1, editing user details was successful
                      if( response.body == '1') {

                        this.index2 = 0 ;
                        widget.showAllValue = true;

                        // resetting the employees list
                        getEmployees();
                        setState(() { });

                        Navigator.pop( context );
                      }
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

  Widget containerBuilder( var data, bool addEdit,bool addDelete, bool addManageScanHistory ) {
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
                          child: Text( this.header['username'].toString() ),
                        ),
                        Container(
                          // color: Colors.red,
                          margin: EdgeInsets.symmetric( vertical: 4.0 ),
                          child: Text( this.header['branch_name'] ),
                        ),
                        Container(
                          // color: Colors.red,
                          margin: EdgeInsets.symmetric( vertical: 4.0 ),
                          child: Text( this.header['recovery_mob'] ),
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
                          margin: EdgeInsets.symmetric( vertical: 4.0 ),
                          child: Text(
                              data['username'],
                              style: TextStyle(
                                fontSize: 22.0,
                              ),
                          ),
                        ),
                        Container(
                            height: 16.0,
                            alignment: Alignment.centerLeft,
                            // color: Colors.red,
                            margin: EdgeInsets.symmetric( vertical: 4.0 ),
                            child: Text( data['branch_name'] == null ? '-' : data['branch_name'] ),
                        ),
                        Container(
                          height: 16.0,
                          alignment: Alignment.centerLeft,
                          // color: Colors.red,
                          margin: EdgeInsets.symmetric( vertical: 4.0 ),
                          child: Text( data['recovery_mob'] == null ? '-' : data['recovery_mob'] ),
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
                      onPressed: () {
                        _editEmployee( data['UID'], data['username'], data['recovery_mob'] == null ? '' : data['recovery_mob'] );
                      },
                      child: Container(
                        // margin: EdgeInsets.symmetric(horizontal: 20.0 ),
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
                      onPressed: () {
                        _deleteEmployee( data['UID'], data['username'], data['UID'] );
                      },
                      child: Container(
                        // margin: EdgeInsets.symmetric(horizontal: 20.0 ),
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
                  addManageScanHistory ? Container(
                    alignment: Alignment.centerRight,
                    child: MaterialButton(
                        onPressed: () {
                          Navigator.of( context ).push(
                              MaterialPageRoute(
                                builder: (context) => ManageScanHistory(userInfo: widget.userInfo, uid: data['UID'], showHamMenu: false,),
                              )
                          );
                        },
                        child: Container(
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.all( 10.0 ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "Manage Scans",
                                  style: TextStyle(
                                    color: Colors.indigo,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.indigo,
                                )
                              ],
                            )
                        )
                    ),
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

  Widget _employeeViewBuilder(){
    return Container(
      alignment: Alignment.center,
      child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState1 ) {
            return Column(
              children: [
                widget.userInfo['authority'] == 'org-admin'?
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
                                  Map<String, dynamic> record = {
                                    "UID" : i[0],
                                    "branch_id" : i[1],
                                    "username" : i[2],
                                    "branch_name": i[3]
                                  };

                                  // employees.add( containerBuilder( i[0], i[1], i[2], true, true, true ) );
                                  employees.add( containerBuilder( record, true, true, true ) );
                                }
                              }
                              else {
                                for( var i in records ) {
                                  Map<String, dynamic> record = {
                                    "UID" : i[0],
                                    "branch_id" : i[1],
                                    "username" : i[2],
                                    "branch_name" : i[3]
                                  };

                                  if( i[1].toString() == widget.branchID) {
                                    // employees.add( containerBuilder( i[0], i[1], i[2], true, true, true ) );
                                    employees.add( containerBuilder( record, true, true, true ) );
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
                    height: MediaQuery.of(context).size.height - 104 ,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child : Container(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            setState( () {} );
                          },
                          child: SingleChildScrollView(
                            physics: AlwaysScrollableScrollPhysics(),
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
    );
  }

  @override
  Widget build( BuildContext context ) {
    return FutureBuilder(
      future: init( ),
      builder: (context, snapshot ) {
        if( snapshot.connectionState == ConnectionState.done ) {
          return HomeScreenBuilder(
            appbar: AppBar(
                iconTheme: IconThemeData(color: Colors.blueAccent),
                elevation: 0,
                backgroundColor: Colors.transparent,
                actions: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular( 10.0 ),
                      // color: Colors.black12,
                    ),
                    margin: EdgeInsets.symmetric( horizontal: 20.0, vertical: 5.0 ),
                    child: IconButton(
                      icon: Icon(
                        Icons.add,
                        color: Colors.blueAccent,
                      ),
                      onPressed: () {
                        // showing the popup to insert users
                        _insertEmployee();
                      },
                    ),
                  )
                ],
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
                    // redirecting the user to Manage Shifts page
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManageShifts( userInfo : widget.userInfo ),
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
            body: _employeeViewBuilder()
          );
        }
        else if( snapshot.hasError == true ) {
          return HomeScreenBuilder(
              appbar: AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                iconTheme: IconThemeData(color: Colors.blueAccent),
              ),
              body: Center(
                child: Text( snapshot.error.toString() ),
              )
          );
        }
        else {
            return HomeScreenBuilder(
              appbar: AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                iconTheme: IconThemeData(color: Colors.blueAccent),
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
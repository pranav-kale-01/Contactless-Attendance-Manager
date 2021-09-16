import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:test_app/Cards/ManageScanLocations.dart';

import 'package:test_app/Screens/SignUp.dart';
import 'package:test_app/Templates/HomeScreenBuilder.dart';
import 'package:test_app/Templates/GradientContainer.dart';
import 'package:test_app/Cards/ManageBranch.dart';
import 'package:test_app/utils/CredentialController.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'ManageEmployee.dart';
import 'ManageScanHistory.dart';
import 'ManageShifts.dart';

class ManageBranchAdmins extends StatefulWidget {
  final userInfo;
  final context;
  final StateSetter setState;
  bool showHamMenu = true;

  ManageBranchAdmins({Key? key, required this.userInfo, required this.context, required this.setState, showHamMenu }) : super( key: key) {
    if( showHamMenu != null ) {
      this.showHamMenu = showHamMenu ;
    }
  }

  @override
  _ManageBranchAdminsState createState() => _ManageBranchAdminsState();
}

class _ManageBranchAdminsState extends State<ManageBranchAdmins>  {
  List<Widget> users = [];

  var nameController = TextEditingController();
  var emailController = TextEditingController();

  late String username;
  late String password;
  late String orgID;
  late String branchID;

  int? index = 0 ;
  int? index2 = 0 ;

  late dynamic jsonData;
  List<Container> orgAdmins = [ ];
  List<DropdownMenuItem<int>> _branches = [ DropdownMenuItem(value:0, child: Text("") ) ];

  List<String> orgIDs = [];
  List<String> branchIDs = [];

  Future<void> _insertBranchAdmin( ) async {
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
      String url;

      // checking if the user has selected 'None' from Branch options
      if( this.branchID == '' ) {
        url = "https://test-pranav-kale.000webhostapp.com/scripts/user.php?function=0&user='${this.username}'&pass='${this.password}'&authority='br-admin'&orgid=${widget.userInfo['org_id']}&br_id=";
      }
      else{
        // adding the user details to the mysql database
        url = "https://test-pranav-kale.000webhostapp.com/scripts/user.php?function=0&user='${this.username}'&pass='${this.password}'&authority='br-admin'&orgid=${widget.userInfo['org_id']}&br_id=${this.branchID}";
      }

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

      setState(() { });
    }
  }

  Future<void> setBranches( id, bool addEmpty ) async {
    int i;

    // getting all the branches of the current organization
    String url = "https://test-pranav-kale.000webhostapp.com/scripts/get.php?table=branches&condition=org_id&post=$id&condition2=&post2=&custom";

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
    }
    else index =0;

    // adding the data to _branches
    for( i=0; i< jsonData.length ; i++ ) {
      Map<String,dynamic> data = jsonData[i] ;

      _branches.add(
        DropdownMenuItem(
          value: index,
          child: Text( data['branch_name'] ),
        ),
      ) ;

      branchIDs.add( data['branch_id'] );
      index +=1 ;
    }

    // checking if an empty branch option was added, if added then making it the default selection, else making the first branch of the list the defaul selection
    if( index == i )
      branchID = branchIDs[0];
    else
      branchID = '';
  }

  Future<void> _editBranchAdmin( String uid, String username )  async {
    // creating a new TextEditingController for username Field
    TextEditingController usernameController = TextEditingController( text: username );
    this.username = username;

    // resetting the old index
    this.index2= 0;

    // setBranches( widget.userInfo['org_id'] , true );

    showDialog(
        context: context,
        builder: (BuildContext context ) {
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
                StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState ) {
                      return Container(
                        padding: EdgeInsets.zero,
                        margin: EdgeInsets.zero,
                        child: DropdownButton(
                          isExpanded: true,
                          value: this.index2,
                          items: this._branches,
                          onChanged: (int? value) {
                            if( _branches[value!].child.toString() == "Text(\"\")" ) {
                              this.branchID = '';
                              setState( ( ) => this.index2 = 0 );
                            }
                            else {
                              this.branchID = this.branchIDs[value-1];
                              setState(() => this.index2 = this._branches[value].value );
                            }
                          },
                        ),
                      );
                    }
                ),
                MaterialButton(
                  onPressed: () async {
                    String url;

                    if( this.branchID == '' ) {
                      url ="https://test-pranav-kale.000webhostapp.com/scripts/user.php?function=2&id=$uid&name=${this.username}&branch_id=";
                    }
                    else {
                      url = "https://test-pranav-kale.000webhostapp.com/scripts/user.php?function=2&id=$uid&name=${this.username}&branch_id=${this.branchID}";
                    }

                    await http.get( Uri.parse( url ) );

                    setState(() { });

                    Navigator.pop(context);
                  },
                  child: Text("Edit"),
                ),
              ],
            ),
          );
        }
    );
  }

  Future<void> _deleteBranchAdmin( String username ) async {
    print( username );

    // delete the User
    String url = "https://test-pranav-kale.000webhostapp.com/scripts/user.php?function=1&user='$username';";

    http.Response response = await http.get( Uri.parse( url ) );

    print( response.body );

    if( response.body == "1" ) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text("User Deleted.."),
            );
          }
      );
      setState(() { });
    }
  }

  Future<void> insertBranchAdmin( ) async {
    this.index2=0;

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
                        this.username = value;
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
                              value: this.index2,
                              items: this._branches,
                              onChanged: (int? value) {
                                if( _branches[value!].child.toString() == "Text(\"\")" ) {
                                  this.branchID = '';
                                  setState( ( ) => this.index2 = 0 );
                                }
                                else {
                                  this.branchID = this.branchIDs[value-1];
                                  setState(() => this.index2 = this._branches[value].value );
                                }
                              },
                            ),
                          );
                        }
                    ),
                    TextField(
                      onChanged: (value) {
                        this.password = value;
                      },
                      decoration: InputDecoration(
                        labelText: "password",
                      ),
                    ),
                    MaterialButton(
                      onPressed: () {
                        // adding the user to the users table
                        _insertBranchAdmin();
                      },
                      child: Text("Add"),
                    )
                  ]
              )

          );
        }
    );
  }

  Container containerBuilder( data , bool addEdit, bool addDelete ) {
    return Container(
      color: Colors.white60,
      padding: EdgeInsets.all( 20.0 ),
      margin: EdgeInsets.all( 2.5 ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
              width: 150.0,
              height: 50.0,
              margin: EdgeInsets.symmetric(horizontal: 20.0 ),
              child: Text( data['UID'] )
          ),
          Container(
              width: 150.0,
              height: 50.0,
              margin: EdgeInsets.symmetric(horizontal: 20.0 ),
              child: Text( data['username'] )
          ),
          Container(
            width: 150.0,
            height: 50.0,
            margin: EdgeInsets.symmetric(horizontal: 20.0 ),
            child: Text( data['branch_id'] == null ? 'Null' : data['branch_id'] ),
          ),
          Container(
            width: 150.0,
            height: 50.0,
            margin: EdgeInsets.symmetric(horizontal: 20.0 ),
            child: Text( data['branch_name'] == null ? 'Null' : data['branch_name'] ),
          ),
          addEdit ? MaterialButton(
            onPressed: () async {
              await _editBranchAdmin( data['UID'] , data['username'] );

            },
            child: Container(
              width: 150.0,
              margin: EdgeInsets.symmetric(horizontal: 20.0 ),
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
            ),
          ) : Container(
            width: 210.0,
            height: 50.0,
          ),
          addDelete? MaterialButton(
              onPressed: () async {
                await _deleteBranchAdmin( data['username'] );
                setState(() { });
              },
              child: Container(
                width: 150.0,
                margin: EdgeInsets.symmetric(horizontal: 20.0 ),
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
            width: 210.0,
            height: 50.0,
          ),
        ],
      ),
    );
  }

  Future<void> init() async {
    // getting the list of organizations for later use
    setBranches( widget.userInfo['org_id'] , true );

    String url = "https://test-pranav-kale.000webhostapp.com/scripts/get.php?table=users&condition=&post=&condition2=&post2=&custom= `users`.`UID`, `users`.`username`, `users`.`branch_id`,`branches`.`branch_id`, `branches`.`branch_name` FROM `users` LEFT JOIN `branches` ON `users`.`branch_id`=`branches`.`branch_id` WHERE `users`.`authority`='br-admin' AND `users`.`org_id`= ${widget.userInfo['org_id']}";

    http.Response response = await http.get( Uri.parse( url ) ) ;

    if( response.body == 'false' ) {
      print("something went wrong");
    }
    else {
      // decoding the data
      var jsonData = jsonDecode( response.body );

      // clearing the previous list
      users.clear();

      // insert the data to the branches list
      for (int j = 0; j < jsonData.length ; j++) {
        users.add( containerBuilder( jsonData[j] , true , true ) );
      }
    }
  }

  Container showBranchAdmins() {
    Map<String, dynamic> header = {
      'UID':"ID",
      'username':'Username',
      'org_id':'Organization ID',
      'branch_id':'Branch ID',
      'branch_name':'Branch Name',
    };
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
              child: containerBuilder( header , false, false),
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
                    children: users,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context ) {
    return FutureBuilder(
        future: init(),
        builder: ( context, snapshot ) {
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
                      onPressed: () async {
                        await insertBranchAdmin();
                      },
                    ),
                  )
                ],
                backgroundColor: Color(0xFF10B5FC),
                title: Text( "View Branch Admins" ),
              ),
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
                  ListTile(
                    title: Text( 'Manage branches', ),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewBranch( context: context, setState: setState,  userInfo: widget.userInfo ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: Text( 'Manage Branch Admins', ),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(

                          builder: (context) => ManageBranchAdmins( context: context, setState: setState, userInfo: widget.userInfo, ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: Text( 'Manage Employees', ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context)=> ManageEmployee( context: context,  setState1: setState, userInfo: widget.userInfo, ),
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
                    title: Text("Manage Shifts"),
                    onTap: () {
                      // redirecting the user to ManageShifts Page
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManageShifts( userInfo: widget.userInfo ),
                        )
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
              body: showBranchAdmins(),
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
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:test_app/Cards/ManageBranch.dart';
import 'package:test_app/Cards/ManageEmployee.dart';
import 'package:test_app/Cards/ManageScanLocations.dart';
import 'package:test_app/Cards/ManageShifts.dart';
import 'package:test_app/Screens/SignUp.dart';
import 'package:test_app/Templates/HomeScreenBuilder.dart';
import 'package:test_app/Templates/GradientContainer.dart';
import 'package:test_app/utils/CredentialController.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

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
  late String rec_mob;
  late String orgID;
  late String branchID;

  int? index = 0 ;
  int? index2 = 0 ;

  late dynamic jsonData;
  List<Container> orgAdmins = [ ];
  List<DropdownMenuItem<int>> _branches = [ DropdownMenuItem(value:0, child: Text("") ) ];

  List<String> orgIDs = [];
  List<String> branchIDs = [];

  Map<String, dynamic> header = {
    'UID':"ID",
    'username':'Username',
    'branch_id':'Branch ID',
    'branch_name':'Branch Name',
    'recovery_mob' : "Recovery Mobile Number"
  };

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
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

  Future<void> _insertBranchAdmin( ) async {
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
                        this.rec_mob = value;
                      },
                      decoration: InputDecoration(
                        labelText: "Recovery Mobile Number",
                      ),
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
                      onPressed: () async {
                        // adding the user to the users table

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
                          String url = "https://test-pranav-kale.000webhostapp.com/scripts/get.php?table=&condition=&post=&condition2=&post2=&custom= * FROM `users` WHERE `users`.`username` = '${this.username}'";

                          http.Response response = await http.get( Uri.parse( url ) );

                          print( response.body );

                          if( response.body != '[]' ){
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                content: Text("Username Already taken please try another one"),
                              ),
                            );
                          }
                          else {
                            // checking if the user has selected 'None' from Branch options
                            if( this.branchID == '' ) {
                              url = "https://test-pranav-kale.000webhostapp.com/scripts/user.php?function=0&user='${this.username}'&pass='${this.password}'&authority='br-admin'&orgid=${widget.userInfo['org_id']}&rec_mob='${this.rec_mob}'&br_id=&created='${widget.userInfo['username']}'&created_dt='${DateTime.now()}'&mod=NULL&mod_dt='00:00:00'";
                            }
                            else{
                              // adding the user details to the mysql database
                              url = "https://test-pranav-kale.000webhostapp.com/scripts/user.php?function=0&user='${this.username}'&pass='${this.password}'&authority='br-admin'&orgid=${widget.userInfo['org_id']}&rec_mob='${this.rec_mob}'&br_id=${this.branchID}&created='${widget.userInfo['username']}'&created_dt='${DateTime.now()}'&mod=NULL&mod_dt='00:00:00'";
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
                      },
                      child: Text("Add"),
                    )
                  ]
              )

          );
        }
    );
  }

  Future<void> _deleteBranchAdmin( String uid ) async {
    // delete the User
    String url = "https://test-pranav-kale.000webhostapp.com/scripts/user.php?function=1&UID='$uid';";

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

  Future<void> _editBranchAdmin( String uid, String username, String rec_mob )  async {
    // creating a new TextEditingController for username Field
    TextEditingController usernameController = TextEditingController( text: username );
    TextEditingController recEmailController = TextEditingController( text: rec_mob );

    this.rec_mob = rec_mob;
    this.username = username;

    // resetting the old index
    this.index2= 0;

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
                TextField(
                  controller: recEmailController,
                  onChanged: (value) {
                    this.rec_mob = value;
                  },
                  decoration: InputDecoration(
                    labelText: "Recovery Mobile Number",
                  ),
                ),
                MaterialButton(
                  onPressed: () async {
                    String url = "https://test-pranav-kale.000webhostapp.com/scripts/get.php?table=&condition=&post=&condition2=&post2=&custom= * FROM `users` WHERE `users`.`username` = '${this.username}' AND `users`.`UID` != $uid";

                    print( url );

                    http.Response response = await http.get( Uri.parse( url ) );

                    if( this.username == '' ){
                      showDialog(
                          context: context,
                          builder: (BuildContext context ) {
                            return AlertDialog(
                              title: Text("Field UserName cannot be empty"),
                            );
                          }
                      );
                    }
                    else if( recEmailController.text == '' ){
                      showDialog(
                          context: context,
                          builder: (BuildContext context ) {
                            return AlertDialog(
                              title: Text("Field Recovery Mobile Number cannot be empty"),
                            );
                          }
                      );
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
                    else {
                      String url = "https://test-pranav-kale.000webhostapp.com/scripts/get.php?table=&condition=&post=&condition2=&post2=&custom= * FROM `users` WHERE `users`.`username` = '${this.username}' AND `users`.`UID` != $uid";

                      print( url );

                      http.Response response = await http.get( Uri.parse( url ) );

                      print( response.body );

                      if( response.body != '[]' ){
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: Text("Username Already taken please try another one"),
                          ),
                        );
                      }
                      else{
                        if( this.branchID == '' ) {
                          url ="https://test-pranav-kale.000webhostapp.com/scripts/user.php?function=2&id=$uid&name=${this.username}&rec_mob='${this.rec_mob}'&branch_id=&mod='${widget.userInfo['username']}'&mod_dt='${DateTime.now()}'";
                        }
                        else {
                          url = "https://test-pranav-kale.000webhostapp.com/scripts/user.php?function=2&id=$uid&name=${this.username}&rec_mob='${this.rec_mob}'&branch_id=${this.branchID}&mod='${widget.userInfo['username']}'&mod_dt='${DateTime.now()}'";
                        }

                        await http.get( Uri.parse( url ) );

                        setState(() { });

                        Navigator.pop(context);

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

  Widget containerBuilder( var data, bool addEdit,bool addDelete ) {
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
                          child: Text( this.header['username'] ),
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
                        // edit branch admin
                        _editBranchAdmin( data['UID'], data['username'], data['recovery_mob'] == null ? '' : data['recovery_mob'] );
                      },
                      child: Container(
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
                      onPressed: () async {
                        // remove branch
                        await _deleteBranchAdmin( data['UID'] );
                        setState(() { });
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> init() async {
    // getting the list of organizations for later use
    setBranches( widget.userInfo['org_id'] , true );

    String url = "https://test-pranav-kale.000webhostapp.com/scripts/get.php?table=users&condition=&post=&condition2=&post2=&custom= `users`.`UID`, `users`.`username`, `users`.`branch_id`,`branches`.`branch_id`, `branches`.`branch_name`, `users`.`recovery_mob` FROM `users` LEFT JOIN `branches` ON `users`.`branch_id`=`branches`.`branch_id` WHERE `users`.`authority`='br-admin' AND `users`.`org_id`= ${widget.userInfo['org_id']}";

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
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height - 56.0,
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
                      children: users,
                    ),
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
                        await _insertBranchAdmin();
                      },
                    ),
                  )
                ],
                title: Text(
                    "View Branch Admins",
                    style: TextStyle(
                      color: Colors.blueAccent,
                    )
                ),
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
                  iconTheme: IconThemeData(color: Colors.blueAccent),
                  elevation: 0,
                  backgroundColor: Colors.transparent,
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
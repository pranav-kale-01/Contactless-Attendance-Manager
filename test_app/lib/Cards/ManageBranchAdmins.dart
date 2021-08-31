import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:test_app/Screens/SignUp.dart';
import 'package:test_app/Templates/HomeScreenBuilder.dart';
import 'package:test_app/Templates/GradientContainer.dart';
import 'package:test_app/Cards/ManageBranch.dart';
import 'package:test_app/utils/CredentialController.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class ManageBranchAdmins extends StatefulWidget {
  final userInfo;
  final context;
  final StateSetter setState;

  ManageBranchAdmins({Key? key, required this.userInfo, required this.context, required this.setState }) : super( key: key);

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
      // adding the user details to the mysql database
      String url = "https://test-pranav-kale.000webhostapp.com/scripts/insert.php?user='${this.username}'&pass='${this.password}'&authority='br-admin'&orgid=${widget.userInfo['org_id']}&br_id=${this.branchID}";

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

    //
    // int index;
    // if( addEmpty ) {
    //   _branches.add(
    //       DropdownMenuItem(
    //         value: 0,
    //         child: Text(""),
    //       )
    //   );
    //   index =1 ;
    // }
    // else index =0;

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

    branchID = branchIDs[0];
  }

  Future<void> _editBranchAdmin( String uid, String username )  async {
    this.index2= 0;

    setBranches( widget.userInfo['org_id'] , true );

    showDialog(
        context: context,
        builder: (BuildContext context ) {

          this.username = username;

          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
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
                      url ="https://test-pranav-kale.000webhostapp.com/scripts/edit_user.php?id=$uid&name=${this.username}&branch_id=";
                    }
                    else {
                      url = "https://test-pranav-kale.000webhostapp.com/scripts/edit_user.php?id=$uid&name=${this.username}&branch_id=${this.branchID}";
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
    // delete the User
    String url = "https://test-pranav-kale.000webhostapp.com/scripts/delete_user.php?user='$username;";

    http.Response response = await http.get( Uri.parse( url ) );

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
                        // confirming that user has selected a branch
                        if( this._branches[0].child.toString() == 'Text("")' ) {
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
                          _insertBranchAdmin();
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
    setBranches( widget.userInfo['org_id'] , false );

    print( widget.userInfo['org_id']);

    String url = "https://test-pranav-kale.000webhostapp.com/scripts/get.php?table=users&condition=&post=&condition2=&post2=&custom= `users`.`UID`, `users`.`username`, `users`.`branch_id`,`branches`.`branch_id`, `branches`.`branch_name` FROM `users` LEFT JOIN `branches` ON `users`.`branch_id`=`branches`.`branch_id` WHERE `users`.`authority`='br-admin' AND `users`.`org_id`= ${widget.userInfo['org_id']}";

    http.Response response = await http.get( Uri.parse( url ) ) ;

    if( response.body == 'false' ) {
      print("something went wrong");
    }
    else {
      print(response.body );

      // decoding the data
      var jsonData = jsonDecode( response.body );

      // clearing the previous list
      users.clear();

      // insert the data to the branches list
      for (int j = 0; j < jsonData.length ; j++) {
        // checking if the org_id of current record is equal to the org_id of the user
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
                        setState(() { });
                      },
                    ),
                  )
                ],
                backgroundColor: Color(0xFF10B5FC),
                title: Text( "View Branch Admins" ),
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
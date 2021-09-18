import 'package:flutter/material.dart';

import 'package:test_app/Screens/SignUp.dart';
import 'package:test_app/Cards/ManageOrganizations.dart';
import 'package:test_app/Templates/HomeScreenBuilder.dart';
import 'package:test_app/utils/CredentialController.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'ManageScanHistory.dart';

class ManageOrganizationsAdmins extends StatefulWidget {
  bool showHamMenu = false;
  String? orgID;

  ManageOrganizationsAdmins({Key? key, showHamMenu , orgID }) : super(key: key) {
    if( orgID != null ) {
      this.orgID = orgID ;
    }
    if( showHamMenu != null ) {
      this.showHamMenu = showHamMenu;
    }
  }

  @override
  _ManageOrganizationsAdminsState createState() => _ManageOrganizationsAdminsState();
}

class _ManageOrganizationsAdminsState extends State<ManageOrganizationsAdmins> {
  var nameController = TextEditingController();
  var emailController = TextEditingController();

  late String username;
  late String password;
  late String orgID;
  late String branchID;

  int? index = 0 ;
  int? index2 = 0 ;

  late dynamic jsonData;
  List<Widget> orgAdmins = [ ];

  List<DropdownMenuItem<int>> _organizations = [];
  List<DropdownMenuItem<int>> _branches = [ DropdownMenuItem(value:0, child: Text("") ) ];

  List<String> orgIDs = [];
  List<String> branchIDs = [];

  Map<String,dynamic> header = {
    'UID': "ID",
    'org_id': "ID",
    'username': "UserName",
    'org_name': "Organization Name",
    'org_mail': "Organization Mail",
  };

  Future<void> insertOrgAdmin( ) async {
    // if widget.user has data then using that data instead
    if( widget.orgID != null )
      this.orgID = widget.orgID!;

    // adding the user details to the mysql database
    String url = "https://test-pranav-kale.000webhostapp.com/scripts/user.php?function=0&user='${this.username}'&pass='${this.password}'&authority='org-admin'&orgid=${this.orgID}&br_id=";

    print( url );

    await http.get( Uri.parse( url ) );
  }

  Future<void> viewOrgAdmins( ) async {
    String url ;

    if( widget.orgID != null ) {
      url = "https://test-pranav-kale.000webhostapp.com/scripts/get.php?table=users&condition=&post=&condition2=&post2=&custom=`users`.`UID`, `users`.`username`, `organization`.`org_name`, `organization`.`org_mail`,`organization`.`org_id`FROM `users` INNER JOIN `organization` ON `users`.`org_id`=`organization`.`org_id`WHERE `users`.`authority`='org-admin' AND `users`.`org_id` = ${widget.orgID }";
    }
    else {
      url = "https://test-pranav-kale.000webhostapp.com/scripts/get.php?table=users&condition=&post=&condition2=&post2=&custom=`users`.`UID`, `users`.`username`, `organization`.`org_name`, `organization`.`org_mail`,`organization`.`org_id`FROM `users` INNER JOIN `organization` ON `users`.`org_id`=`organization`.`org_id` WHERE `users`.`authority`='org-admin'";
    }

    http.Response response = await http.get( Uri.parse( url ), );

    jsonData = jsonDecode( response.body ) ;

    if( jsonData == 'false') {
      print("something went wrong ") ;
    }

    // clearing organizations list
    orgAdmins.clear();

    for (int j = 0; j < jsonData.length; j++) {
      Map<String, dynamic> data = jsonData[j] ;

      // checking if widget.user has org_id, if true then adding org_admins that belong to that org only
      if( widget.orgID != null ) {
        if(  widget.orgID == data['org_id'] )
          orgAdmins.add( containerBuilder( data, true, true ) );
      }
      else {
        // adding the information to the organizations list for displaying
        orgAdmins.add( containerBuilder( data, true, true ) );
      }
    }
  }

  Future<void> viewOrg( ) async {
    int j;
    String url = "https://test-pranav-kale.000webhostapp.com/scripts/get.php?table=organization&condition=&post=&condition2=&post2=&custom";

    http.Response response = await http.get( Uri.parse( url ) );

    jsonData = jsonDecode( response.body ) ;

    // clearing organizations list
    _organizations.clear();
    orgIDs.clear();

    for ( j = 0; j < jsonData.length; j++) {
      Map<String, dynamic> data = jsonData[j];

      // adding the information to the organizations list for displaying
      _organizations.add(
        DropdownMenuItem(
          value: j,
          child: Text( data['org_name'] ),
        ),
      );

      orgIDs.add( data['org_id'] );
    }

    // adding a blank Entry
    DropdownMenuItem(
      value:j,
      child: Text(""),
    );
  }

  Future<void> setBranches( id ) async {
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
  }

  void _editOrgAdmin( String username , String uid) {
    // creating a controller for username TextField
    TextEditingController usernameController = TextEditingController( text: username );

    showDialog(
        context: context,
        builder: (BuildContext context ) {
          this.username = username;

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
                    String url = "https://test-pranav-kale.000webhostapp.com/scripts/user.php?function=2&id=$uid&name='${this.username}'";

                    http.Response response = await http.get( Uri.parse( url ) );

                    // if response.body == 1, editing user details was successful
                    if( response.body == '1') {
                      Navigator.pop( context );

                      setState(() { });
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

  Future<void> _deleteOrgAdmin(username) async {
    // delete the User
    String url = "https://test-pranav-kale.000webhostapp.com/scripts/user.php?function=1&user='$username'";

    http.Response response = await http.get(Uri.parse(url));

    if (response.body == "1") {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text("User Deleted.."),
            );
          }
      );
    }
  }

  Widget containerBuilder( var data, bool addEdit,bool addDelete ) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric( horizontal: 7.0, vertical: 6.0 ),
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
                          child: Text( this.header['org_name'].toString() ),
                        ),
                        Container(
                          // color: Colors.red,
                          margin: EdgeInsets.symmetric( vertical: 4.0 ),
                          child: Text( this.header['org_id'] ),
                        ),
                        Container(
                          // color: Colors.red,
                          margin: EdgeInsets.symmetric( vertical: 4.0 ),
                          child: Text( this.header['org_mail'] ),
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
                            data['org_name'],
                            textAlign: TextAlign.start,
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          // color: Colors.red,
                          margin: EdgeInsets.symmetric( vertical: 4.0 ),
                          child: Text( data['org_id'] ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          // color: Colors.red,
                          margin: EdgeInsets.symmetric( vertical: 4.0 ),
                          child: Text( data['org_mail'] ),
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
                        _editOrgAdmin( data['username'], data['UID'] );
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
                      onPressed: () async {
                        await _deleteOrgAdmin( data['username'] );
                        setState( () {} );
                      },
                      child: Container(
                        width: 150.0,
                        margin: EdgeInsets.symmetric(horizontal: 20.0 ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              Icons.delete,
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
            ),
          ],
        ),
      ),
    );
  }
  @override
  void initState( ) {
    super.initState();

    // getting all the organization names for later use
    viewOrg();
  }

  Widget _organizationAdminsViewBuilder( ) {
    return Container(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height - 151.0 ,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child : Container(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: orgAdmins,
                    ),
                  ),
                ),
              ),
            ),
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: viewOrgAdmins(),
        builder: (context,snapshot) {
          if( snapshot.connectionState == ConnectionState.done ) {
            return HomeScreenBuilder(
              appbar: AppBar(
                iconTheme: IconThemeData(color: Colors.blueAccent),
                elevation: 0,
                backgroundColor: Colors.transparent,
                actions: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20.0),
                    child: IconButton(
                      icon: Icon(
                          Icons.add,
                          color: Colors.blueAccent,
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
                                        this.username = value;
                                      },
                                      decoration: InputDecoration(
                                          labelText: "user email"
                                      ),
                                    ),
                                    StatefulBuilder(
                                      builder: (BuildContext context, StateSetter setState ) {
                                        return Column(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.zero,
                                              margin: EdgeInsets.zero,
                                              child: widget.orgID == null ? DropdownButton(
                                                isExpanded: true,
                                                value: index,
                                                items: _organizations,
                                                onChanged: (int? value) async {
                                                  this.orgID = orgIDs[value!];
                                                  index = _organizations[value].value ;

                                                  // getting the branches of the current organization
                                                  await setBranches( this.orgID );

                                                  // setting the index2 to 0
                                                  index2 = 0;

                                                  setState( () { } );
                                                },
                                              ) : Container() ,
                                            ),
                                          ],
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
                                        insertOrgAdmin();

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
                  ),
                ]
              ),
              listView: widget.showHamMenu ?  ListView(
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
                    title: Text( 'Manage Organizations', ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context)=> ViewOrganizations( ),
                          )
                      );
                    },
                  ),
                  ListTile(
                    title: Text( 'Manage Organization admin', ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context)=> ManageOrganizationsAdmins(),
                          )
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
              ) : null ,
              body: _organizationAdminsViewBuilder(),
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
                child: Text( snapshot.error.toString() ),
              ),
            );
          }
          else {
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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:test_app/Screens/SignUp.dart';
import 'package:test_app/Cards/ManageOrganizationAdmins.dart';
import 'package:test_app/Cards/ManageBranch.dart';
import 'package:test_app/Cards/ManageBranchAdmins.dart';
import 'package:test_app/Templates/HomeScreenBuilder.dart';
import 'package:test_app/utils/CredentialController.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:convert';

class ViewOrganizations extends StatefulWidget {
  bool showHamMenu = true;
  final userInfo;

  ViewOrganizations({Key? key, showHamMenu, required this.userInfo }) : super(key: key) {
    if( showHamMenu != null ) {
      this.showHamMenu = showHamMenu;
    }
  }

  @override
  _ViewOrganizationsState createState() => _ViewOrganizationsState();
}

class _ViewOrganizationsState extends State<ViewOrganizations> {
  var nameController = TextEditingController();
  var emailController = TextEditingController();

  late String orgName;
  late String orgEmail='';

  late dynamic jsonData;
  List<Widget> organizations = [ ];

  Map<String,dynamic> header = {
    'org_name': "Name",
    'org_id': "ID",
    'org_mail': "Mail",
    'created_by' : "Created By",
    'created_date_time' : "Created Date Time",
    'modified_by' : "Modified By",
    'modified_date_time' : "Modified Date Time"
  };

  Future<void> insertOrg( ) async {
    String url = "https://test-pranav-kale.000webhostapp.com/scripts/org.php?function=0&name='${this.orgName}'&mail='${this.orgEmail}'&created='${widget.userInfo['username']}'&created_dt='${DateTime.now()}'&mod=&mod_dt='0000-00-00 00:00:00'";
    await http.get( Uri.parse( url ) );
  }

  Future<void> viewOrg( ) async {
    String url = "https://test-pranav-kale.000webhostapp.com/scripts/get.php?table=&condition&post&condition2&post2&custom= * FROM `organization`";
    http.Response response = await http.get( Uri.parse( url ) );
    jsonData = jsonDecode( response.body ) ;

    if( jsonData == 'false') {
      return;
    }

    // clearing organizations list
    organizations.clear();

    for (int j = 0; j < jsonData.length; j++) {
      // adding the information to the organizations list for displaying
      organizations.add( containerBuilder(jsonData[j], true, true ) );
    }
  }

  Future<void> editOrg( String name, String email, String id ) async {
    if( name == "" ) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Invalid Data'),
              content: Text('Organization Name cannot be Empty'),
            );
          }
      );
      return;
    }

    String url = "https://test-pranav-kale.000webhostapp.com/scripts/org.php?function=2&id=$id&name='$name'&mail='$email'&mod='${widget.userInfo['username']}'&mod_dt='${DateTime.now()}'";
    await http.get( Uri.parse( url ) );

    // closing the AlertBox
    Navigator.pop(context);

    // setting the State
    setState( () {} ) ;
  }

  Widget _buildPopupDialog( String name, String email, String id ) {
    this.orgName = name ;
    this.orgEmail = email ;

    return AlertDialog(
      content: Container(
          padding: EdgeInsets.all( 20.0 ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                width: 450,
                child:TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Organization Name',
                  ),
                  onChanged: (value) {
                    this.orgName = value;
                  },
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                width: 450,
                child:TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Organization Email',
                  ),
                  onChanged: (value) {
                    this.orgEmail = value;
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.all( 20.0 ),
                child: MaterialButton(
                  color: Colors.blue,
                  onPressed: () async {
                    await editOrg( this.orgName, this.orgEmail, id );
                  },
                  child: Text(
                    'Edit Organization',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          )
      ),
    );
  }

  Widget containerBuilder( var data, bool addEdit,bool addDelete ) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: MediaQuery.of(context).size.width > 725 ? EdgeInsets.symmetric( vertical: 10.0, horizontal: 7.0 ) : EdgeInsets.symmetric( vertical: 10.0 ),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    // alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric( horizontal: 30.0, ),
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
                            style: TextStyle(
                              fontSize: 24.0,
                            ),
                          ),
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
                        nameController.text= data['org_name'] ;
                        emailController.text= data['org_mail'] ;

                        showDialog(
                            context: context,
                            builder: (BuildContext context) => _buildPopupDialog( data['org_name'], data['org_mail'] , data['org_id'] ),
                        );
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
                  addDelete ?  Container(
                    margin: EdgeInsets.symmetric( horizontal: 4.0 ),
                    child: PopupMenuButton(
                      padding: EdgeInsets.symmetric( vertical: 10.0, horizontal: 10.0, ),
                      offset: Offset(10.0,0.0),
                      icon: Icon( Icons.more_horiz ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 0,
                          child: Text("Manage Organization Admins"),
                        ),
                        PopupMenuItem(
                          value: 2,
                          child: Text("Manage Branches"),
                        ),
                        PopupMenuItem(
                          value: 3,
                          child: Text("Manage Branch Admins"),
                        )
                      ],
                      onSelected: (int value) {
                        if(value == 0) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ManageOrganizationsAdmins( orgID: data['org_id'] , showHamMenu: false, userInfo: widget.userInfo ),
                            )
                          );
                        }
                        else if( value == 2 ){
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ViewBranch( setState: setState, context: context, userInfo: data, showHamMenu: false,  ),
                            ),
                          );
                        }
                        else if( value == 3 ) {
                          Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ManageBranchAdmins( userInfo: data, context: context,  setState: setState, showHamMenu: false, ),
                              )
                          );
                        }
                      },
                    ),
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

  Widget _organizationViewBuilder() {
    return Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height - 80.0 ,
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
                        children: organizations,
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
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: viewOrg(),
        builder: (context,snapshot) {
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
                      onPressed: () {
                        // showing the dialog box to add the new user
                        showDialog(
                            context: context,
                            builder: (BuildContext context ) {
                              return AlertDialog(
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      decoration: InputDecoration(
                                          labelText: "Organization Name"
                                      ),
                                      onChanged: (value) {
                                        this.orgName = value;
                                      },
                                    ),
                                    TextField(
                                      decoration: InputDecoration(
                                          labelText: "Organization Email"
                                      ),
                                      onChanged: (value) {
                                        this.orgEmail = value;
                                      },
                                    ),
                                    MaterialButton(
                                      onPressed: () async {
                                        await insertOrg( );

                                        // popping the current Screen
                                        Navigator.pop(context);

                                        // reloading current screen
                                        setState( () {} );

                                        // showing a AlertDialog
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text("Organization Added"),
                                                content: Text("Organization added to the List"),
                                              );
                                            }
                                        );
                                      },
                                      child: Text("Add"),
                                    ),
                                  ],
                                ),
                              );
                            }
                        );
                      },
                    ),
                  )
                ],
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
                    title: Text( 'View all Organizations', ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context)=> ViewOrganizations( userInfo: widget.userInfo, ),
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
                            builder: (context)=> ManageOrganizationsAdmins( showHamMenu: true, userInfo: widget.userInfo, ),
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
              body: _organizationViewBuilder()
            );
          }
          else if( snapshot.hasError ) {
            return HomeScreenBuilder(
              appbar: AppBar(
                iconTheme: IconThemeData(color: Colors.blueAccent),
                elevation: 0,
                backgroundColor: Colors.transparent,
              ),
              body: Text( snapshot.error.toString() ),
            );
          }
          else {
            return HomeScreenBuilder(
                body:  Container(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                ),
            );
          }
      }
    );
  }
}
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:test_app/Screens/SignUp.dart';
import 'package:test_app/Cards/ManageBranchAdmins.dart';
import 'package:test_app/Templates/GradientContainer.dart';
import 'package:test_app/Templates/HomeScreenBuilder.dart';
import 'package:test_app/utils/CredentialController.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'ManageEmployee.dart';
import 'ManageScanLocations.dart';
import 'ManageShifts.dart';

class ViewBranch extends StatefulWidget {
  final userInfo;
  final context;
  final StateSetter setState;
  List<Widget> branches = [];

  ViewBranch({Key? key, required this.userInfo, this.context, required this.setState}) : super(key: key);

  @override
  ViewBranchState createState() => ViewBranchState();


  // initialize the branches list
  Future<void> init() async {
    String url = "https://test-pranav-kale.000webhostapp.com/scripts/get.php?table=branches&condition=org_id&post=${userInfo['org_id']}&condition2=&post2=&custom";

    http.Response response = await http.get( Uri.parse( url ) ) ;

    if( response.body == 'false' ) {
      print("something went wrong");
    }
    else {
      // decoding the data
      var jsonData = jsonDecode( response.body );

      // clearing the previous list
      branches.clear();

      // insert the data to the branches list
      for (int j = 0; j < jsonData.length ; j++) {
        Map<String, dynamic> data =  jsonData[j];
        branches.add( containerBuilder( data , true , true ) );
      }
    }
  }

  Future<void> insertBranch( String branchName , String address ) async {
    // triming the inputs
    branchName = branchName.trim();
    address = address.trim();

    // checking if branch Name or address is empty, returning if empty
    if( branchName == '' ) {
      showDialog(
          context: context,
          builder: ( BuildContext context ) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: Colors.red,
                  ),
                  Text("Warning")
                ],
              ),
              content: Text("Branch Name cannot be Empty!"),
            );
          }
      );

      return;
    }
    else if( address == '' ) {
      showDialog(
          context: context,
          builder: ( BuildContext context ) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: Colors.red,
                  ),
                  Text("Warning")
                ],
              ),
              content: Text("Address cannot be Empty!"),
            );
          }
      );

      return ;
    }

    String url = "https://test-pranav-kale.000webhostapp.com/scripts/insert_branch.php?org_id='${userInfo['org_id']}'&name='$branchName'&address='$address'";

    http.Response response = await http.get( Uri.parse( url ) ) ;

    if(response.body == 'false' ) {
      showDialog(
          context: context,
          builder: (BuildContext context ) {
            return AlertDialog(
              content: Text("Something Went Wrong "),
            );
          }
      );
    }
    else {
      // closing the previous AlertDialog
      Navigator.pop(context);

      // reloading the screen
      setState( () {
        // reseting the employee list
      } );

      showDialog(
          context: context,
          builder: (BuildContext context ) {
            return AlertDialog(
              content: Text("Branch Added Successfully"),
            );
          }
      );
    }
  }

  Future<void> editBranch( String id, String branchName, String address ) async {
    // triming the inputs
    branchName = branchName.trim();
    address = address.trim();

    // checking if branch Name or address is empty, returning if empty
    if(branchName == '' ) {
      showDialog(
          context: context,
          builder: ( BuildContext context ) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: Colors.red,
                  ),
                  Text("Warning")
                ],
              ),
              content: Text("Branch Name cannot be Empty!"),
            );
          }
      );

      return;
    }
    else if( address == '' ) {
      showDialog(
          context: context,
          builder: ( BuildContext context ) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: Colors.red,
                  ),
                  Text("Warning")
                ],
              ),
              content: Text("Address cannot be Empty!"),
            );
          }
      );

      return ;
    }

    String url = "https://test-pranav-kale.000webhostapp.com/scripts/edit_branch.php?id=$id&name='$branchName'&address='$address'";

    http.Response response  = await http.get( Uri.parse( url ) );

    if( response.body == '1'){

      // closing popup window
      Navigator.pop(context);

      showDialog(
          context: context,
          builder: ( BuildContext context ) {
            return AlertDialog(
              content: Text("Edit saved Successfully"),
            );
          }
      );
    }
    else{
      showDialog(
          context: context,
          builder: ( BuildContext context ) {
            return AlertDialog(
              content: Text('Branch Name Already exists please select a different Name'),
            );
          }
      );
    }
  }

  Future<void> removeBranch( String branchID ) async {
    String url = "https://test-pranav-kale.000webhostapp.com/scripts/delete_branch.php?id=$branchID";

    http.Response response = await http.get( Uri.parse(url) );

    if( response.body == '1') {
      print("Branch Removed");
    }
    else {
      print("Something Went Wrong");
    }
  }

  Widget containerBuilder( data  , bool addEdit,bool addDelete ) {
    return Container(
      alignment: Alignment.centerLeft,
      color: Colors.white60,
      padding: EdgeInsets.all( 20.0 ),
      margin: EdgeInsets.symmetric(vertical: 2.5 ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
              width: 100.0,
              height: 50.0,
              margin: EdgeInsets.symmetric(horizontal: 20.0 ),
              child: Text( data['branch_id'] )
          ),
          Container(
              width: 200.0,
              height: 50.0,
              margin: EdgeInsets.symmetric(horizontal: 20.0 ),
              child: Text( data['branch_name'] )
          ),
          Container(
              width: 300.0,
              height: 50.0,
              margin: EdgeInsets.symmetric(horizontal: 20.0 ),
              child: Text( data['address'] )
          ),
          addEdit ? MaterialButton(
              onPressed: () {
                // edit branch
                showDialog(
                    context: context,
                    builder: (BuildContext context ) {
                      String _branchName = data['branch_name'] ;
                      String _address = data['address'] ;

                      var branchNameController = TextEditingController();
                      var addressController = TextEditingController();

                      branchNameController.text = data['branch_name'] ;
                      addressController.text = data['address'] ;

                      return AlertDialog(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              textDirection: TextDirection.ltr,
                              controller: branchNameController,
                              onChanged: (String value) {
                                // reversing the output value before giving it to the controller
                                _branchName = value  ;
                              },
                              decoration: InputDecoration(
                                labelText: 'branch Name',
                              ),
                            ),

                            TextField(
                              textDirection: TextDirection.ltr,
                              controller: addressController,
                              onChanged: (value) {
                                _address = value;
                              },
                              decoration: InputDecoration(
                                labelText: "Address",
                              ),
                            ),
                            MaterialButton(
                              onPressed: () {
                                // save user changes
                                editBranch( data['branch_id'] , _branchName, _address );

                                setState( () {} );
                              },
                              child: Text("Save"),
                            ),
                          ],
                        ),
                      );
                    }
                );
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
              )
          ) : Container(
            width: 205.0,
          ),
          addDelete ? MaterialButton(
              onPressed: () {
                // delete branch
                removeBranch( data['branch_id'] );

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
            width: 205.0,
          ),
        ],
      ),
    );
  }

  Container branchViewBuilder( ) {
    Map<String, dynamic> header = {
      'branch_id': 'BRANCH ID',
      'branch_name': 'BRANCH NAME',
      'address': 'ADDRESS',
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
                child: containerBuilder( header ,false, false)
            ),
          ),
          Container(
              height: MediaQuery.of(context).size.height - 178.0 ,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child : Container(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: branches,
                    ),
                  ),
                ),
              )
          ),
        ],
      ),
    );
  }
}

class ViewBranchState extends State<ViewBranch>{
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.init(),
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
                    onPressed: () {
                      // showing the insert popup
                      showDialog(
                          context: context,
                          builder: (BuildContext context ) {
                            String brName = "";
                            String address = "";

                            return AlertDialog(
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextField(
                                    onChanged: (value) {
                                      brName = value;
                                    },
                                    decoration: InputDecoration(
                                      labelText: "Branch Name",
                                    ),
                                  ),
                                  TextField(
                                    onChanged: (value) {
                                      address = value;
                                    },
                                    decoration: InputDecoration(
                                      labelText: "Address",
                                    ),
                                  ),
                                  MaterialButton(
                                    onPressed: () async {
                                      // adding the new branch
                                      widget.insertBranch(brName, address);
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
              backgroundColor: Color(0xFF10B5FC),
              title: Text( "View Branches" ),
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
                        builder: (context) => ViewBranch( context: context, setState: setState, userInfo: widget.userInfo ),
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
            ),
            body: widget.branchViewBuilder()
          );
        }
        else {
          return HomeScreenBuilder(
              appbar: AppBar(
                backgroundColor: Color(0xFF10B5FC),
                title: Text( "View Branches" ),
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
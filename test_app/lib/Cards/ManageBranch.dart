import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:test_app/Screens/SignUp.dart';
import 'package:test_app/Cards/ManageBranchAdmins.dart';
import 'package:test_app/Templates/GradientContainer.dart';
import 'package:test_app/Templates/HomeScreenBuilder.dart';
import 'package:test_app/utils/CredentialController.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class ViewBranch extends StatefulWidget {
  final userInfo;

  ViewBranch({Key? key, required this.userInfo }) : super(key: key);

  @override
  _ViewBranchState createState() => _ViewBranchState();
}

class _ViewBranchState extends State<ViewBranch> {

  List<Widget> branches = [];

  // initialize the branches list
  Future<void> _init() async {
    String url = "https://test-pranav-kale.000webhostapp.com/scripts/get.php?table=branches&condition=org_id&post=${widget.userInfo['org_id']}&condition2=&post2=";

    http.Response response = await http.get( Uri.parse( url ) ) ;

    if( response.body == 'false' ) {
      print("something went wrong");
    }
    else {
      // decoding the data
      var data = jsonDecode( response.body );

      // clearing the previous list
      branches.clear();

      // insert the data to the branches list
      for (int j = 0; j < data.length ; j++) {
        Map<String, dynamic> jsonData = jsonDecode( data[j]);
        branches.add( containerBuilder( jsonData['org_id'], jsonData['branch_id'], jsonData['branch_name'], jsonData['address'], true , true ) );
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

    String url = "https://test-pranav-kale.000webhostapp.com/scripts/insert_branch.php?org_id='${widget.userInfo['org_id']}'&name='$branchName'&address='$address'";

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
      setState( () {} );

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

  Widget containerBuilder( String id , String  branchID, String branchName ,String  address , bool addEdit,bool addDelete ) {
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
              child: Text( id )
          ),
          Container(
              width: 100.0,
              height: 50.0,
              margin: EdgeInsets.symmetric(horizontal: 20.0 ),
              child: Text( branchID )
          ),
          Container(
              width: 200.0,
              height: 50.0,
              margin: EdgeInsets.symmetric(horizontal: 20.0 ),
              child: Text( branchName )
          ),
          Container(
              width: 300.0,
              height: 50.0,
              margin: EdgeInsets.symmetric(horizontal: 20.0 ),
              child: Text( address )
          ),
          addEdit ? MaterialButton(
              onPressed: () {
                // edit branch
                showDialog(
                  context: context,
                  builder: (BuildContext context ) {
                    String _branchName = branchName ;
                    String _address = address ;

                    var branchNameController = TextEditingController();
                    var addressController = TextEditingController();

                    branchNameController.text = branchName ;
                    addressController.text = address ;

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
                                editBranch( branchID , _branchName, _address );

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
                removeBranch( branchID );

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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _init(),
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
                                      insertBranch(brName, address);
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
                        builder: (context) => ViewBranch( userInfo: widget.userInfo ),
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
                        builder: (context) => ManageBranchAdmins(userInfo: widget.userInfo, ),
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
            body: Container(
              color: Colors.blueAccent,
              alignment: Alignment.center,
              child: Column(
                children: [
                  Container(
                    width: 1400.0,
                    alignment: Alignment.center,
                    child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: containerBuilder( "ID", 'BRANCH ID', 'BRANCH NAME', 'ADDRESS',false, false)
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
                              children: branches,
                            ),
                          ),
                        ),
                      )
                    ),
                ],
              ),
            ),
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
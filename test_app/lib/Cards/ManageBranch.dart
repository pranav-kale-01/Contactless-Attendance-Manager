import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:test_app/Cards/ManageBranchAdmins.dart';
import 'package:test_app/Cards/ManageEmployee.dart';
import 'package:test_app/Cards/ManageScanLocations.dart';
import 'package:test_app/Cards/ManageShifts.dart';
import 'package:test_app/Cards/UserDetails.dart';
import 'package:test_app/Screens/SignUp.dart';
import 'package:test_app/Templates/GradientContainer.dart';
import 'package:test_app/Templates/HomeScreenBuilder.dart';
import 'package:test_app/utils/CredentialController.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class ViewBranch extends StatefulWidget {
  final userInfo;
  final context;
  final StateSetter setState;
  bool showHamMenu = true;
  List<Widget> branches = [];

  ViewBranch({Key? key, required this.userInfo, this.context, required this.setState, showHamMenu }) : super(key: key) {
    if( showHamMenu != null ) {
      this.showHamMenu = showHamMenu;
    }
  }

  @override
  ViewBranchState createState() => ViewBranchState();
}

class ViewBranchState extends State<ViewBranch>{
  Map<String, dynamic> header = {
    'branch_id': 'BRANCH ID',
    'branch_name': 'BRANCH NAME',
    'address': 'ADDRESS',
  };

  // initialize the branches list
  Future<void> init() async {
    String url = "https://test-pranav-kale.000webhostapp.com/scripts/get.php?table=branches&condition=org_id&post=${widget.userInfo['org_id']}&condition2=&post2=&custom";

    http.Response response = await http.get( Uri.parse( url ) ) ;

    if( response.body == 'false' ) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text("Unable to Connect to Server"),
        ),
      );
    }
    else {
      // decoding the data
      var jsonData = jsonDecode( response.body );

      // clearing the previous list
      widget.branches.clear();

      // insert the data to the branches list
      for (int j = 0; j < jsonData.length ; j++) {
        Map<String, dynamic> data =  jsonData[j];
        widget.branches.add( containerBuilder( data , true , true ) );
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

    String url = "https://test-pranav-kale.000webhostapp.com/scripts/branch.php?function=0&org_id='${widget.userInfo['org_id']}'&name='$branchName'&address='$address'&created='${widget.userInfo['username']}'&created_dt='${DateTime.now()}'&mod=NULL&mod_dt='00:00:00'";

    http.Response response = await http.get( Uri.parse( url ) ) ;

    print( response.body );

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

    String url = "https://test-pranav-kale.000webhostapp.com/scripts/branch.php?function=2&id=$id&name='$branchName'&address='$address'&mod='${widget.userInfo['username']}'&mod_dt='${DateTime.now()}'";

    print(url);

    http.Response response  = await http.get( Uri.parse( url ) );


    if( response.body == '1'){

      setState( () {} );

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
    String url = "https://test-pranav-kale.000webhostapp.com/scripts/branch.php?function=1&id=$branchID";

    http.Response response = await http.get( Uri.parse(url) );

    if( response.body == '1') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text("Branch Removed"),
        ) ,
      );
      setState( () {} );
    }
    else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text("Something Went Wrong"),
        ),
      );
    }
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
                          child: Text( this.header['branch_name'] ),
                        ),
                        Container(
                          // color: Colors.red,
                          margin: EdgeInsets.symmetric( vertical: 4.0 ),
                          child: Text( this.header['address'].toString() ),
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
                              data['branch_name'],
                              style: TextStyle(
                                fontSize: 22.0,
                              )
                          ),
                        ),
                        Container(
                          height: 15.0,
                          alignment: Alignment.centerLeft,
                          // color: Colors.red,
                          margin: EdgeInsets.symmetric( vertical: 4.0 ),
                          child: Text( data['address'] ),
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
                          // remove branch
                          removeBranch( data['branch_id'] );
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

  Container branchViewBuilder( ) {
    return Container(
      // color: Colors.blueAccent,
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
              height: MediaQuery.of(context).size.height - 178.0 ,
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
                        children: widget.branches,
                      ),
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
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: this.init(),
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
                                            this.insertBranch(brName, address);

                                            setState( () {} );
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
                    title: Text(
                        "View Branches",
                        style: TextStyle(
                          color: Colors.blueAccent,
                        ),
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
                        child: IconButton(
                          onPressed: () {
                            // opening the UesrDetails Panel
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => UserDetails( userInfo: widget.userInfo,),
                              ),
                            );
                          },
                          icon: Icon( Icons.account_circle ),
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
                  ) : null ,
                  body: this.branchViewBuilder()
              );
        }
        else {
          return HomeScreenBuilder(
              appbar: AppBar(
                automaticallyImplyLeading: false,
                iconTheme: IconThemeData(color: Colors.blueAccent),
                elevation: 0,
                backgroundColor: Colors.transparent,
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
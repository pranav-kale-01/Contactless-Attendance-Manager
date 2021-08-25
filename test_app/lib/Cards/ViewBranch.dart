import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:test_app/Screens/SignUp.dart';
import 'package:test_app/Templates/GradientContainer.dart';
import 'package:test_app/Templates/HomeScreenBuilder.dart';
import 'package:test_app/utils/CredentialController.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class ViewBranch extends StatefulWidget {
  var userInfo;

  ViewBranch({Key? key, required this.userInfo }) : super(key: key);

  @override
  _ViewBranchState createState() => _ViewBranchState();
}

class _ViewBranchState extends State<ViewBranch> {

  List<Widget> branches = [];
  late ScrollController scrollController1 = ScrollController();
  late ScrollController scrollController2 = ScrollController();


  // initialize the branches list
  Future<void> _init() async {
    String url = "https://test-pranav-kale.000webhostapp.com/scripts/get.php?table=branches";

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

        branches.add( ContainerBuilder( jsonData['org_id'], jsonData['branch_id'], jsonData['branch_name'], jsonData['address'], true , true ) );
      }

      // adding listeners to ScrollController1 and scrollController2
      scrollController1.addListener(() {
        scrollController2.animateTo(
            scrollController1.offset,
            duration: Duration(milliseconds:1),
            curve: Curves.bounceInOut
        );
      });

      scrollController2.addListener(() {
        scrollController1.animateTo(
            scrollController2.offset,
            duration: Duration(milliseconds:1),
            curve: Curves.bounceInOut
        );
      });
    }
  }

  Widget ContainerBuilder( String ID , String  branchID, String branchName ,String  address , bool addEdit,bool addDelete ) {
    return Container(
      alignment: Alignment.centerLeft,
      color: Colors.white60,
      padding: EdgeInsets.all( 20.0 ),
      margin: EdgeInsets.symmetric(vertical: 2.5 ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
              width: 150.0,
              height: 50.0,
              margin: EdgeInsets.symmetric(horizontal: 20.0 ),
              child: Text( ID )
          ),
          Container(
              width: 150.0,
              height: 50.0,
              margin: EdgeInsets.symmetric(horizontal: 20.0 ),
              child: Text( branchID )
          ),
          Container(
              width: 150.0,
              height: 50.0,
              margin: EdgeInsets.symmetric(horizontal: 20.0 ),
              child: Text( branchName )
          ),
          Container(
              width: 150.0,
              height: 50.0,
              margin: EdgeInsets.symmetric(horizontal: 20.0 ),
              child: Text( address )
          ),
          addEdit ? MaterialButton(
              onPressed: () { },
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
              onPressed: () { },
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
                            String br_name = "";
                            String address = "";


                            return AlertDialog(
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextField(
                                    onChanged: (value) {
                                      br_name = value;
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
                                      String url = "https://test-pranav-kale.000webhostapp.com/scripts/insert_branch.php?org_id='${widget.userInfo['org_id']}'&name='$br_name'&address='$address'";

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
                                        // closing the previos AlertDialog
                                        Navigator.pop(context);

                                        // reloading the screen
                                        setState( () {} );

                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context ) {
                                            return AlertDialog(
                                              content: Text("User Added Successfully"),
                                            );
                                          }
                                        );
                                      }
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
                  title: Text( 'View branches', ),
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
                        controller: scrollController2,
                        child: ContainerBuilder( "ID", 'BRANCH ID', 'BRANCH NAME', 'ADDRESS',false, false)
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height - 151.0 ,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        controller: scrollController1,
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
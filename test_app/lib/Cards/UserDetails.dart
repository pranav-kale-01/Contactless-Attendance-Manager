import 'package:flutter/material.dart';

import 'ChangePassword.dart';

class UserDetails extends StatefulWidget {
  var userInfo;

  UserDetails({Key? key, required this.userInfo }) : super(key: key);

  @override
  _UserDetailsState createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  Future<void> init() async {
    String url = "";
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: init(),
        builder: (context,snapshot ) {
          if( snapshot.connectionState == ConnectionState.done ) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Color(0xFF101B3E),
                automaticallyImplyLeading: true,
              ),
              body: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        color: Color(0xFF101B3E),
                        height: MediaQuery.of(context).size.height / 5,
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height - MediaQuery.of(context).size.height / 5,
                        color: Colors.white,
                        child: MediaQuery.of(context).size.width > 725 ? Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.height /3,
                              decoration: BoxDecoration(
                                // color: Colors.red,
                                border: Border( right: BorderSide( color: Colors.black ) ),
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.symmetric( vertical: 10.0, ),
                                      width: MediaQuery.of(context).size.width / 8 ,
                                      height: MediaQuery.of(context).size.width / 8,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular( 100.0 )
                                      ),
                                      child: Icon(
                                        Icons.account_circle_sharp,
                                        color: Colors.grey,
                                        size: MediaQuery.of(context).size.width / 11,
                                      ),
                                    ),
                                    Container(
                                      height: MediaQuery.of(context).size.height / 1.5,
                                      color: Color( 0xFFd6d6d6 ),
                                      child: Column(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context).size.height / 2,
                                            alignment: Alignment.centerLeft,
                                            padding: EdgeInsets.only( left: 4.0, top: 10.0, ),
                                            child: Text('User ID'),
                                          ),
                                          Container(
                                            decoration:  BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular( 8.0, ),
                                            ),
                                            padding: EdgeInsets.all( 10.0 ),
                                            margin: EdgeInsets.symmetric( vertical: 5.0, horizontal: 2.0, ),
                                            width: MediaQuery.of(context).size.height / 2,
                                            child: Text(
                                                widget.userInfo['UID'].toString(),
                                                style: TextStyle(
                                                    fontSize: 16.0,
                                                    fontWeight: FontWeight.w400
                                                )
                                            ),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context).size.height / 2,
                                            alignment: Alignment.centerLeft,
                                            padding: EdgeInsets.only( left: 4.0, top: 10.0, ),
                                            child: Text('UserName'),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular( 8.0, ),
                                            ),
                                            padding: EdgeInsets.all( 10.0 ),
                                            margin: EdgeInsets.symmetric( vertical: 5.0, horizontal: 2.0, ),
                                            width: MediaQuery.of(context).size.height / 2,
                                            child: Text(
                                                widget.userInfo['username'].toString(),
                                                style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.w400,
                                                )
                                            ),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context).size.height / 2,
                                            alignment: Alignment.centerLeft,
                                            padding: EdgeInsets.only( left: 4.0, top: 10.0, ),
                                            child: Text('Organization ID'),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular( 8.0, ),
                                            ),
                                            padding: EdgeInsets.all( 10.0 ),
                                            margin: EdgeInsets.symmetric( vertical: 5.0, horizontal: 2.0, ),
                                            width: MediaQuery.of(context).size.height / 2,
                                            child: Text(
                                                widget.userInfo['org_id'].toString(),
                                                style: TextStyle(
                                                    fontSize: 16.0,
                                                    fontWeight: FontWeight.w400
                                                )
                                            ),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context).size.height / 2,
                                            alignment: Alignment.centerLeft,
                                            padding: EdgeInsets.only( left: 4.0, top: 10.0, ),
                                            child: Text('Branch ID'),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular( 8.0, ),
                                            ),
                                            padding: EdgeInsets.all( 10.0 ),
                                            margin: EdgeInsets.symmetric( vertical: 5.0, horizontal: 2.0, ),
                                            width: MediaQuery.of(context).size.height / 2,
                                            child: Text(
                                                widget.userInfo['branch_id'].toString(),
                                                style: TextStyle(
                                                    fontSize: 16.0,
                                                    fontWeight: FontWeight.w400
                                                )
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Container(
                                width: MediaQuery.of(context).size.width - MediaQuery.of(context).size.width / 3  ,
                                decoration: BoxDecoration(
                                  border: Border( right: BorderSide( color: Color( 0xFF222424 ) ) ),
                                ),
                                child: Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      MouseRegion(
                                        cursor:  SystemMouseCursors.click,
                                        child: GestureDetector(
                                          onTap: () {
                                            // navigating to Change password page
                                            Navigator.of(context).push(
                                              PageRouteBuilder(
                                                opaque: false,
                                                pageBuilder: (context, _ , __ ) => ChangePassword( userInfo: widget.userInfo ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.lightBlue,
                                              border: Border.all( color: Colors.blueAccent ),
                                              borderRadius: BorderRadius.circular( 8.0, ),
                                            ),
                                            margin: EdgeInsets.only( left: MediaQuery.of(context).size.width / 9, top: 40.0, bottom: 40.0, ),
                                            padding: EdgeInsets.symmetric( vertical: 4.0, horizontal: 8.0, ),
                                            child: Text(
                                              'Change Password',
                                              style: TextStyle(
                                                fontSize: 28.0,
                                                fontWeight: FontWeight.w300,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 1.0,
                                        width: MediaQuery.of(context).size.width - MediaQuery.of(context).size.width / 3,
                                        child: Container(
                                          color: Color(0xFF222424),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                            )
                          ],
                        ) : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.height /3,
                              decoration: BoxDecoration(

                                border: Border( bottom: BorderSide( color: Colors.black ) ),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    margin: EdgeInsets.symmetric( vertical: 10.0, ),
                                    width: MediaQuery.of(context).size.width / 8 ,
                                    height: MediaQuery.of(context).size.width / 8,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular( 100.0 )
                                    ),
                                    child: Icon(
                                      Icons.account_circle_sharp,
                                      color: Colors.grey,
                                      size: MediaQuery.of(context).size.width / 11,
                                    ),
                                  ),
                                  Container(
                                    child: Text(
                                        "Username",
                                        style: TextStyle(
                                            fontSize: 32.0,
                                            fontWeight: FontWeight.w400
                                        )
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              color: Colors.white,
                              width: MediaQuery.of(context).size.height - MediaQuery.of(context).size.height / 3,
                            )
                          ],
                        ),
                      ),
                    ],
                  )
              ),
            );
          }
          else {
            return Scaffold(
              body: Column(
                children: [
                  Container(
                    color: Color(0xFF101B3E),
                    height: MediaQuery.of(context).size.height / 5,
                  ),
                  Container(
                    alignment: Alignment.center,
                    color: Colors.white,
                    height: MediaQuery.of(context).size.height - MediaQuery.of(context).size.height / 5,
                    child: CircularProgressIndicator(),
                  )
                ],
              )
            );
          }
        }
    );


  }
}

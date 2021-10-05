import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class ChangePassword extends StatelessWidget {
  var userInfo;

  ChangePassword({Key? key, required this.userInfo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController tf1Controller = new TextEditingController();
    TextEditingController tf2Controller = new TextEditingController();

    return Scaffold(
      body: Container(
        child: Column(
          children: [
            Container(
              color: Color(0xFF101B3E),
              height: MediaQuery.of(context).size.height / 5,
            ),
            Container(
                height: MediaQuery.of(context).size.height - MediaQuery.of(context).size.height / 5,
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width > 700 ? MediaQuery.of(context).size.width / 3 : MediaQuery.of(context).size.width,
                      child: TextField(
                        controller: tf1Controller,
                        decoration: InputDecoration(
                          labelText: "New password",
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width > 700 ? MediaQuery.of(context).size.width / 3 : MediaQuery.of(context).size.width,
                      child: TextField(
                        controller: tf2Controller,
                        decoration: InputDecoration(
                            labelText: "Confirm password",
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width > 700 ? MediaQuery.of(context).size.width / 3 : MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric( vertical: 10.0, ),
                      padding: EdgeInsets.symmetric(  vertical: 10.0, ),
                      child: MaterialButton(
                        onPressed: () async {
                          // checking if the password is same as confirm password
                          if( tf1Controller.text != tf2Controller.text ) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                content: Text("Passwords do not match, Please Enter again"),
                              ),
                            );

                            return;
                          }
                          else {
                            // setting the value as the new password
                            String url = "https://test-pranav-kale.000webhostapp.com/scripts/user.php?function=3&id=${this.userInfo['UID']}&pass=${tf1Controller.text}&mod='${this.userInfo['username']}'&mod_dt='${DateTime.now()}'";

                            print( url );

                            http.Response response = await http.get( Uri.parse( url ) );

                            print( response.body );

                            if( response.body == '1' ) {
                              // going back to previous screen
                              Navigator.of(context).pop();

                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  content: Text("Password Updated Successfully!"),
                                ),
                              );
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
                        },
                        child: Text("Confirm"),
                      ),
                    ),
                  ],
                )
            ),
          ],
        ),
      ),
    );
  }
}


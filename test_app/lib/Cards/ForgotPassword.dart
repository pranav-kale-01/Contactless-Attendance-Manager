import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_sms/flutter_sms.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPassword extends StatefulWidget {
  List<Widget> Pages = [];
  int pageNumber =0 ;

  ForgotPassword({Key? key}) : super(key: key);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  Future<void> sendOTP( List<String> recipents) async {
      String message = "test";

      print( recipents );


      await launchSms(
        message: message,
        number: recipents[0],
      );

      String _result = await sendSMS(message: message, recipients: recipents)
          .catchError((onError) {
        print(onError);
      });

      print(_result);
  }

  Future<void> init() async {
    TextEditingController usernameController = TextEditingController();

    // Page 1
    widget.Pages.add(
        TextField( ),
        /*
        SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: Color(0xFF101B3E),
                height: MediaQuery.of(context).size.height / 6,
              ),
              Container(
                  color: Colors.white,
                  height: MediaQuery.of(context).size.height - MediaQuery.of(context).size.height / 6,
                  padding: EdgeInsets.only( top: 40.0, ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Enter you Username',
                      ),
                      Container(
                          width: MediaQuery.of(context).size.width > 700 ? MediaQuery.of(context).size.width / 4 : MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only( bottom: 20.0, left: 10.0, right: 10.0),
                          child: TextField(
                            textDirection: TextDirection.ltr,
                            controller: usernameController,
                          )
                      ),
                      MaterialButton(
                        onPressed: () async {
                          // checking if any user with this username exists
                          String url = "https://test-pranav-kale.000webhostapp.com/scripts/get.php?table=scans&condition&post&condition2&post2&custom= `users`.`recovery_mob` FROM `users` WHERE `users`.`username` = '${usernameController.text}'";

                          http.Response response = await http.get( Uri.parse( url ) );

                          if( response.body == '[]') {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    content: Text('Invalid Username!'),
                                  );
                                }
                            );
                          }
                          else
                          {
                            List<dynamic> jsonData = jsonDecode( response.body );
                            String rec_mob = jsonData[0]['recovery_mob'];

                            if( rec_mob.length != 10 || isNumeric( rec_mob ) == false ) {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context ) {
                                    return AlertDialog(
                                      title: Text("Invalid Recovery Mobile Number"),
                                    );
                                  }
                              );
                              return;
                            }
                            else {
                              widget.pageNumber++;
                              await sendOTP( [rec_mob] );
                              // setState( () {} );
                            }
                          }
                        },
                        child: Text("Next"),
                      )
                    ],
                  ),
              )
            ],
          ),
        )
        */
    );

    TextEditingController OTPController = TextEditingController();

    // Page 2
    widget.Pages.add(
        Container(
          alignment: Alignment.center,
          child: Column(
            children: [
              Container(
                color: Color(0xFF101B3E),
                height: MediaQuery.of(context).size.height / 6,
              ),
              Container(
                color: Colors.white,
                height: MediaQuery.of(context).size.height - MediaQuery.of(context).size.height / 6,
                child: Column(
                  children: [
                    Text("Verify Mobile Number"),
                    Text("OTP has been sent to you on your mobile number. please enter it below"),
                    Container(
                        width: MediaQuery.of(context).size.width > 700 ? MediaQuery.of(context).size.width / 3 : MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only( bottom: 20.0, left: 10.0, right: 10.0),
                        child: TextField(
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          keyboardType: TextInputType.number,
                          controller: OTPController,
                        ),
                    ),
                    MaterialButton(
                      onPressed: () {

                      },
                      child: Text("RESEND "),
                    )
                  ],
                )
              )
            ],
          ),
        )
    );

    // Page 3
    widget.Pages.add(
        Container(
          alignment: Alignment.center,
          child: Text("page 3"),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: init(),
      builder: (context, snapshot) {
        return Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.white,
            body: snapshot.connectionState == ConnectionState.done ? Container(
              height:100.0,
                  alignment: Alignment.center,
                  child: TextField()
            ) : Container(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
            ),
        );
      }
    );


    //     if( ) {
    //       return Scaffold(
    //         resizeToAvoidBottomInset: false,
    //         backgroundColor: Colors.white,
    //         body: Container(
    //           alignment: Alignment.center,
    //             child: TextField()
    //         ),
    //         // body: widget.Pages[widget.pageNumber],
    //       );
    //     }
    //     else if( snapshot.hasError ) {
    //       return Scaffold(
    //         appBar: AppBar(
    //           iconTheme: IconThemeData(color: Colors.blueAccent),
    //           elevation: 0,
    //           backgroundColor: Colors.transparent,
    //         ),
    //         body: Container(
    //           child: Text( snapshot.error.toString() ),
    //         ),
    //       );
    //     }
    //     else {
    //       return Scaffold(
    //         backgroundColor: Colors.white,
    //         body: Container(
    //           alignment: Alignment.center,
    //           child: CircularProgressIndicator(),
    //         ),
    //       );
    //     }
    //   }
    // );
  }
}
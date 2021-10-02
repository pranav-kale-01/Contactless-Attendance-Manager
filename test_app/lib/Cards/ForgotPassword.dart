import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:twilio_flutter/twilio_flutter.dart';

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
  late TwilioFlutter twilioFlutter;
  TextEditingController usernameController = TextEditingController();

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  @override
  void initState() {
    this.twilioFlutter = TwilioFlutter(
        accountSid: 'AC9150947f13126d7b6d22a5d67b497be7',
        authToken: '2d092b506cdd34d27ffb75e0962ec16f',
        twilioNumber: '+18144027693'
    );
    super.initState();
  }

  void sendSms( String mob ) async {
    print( "+91" + mob );

    twilioFlutter.sendSMS(
        toNumber: '+91' + mob , messageBody: 'Hii You will have a OTP here'
    );
  }

  void getSms() async {
    var data = await twilioFlutter.getSmsList();
    print(data);

    await twilioFlutter.getSMS('AC9150947f13126d7b6d22a5d67b497be7');
  }

  Widget Page2( String mob_no ) {
    sendSms( mob_no );

    TextEditingController OTPController = TextEditingController();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    Container(
                        padding: EdgeInsets.symmetric( horizontal: 16.0, vertical: 20.0, ),
                        child: Text(
                            "Verify Mobile Number",
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.w700,
                            ),
                        ),
                    ),
                    Container(
                        padding: EdgeInsets.symmetric( horizontal: 16.0, vertical: 20.0, ),
                        child: Text(
                            "OTP has been sent to you on your mobile number. please enter it below",
                            textAlign: TextAlign.center,
                        )
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width > 700 ? MediaQuery.of(context).size.width / 3 : MediaQuery.of(context).size.width,
                      margin: EdgeInsets.only( bottom: 20.0, left: 16.0, right: 16.0),
                      child: TextField(
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24.0,
                        ),
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
                        this.initState();
                        sendSms( mob_no );
                      },
                      child: Text("RESEND "),
                    )
                  ],
                )
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Container(
          height:  MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                            textAlign: TextAlign.center,
                          )
                      ),
                      MaterialButton(
                        onPressed: () async {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              opaque: false,
                               pageBuilder: (context, _ , __ ) => Container( color:  Colors.black54, ),
                            ),
                          );

                          // checking if any user with this username exists
                          String url = "https://test-pranav-kale.000webhostapp.com/scripts/get.php?table=scans&condition&post&condition2&post2&custom= `users`.`recovery_mob` FROM `users` WHERE `users`.`username` = '${usernameController.text}'";

                          http.Response response = await http.get( Uri.parse( url ) );

                          print( response.body );

                          if( response.body == '[]') {
                            Navigator.pop( context );

                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    content: Text('Invalid Username!'),
                                  );
                                }
                            );
                            return;
                          }
                          else
                          {
                            List<dynamic> jsonData = jsonDecode( response.body );
                            String rec_mob = jsonData[0]['recovery_mob'];

                            if( rec_mob.length != 10 || isNumeric( rec_mob ) == false ) {
                              Navigator.pop( context );

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
                              Navigator.pop( context );

                              Navigator.of( context ).push(
                                PageRouteBuilder(
                                  opaque: false,
                                  pageBuilder: (context, _, __ ) => Page2( rec_mob ),
                                )
                              );
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
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

import 'package:test_app/Screens/Home.dart';
import 'package:test_app/utils/CredentialController.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:http/http.dart' as  http ;
import 'dart:convert';

class SignUp extends StatelessWidget {
  late String _email;
  late String _pass;
  late String statusString;

  Future<void> registerToFb(BuildContext context) async {
    print( 'test' );

    // getting the uid for current mail ID
    String url = "https://test-pranav-kale.000webhostapp.com/scripts/sign_in.php?mail='${this._email}'";

    http.Response response = await http.get( Uri.parse( url ) );

    print( response.body ) ;
    print("test");

    if( response.body == 'no-user' ) {
      // this means that there is no user with provided credentials
      showDialog(
          context: context,
          builder: (BuildContext context ){
            return AlertDialog(
              title: Text("Error"),
              content:  Text('User not Registered'),
              actions: [
                TextButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }
                ),
              ]
            );
          }
      );
    }
    else {
      var data = jsonDecode(response.body);

      // checking if the password matches
      if( data['password'] == this._pass ) {
        // directing the user to home Screen
        Navigator.pushReplacement(
          context, MaterialPageRoute(
          builder: (context) => Home( email: this._email, uid: data['UID'] ),
        ),
        );
      }
      else {
        showDialog(
            context: context,
            builder: (BuildContext context ) {
              return AlertDialog(
                title: Text("Incorrect password"),
                content: Text('The entered password is incorrect please re-enter the password'),
              );
            }
        );

        return;
      }

      // providing CredentialController current credentials
      if( !kIsWeb ) {
        await CredentialController.writeFile( "{ \"user\": \"${this._email}\", \"pass\": \"${this._pass}\" }" );
      }

      // directing the user to home Screen
      Navigator.pushReplacement(
        context, MaterialPageRoute(
          builder: (context) => Home( email: this._email, uid: data['UID'] ),
        ),
      );
    }
  }

  @override
  Widget build( BuildContext context ) {
    return Scaffold(
        body: Center(
          child: Container(
            alignment: Alignment.center,
            width: 400.0,
            child: SafeArea(
                child: Container(
                  padding: EdgeInsets.all( 20.0 ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextField(
                        onChanged: (value) {
                          this._email = value;
                        },
                        decoration: InputDecoration(
                          labelText: 'email',
                        ),
                      ),
                      TextField(
                        onChanged: (value) {
                          this._pass = value;
                        },
                        decoration: InputDecoration(
                          labelText: 'password',
                        ),
                        obscureText: true,
                      ),
                      Container(
                        margin: EdgeInsets.symmetric( vertical: 30.0 ) ,
                        child: MaterialButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            color: Colors.blue,
                            onPressed: () {
                                registerToFb( context );
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric( vertical: 10.0, horizontal: 20.0),
                              child: Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 30.0,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white,
                                  )
                              ),
                            ),
                        ),
                      ),
                    ],
                  ),
                )
            ),
          ),
        )
    );
  }
}
import 'package:flutter/material.dart';

import 'package:test_app/Screens/Home.dart';
import 'package:test_app/Screens/SignUp.dart';

import 'package:test_app/utils/CredentialController.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:http/http.dart' as http ;
import 'dart:convert';

class IntroScreen extends StatelessWidget {
  late bool hasUser;
  var data;
  var uid;

  Future<void> _init() async {
    print("_init() starts");

    if( !kIsWeb ) {
      // checking if Credential controller has any user data
      String user = '';
      try {
        user = await CredentialController.readFile();
      }
      catch( e ) {
        // if the operation of reading the file throw an exception then redirecting the user to the login page
        this.hasUser = false ;
        return;
      }

      if( user == '' ) {
        this.hasUser = false;
        return;
      }

      this.hasUser = true;

      // decoding the user data
      data = jsonDecode(user);

      // getting the uid for the user
      String url = "https://test-pranav-kale.000webhostapp.com/scripts/sign_in.php?mail='${data['user']}'";

      http.Response response = await http.get( Uri.parse( url ) );

      if( response.body == 'no-user' ) {
        this.hasUser = false;
        return;
      }

      // assigning the UID
      this.uid = jsonDecode( response.body )['UID'];

      this.hasUser = true;
      return;
    }

    this.hasUser = false;
  }

  @override
  Widget build( BuildContext context ){
    return FutureBuilder(
      future: _init(),
      builder: ( context, snapshot) {
        if( snapshot.connectionState == ConnectionState.done ) {
          if( this.hasUser ) {
            if( data['user'] == null || this.uid == null ){
              snapshot.connectionState == ConnectionState.waiting;
              _init();
            }
            return Home( email: data['user'], uid: this.uid );
          }
          else {
            return SignUp();
          }
        }
        else {
          return Scaffold(
            body: SafeArea(
              child: Container(
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
      }
    );
  }
}
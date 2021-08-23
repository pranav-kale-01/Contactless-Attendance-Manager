import 'package:flutter/material.dart';

import 'package:test_app/Screens/Home.dart';
import 'package:test_app/Screens/SignUp.dart';

import 'package:test_app/utils/CredentialController.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:http/http.dart' as http ;
import 'dart:convert';

class IntroScreen extends StatelessWidget {
  late bool has_user;
  var data;
  var uid;

  Future<void> _init() async {
    if( !kIsWeb ) {
      // checking if Credential controller has any user data
      String user = await CredentialController.readFile();

      if( user == '' ) {
        this.has_user = false ;
        return;
      }

      data = jsonDecode(user);

      // getting the uid for the user
      String url = "https://test-pranav-kale.000webhostapp.com/scripts/sign_in.php?mail='${data['user']}'";

      http.Response response = await http.get( Uri.parse( url ) );

      if( response.body == 'no-user' ) {
        this.has_user = false;
        return;
      }

      // assigning the UID
      var uid = jsonDecode(response.body);
      this.uid = uid['UID'];

      this.has_user = true;
      return;

    }

    this.has_user = false;
    return;
  }

  @override
  Widget build( BuildContext context ){
    return FutureBuilder(
      future: _init(),
      builder: ( context, snapshot) {
        if( snapshot.connectionState == ConnectionState.done ) {
          return this.has_user ? Home( email: data['user'], uid: this.uid ) : SignUp();
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
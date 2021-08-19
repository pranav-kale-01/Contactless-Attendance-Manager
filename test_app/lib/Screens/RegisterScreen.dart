import 'package:flutter/material.dart';

import 'package:test_app/Screens/Home.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatelessWidget {
  late String _email;
  late String _pass;
  late String statusString;
  late Map<String,dynamic> data;

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future<void> registerUser(BuildContext context) async {

    // register the user on firebase authentication system
    await firebaseAuth
        .createUserWithEmailAndPassword(
      email: this._email,
      password: this._pass,
    )
      .then( (result) async {
      // adding the user details to the mysql database
      String url = "https://test-pranav-kale.000webhostapp.com/scripts/insert.php?id='${result.user!.uid}'&user='${result.user!.email}'&authority='emp'";
      print( url );

      http.Response response = await http.get(
          Uri.parse( url ),
          headers: {
            "Accept": "application/json",
            "Access-Control-Allow-Origin": "*",
          }
      );
      print( response.body );

      // directing to the Home screen
      Navigator.pushReplacement(
          context, MaterialPageRoute(
          builder: (context) => Home( email: result.user!.email! ),
        ),
        );
      })
      .catchError( (err) {
        showDialog(
          context: context,
          builder: (BuildContext context ){
            return AlertDialog(
                title: Text("Error"),
                content:  Text(err.message),
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
      });
  }

  @override
  Widget build( BuildContext context ) {
    return Scaffold(
        body: SafeArea(
            child: Column(
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
                MaterialButton(
                  onPressed: () async {
                    await registerUser( context );
                  },
                  child: Text('Register'),
                ),
              ],
            )
        )
    );
  }
}
import 'package:flutter/material.dart';

import 'package:test_app/Screens/Home.dart';
import 'package:test_app/Screens/RegisterScreen.dart';

import 'package:firebase_auth/firebase_auth.dart';

class SignUp extends StatelessWidget {
  late String _email;
  late String _pass;
  late String statusString;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  void registerToFb(BuildContext context){
    firebaseAuth
      .signInWithEmailAndPassword(
        email: this._email,
        password: this._pass,
    ).then( (result) {
      Navigator.pushReplacement(
        context, MaterialPageRoute(
          builder: (context) => Home( email: result.user!.email! ),
        ),
      );
    }).catchError( (err) {
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
                    onPressed: () {
                        registerToFb( context );
                    },
                    child: Text('Sign In'),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterScreen(),
                        ),
                    );
                  },
                  child: Text(
                    'new user? Sign up here',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            )
        )
    );
  }
}
import 'package:flutter/material.dart';

import 'package:test_app/Screens/RegisterScreen.dart';
import 'package:test_app/Screens/UserLogin.dart';

import 'package:test_app/Templates/UserCredentials.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dart:io';
import 'package:path_provider/path_provider.dart';


class LoginScreen extends StatefulWidget {
  static final String id = '/login';

  LoginScreen({Key? key}) : super( key: key );

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  late String _email;
  late String _pass;
  String statusString ='';


  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/credentials.txt');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if( snapshot.hasError ) {
          print( snapshot.error );

          return Scaffold(
            body: SafeArea(
              child: Container(
                child: Text('something went wrong'),
              ),
            ),
          );
        }
        else if( snapshot.connectionState == ConnectionState.done ){
          return Scaffold(
            body: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      this.statusString,
                      style: TextStyle(
                        color: Colors.red,
                        decoration: TextDecoration.underline,
                      ),
                  ),
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
                      // // authenticate user login with the credentials

                      // FirebaseAuth auth = FirebaseAuth.instance;
                      // auth.authStateChanges()
                      //     .listen( (User? user) async {
                      //       if( user == null ) {
                      //         print("user - null ");
                      //       }
                      //       else{
                      //         print('user - ${user.email}' );
                      //       }
                      //       try {
                      //           UserCredential userCredential = await auth.signInWithEmailAndPassword(
                      //             email: this._email,
                      //             password: this._pass,
                      //           );
                      //
                      //           // creating new UserCredentials Object
                      //           UserCredentials creds = UserCredentials(auth: auth, user: user! );
                      //
                      //           // cancelling the subscription
                      //
                      //
                      //           Navigator.pushNamed(context, UserLogin.id, arguments: creds );
                      //       }
                      //       on FirebaseAuthException catch( fae ) {
                      //         if(fae.code == 'email-already-in-use' ) {
                      //           this.statusString = 'account already exists';
                      //         }
                      //         else
                      //           this.statusString = fae.code;
                      //
                      //         setState( () {} );
                      //       }
                      //       catch (e) {
                      //         print('exception $e');
                      //       }
                      //     });
                    },
                    child: Text(
                        "Login",
                        textDirection: TextDirection.ltr,
                    ),
                  ),

                  // if not a registered user go to RegisterScreen
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed( context, '/register' );
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
              ),
            ),
          );
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
      },
    );
  }
}
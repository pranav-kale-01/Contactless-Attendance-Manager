import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:test_app/Screens/UserLogin.dart';

class RegisterScreen extends StatefulWidget {
  static final String id= '/register';

  RegisterScreen({Key? key}) : super( key: key );

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  // initializing firebase_core
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  late String _email;
  late String _pass;
  String statusString = '';

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
                      // authenticate user login with the credentials
                      FirebaseAuth auth = FirebaseAuth.instance;
                      auth.authStateChanges()
                          .listen( (User? user) async {
                        try {
                          UserCredential userCredential = await auth
                              .createUserWithEmailAndPassword(
                            email: this._email,
                            password: this._pass,
                          );

                          Navigator.pushReplacementNamed(context, UserLogin.id, arguments: user );
                        }
                        on FirebaseAuthException catch( fae ) {
                          if( fae.code == 'weak-password' ) {
                            this.statusString = 'weak password';
                          }
                          else{
                            this.statusString = fae.code;
                          }

                          setState( () {} );
                        }
                        catch (e) {
                          print('exception $e');
                        }
                      });
                    },
                    child: Text(
                      "Login",
                      textDirection: TextDirection.ltr,
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






    // return Scaffold(
    //   appBar: AppBar(
    //     iconTheme: IconThemeData(
    //       color: Colors.black,
    //     ),
    //     foregroundColor: Colors.black,
    //     shadowColor: Colors.white,
    //     elevation: 0.0,
    //     backgroundColor: Colors.transparent,
    //   ),
    //   body: SafeArea(
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         TextField(
    //           onChanged: (value) {
    //             this._email = value;
    //           },
    //           decoration: InputDecoration(
    //             labelText: 'email',
    //           ),
    //         ),
    //         TextField(
    //           onChanged: (value) {
    //             this._pass = value;
    //           },
    //           decoration: InputDecoration(
    //             labelText: 'password'
    //           ),
    //           obscureText: true,
    //         ),
    //         MaterialButton(
    //           onPressed: () {
    //             // register a new user if a user with current credentials is not present
    //             //creating new FirebaseAuth instance
    //             FirebaseAuth auth = FirebaseAuth.instance;
    //             auth.authStateChanges()
    //                 .listen( (User? user) async {
    //               try {
    //                 UserCredential userCredential = await auth
    //                     .createUserWithEmailAndPassword(
    //                   email: this._email,
    //                   password: this._pass,
    //                 );
    //               } on FirebaseAuthException catch (fae) {
    //                 if (fae.code == 'weak-password') {
    //                   print("the password provide is too weak");
    //                 }
    //                 else if (fae.code == 'email-already-in-use') {
    //                   print('the account already exists for that email.');
    //                 }
    //               }
    //               catch (e) {
    //                 print(e);
    //               }
    //             });
    //           },
    //           child: Text(
    //             "Register",
    //             textDirection: TextDirection.ltr,
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}

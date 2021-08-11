import 'package:flutter/material.dart';

import 'package:test_app/Screens/Home.dart';
import 'package:test_app/Screens/SignUp.dart';

// import 'package:splashscreen/splashscreen.dart' show SplashScreen;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class IntroScreen extends StatelessWidget {
  Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build( BuildContext context ){
    return FutureBuilder(
      future: _initialization,
      builder: ( context, snapshot) {
        if( snapshot.connectionState == ConnectionState.done ) {
          User? result =  FirebaseAuth.instance.currentUser;

          return result != null ? Home( email: result.email!,) : SignUp();
        }
        else {
          return Scaffold(
            body: SafeArea(
              child: Container(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
      }
    );

    // return new SplashScreen(
    //   navigateAfterSeconds: result != null? Home( uid: result.uid ): SignUp(),
    //   seconds: 5,
    // );
  }
}
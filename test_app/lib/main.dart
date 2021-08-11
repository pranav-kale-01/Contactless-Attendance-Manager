import 'package:flutter/material.dart';

import 'package:test_app/Screens/UserLogin.dart';
import 'package:test_app/Screens/LoginScreen.dart';
import 'package:test_app/Screens/RegisterScreen.dart';
import 'package:test_app/Screens/IntroScreen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() => runApp( Main() );

class Main extends StatefulWidget {
  const Main({Key? key}) : super(key: key);

  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  @override
  Widget build( BuildContext context ){

    return MaterialApp(
      home: IntroScreen(),
    );
  }
}
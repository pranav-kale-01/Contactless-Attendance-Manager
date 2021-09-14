import 'package:flutter/material.dart';
import 'package:test_app/Screens/IntroScreen.dart';
import 'package:test_app/Templates/GenerateScreen.dart';

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
      debugShowCheckedModeBanner: false,
      home: IntroScreen(),
    );
  }
}
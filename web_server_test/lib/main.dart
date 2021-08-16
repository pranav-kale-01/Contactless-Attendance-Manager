import 'package:flutter/material.dart';
import 'package:web_server_test/insert.dart';
import 'package:web_server_test/Home.dart';

void main() {
  runApp( Main() );
}

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Test(),
      routes: {
        '/insert' : (context) => InsertData(),
        '/home' : (context) => Test(),
      },
    );
  }
}
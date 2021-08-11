import 'package:flutter/material.dart';
import 'package:test_app/Screens/UserLogin.dart';
import 'package:test_app/Screens/LoginScreen.dart';
import 'package:test_app/Screens/RegisterScreen.dart';

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
      initialRoute: LoginScreen.id,
      routes: {
        LoginScreen.id : (context) => LoginScreen(),
        RegisterScreen.id : (context) => RegisterScreen(),
        UserLogin.id : (context) => UserLogin(),
      },
    );
  }
}
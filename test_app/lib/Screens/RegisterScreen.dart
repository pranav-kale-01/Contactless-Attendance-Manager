import 'package:flutter/material.dart';
import 'package:test_app/Screens/Home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:test_app/utils/CredentialController.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class RegisterScreen extends StatelessWidget {
  late String _email;
  late String _pass;
  late String statusString;
  late Map<String,dynamic> data;

  Future<void> registerUser(BuildContext context) async {
    // adding the user details to the mysql database
    String url = "https://test-pranav-kale.000webhostapp.com/scripts/insert.php?user='${this._email}'&pass='${this._pass}'&authority='s-admin'&orgid=";
    print(url);

    http.Response response = await http.get(
        Uri.parse( url ),
        headers: {
          "Accept": "application/json",
          "Access-Control-Allow-Origin": "*",
        }
    );

    print("decoding data");

    print( response.body );

    var data= jsonDecode( response.body );

    print( data.toString() );

    // writing the data into a file for future auto logins
    if( !kIsWeb ) {
      await CredentialController.writeFile( "{ \"user\": \"${this._email}\", \"pass\": \"${this._pass}\" }" );
    }

    if( response.body != "" ) {
      // directing to the Home screen
      Navigator.pushReplacement(
        context, MaterialPageRoute(
          builder: (context) => Home( uid: data['UID'], email: this._email, ),
        ),
      );
    }
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
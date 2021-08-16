import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class InsertData extends StatefulWidget {
  const InsertData({Key? key}) : super(key: key);

  @override
  _InsertDataState createState() => _InsertDataState();
}

class _InsertDataState extends State<InsertData> {
  late int _ID;
  late String _post_header;
  late String _post_body;

  late dynamic data;

  Future<void> getData( int id, header, body) async {
    String url = "https://test-pranav-kale.000webhostapp.com/insert.php?ID=$id&post_header='$header'&post_body='$body'";
    print(url);

    http.Response response = await http.get( Uri.parse(url) );
    print( response.body );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: Column(
            children: [
              TextField(
                onChanged: (value) {
                  this._ID = int.parse( value );
                },
              ),
              TextField(
                onChanged: (value) {
                  this._post_header = value ;
                },
              ),
              TextField(
                onChanged: (value) {
                  this._post_body = value ;
                }
              ),

              IconButton(
                onPressed: () async {
                  // verifying and pushing the data to database
                  await getData(this._ID, this._post_header, this._post_body );

                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.add_circle,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
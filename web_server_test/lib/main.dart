import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http ;
import 'dart:convert';

void main() {
  runApp( Test() );
}

class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  late List<dynamic> data;

  Future<void> getData() async {
    // print('pressed');
    String url = 'https://test-pranav-kale.000webhostapp.com/get.php';

    http.Response response = await http.get( Uri.parse(url) );
    data = jsonDecode(response.body);

    setDataList();
  }

  Container getContainer( Map<String, dynamic> data ) {
    return Container(
      height: 100.0,
      width: 300.0,
      child: Column(
        children: [
          Text( data['ID'] ),
        ],
      )
    );
  }

  List<Container> dataList = [];

  void setDataList( ) {
    dataList.clear();

    for(var i in data ){
      Map<String, dynamic> temp = jsonDecode(i);
      dataList.add( getContainer( temp ) );
      print( temp );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Container(
            child: Column(
              children: [
                Container(
                  child: ListView(
                    shrinkWrap: true,
                  ),
                ),
                MaterialButton(
                  color: Colors.blue,
                  onPressed: () {
                    getData();
                  },
                  child: Text('press to get data'),
                ),
              ],
            ),
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }
}


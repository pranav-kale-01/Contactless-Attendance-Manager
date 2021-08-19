import 'package:flutter/material.dart';

import 'package:http/http.dart' as http ;
import 'dart:convert';

class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  late List<dynamic> data;
  List<Container> dataList = [];
  dynamic _elements = Container();

  Future<void> getData() async {
    String url = 'https://test-pranav-kale.000webhostapp.com/get.php';

    http.Response response = await http.get( Uri.parse(url) );
    data = jsonDecode(response.body);

    setDataList();
  }

  Container getContainer( Map<String, dynamic> data ) {
    return Container(
        height: 100.0,
        width: 300.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                padding: EdgeInsets.all( 10.0 ),
                child: Text( data['ID'] )
            ),
            Container(
                padding: EdgeInsets.all( 10.0 ),
                child: Text( data['post_header'] )
            ),
            Container(
                padding: EdgeInsets.all( 10.0 ),
                child: Text( data['post_body'] )
            ),
          ],
        )
    );
  }

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
        appBar: AppBar(
          actions: [
            IconButton(
              icon: Icon( Icons.add ),
              onPressed: () {
                Navigator.pushNamed( context, '/insert' );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Container(
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    // height: 200,
                    child: this._elements,
                  ),
                ),
                MaterialButton(
                  color: Colors.blue,
                  onPressed: () async {
                    this._elements = Container(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    );
                    setState(() { });

                    await getData();

                    this._elements = ListView(
                      children: dataList,
                    );

                    setState( () {} );
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
import 'package:flutter/material.dart';
import 'package:test_app/Templates/GradientContainer.dart';

import 'package:test_app/Templates/HomeScreenBuilder.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class ViewOrganizations extends StatefulWidget {
  const ViewOrganizations({Key? key}) : super(key: key);

  @override
  _ViewOrganizationsState createState() => _ViewOrganizationsState();
}

class _ViewOrganizationsState extends State<ViewOrganizations> {
  late dynamic jsonData;


  Future<void> viewOrg( ) async {
    String url = "https://test-pranav-kale.000webhostapp.com/scripts/get.php?table=organization";

    http.Response response = await http.get( Uri.parse( url ) );

    print("fetched");
    print( response.body );

    jsonData = jsonDecode( response.body ) ;

    for (int j = 0; j < jsonData.length; j++) {
      Map<String,dynamic> data = jsonDecode(jsonData[j]);
      print( data['org_id'] );
      print( data['org_name'] );
      print( data['org_email'] );
    }
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: viewOrg(),
        builder: (context,snapshot) {
          if( snapshot.connectionState == ConnectionState.done ) {
            return HomeScreenBuilder(
                body: GradientContainer(
                  child: Container(),
                ),
            );
          }
          else if( snapshot.hasError ) {
            return Container(
              child: Text( snapshot.error.toString() ),
            );
          }
          else {
            return Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            );
          }
        }
    );
  }
}

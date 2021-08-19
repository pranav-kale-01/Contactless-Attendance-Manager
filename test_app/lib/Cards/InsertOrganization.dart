import 'package:flutter/material.dart';

import 'package:test_app/Templates/HomeScreenBuilder.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class InsertOrganization extends StatefulWidget {
  const InsertOrganization({Key? key}) : super(key: key);

  @override
  _InsertOrganizationState createState() => _InsertOrganizationState();
}

class _InsertOrganizationState extends State<InsertOrganization> {
  // `org_name`, `org_email`, `db_name`, `db_user`
  late String org_name;
  late String org_email='';

  Future<void> insertOrg( ) async {
    String url = "https://test-pranav-kale.000webhostapp.com/scripts/insert_org.php?name='${this.org_name}'&mail='${this.org_email}'";

    http.Response response = await http.get( Uri.parse( url ) );

    print("inserted");
    // Map<String,dynamic> jsonData = jsonDecode( response.body ) ;
    //
    // print( jsonDecode );
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreenBuilder(
        body: Container(
            padding: EdgeInsets.all( 20.0 ),
            // `org_id`, `org_name`, `org_email`, `db_name`, `db_user`
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  width: 450,
                  child:TextField(
                    decoration: InputDecoration(
                      labelText: 'Organization Name',
                    ),
                    onChanged: (value) {
                      this.org_name = value;
                    },
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  width: 450,
                  child:TextField(
                    decoration: InputDecoration(
                      labelText: 'Organization Email',
                    ),
                    onChanged: (value) {
                      this.org_email = value;
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.all( 20.0 ),
                  child: MaterialButton(
                    color: Colors.blue,
                    onPressed: () async {
                      await insertOrg( );

                      print("organization added to the list");
                    },
                    child: Text(
                      'Add New Organization',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            )
        ),
      ),
    );
  }
}

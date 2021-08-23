import 'package:flutter/material.dart';
import 'package:test_app/Cards/ViewOrganizations.dart';

import 'package:http/http.dart' as http;

class SuperAdmin extends StatelessWidget {
  late String org_name;
  late String org_email='';

  SuperAdmin({Key? key}) : super(key: key);

  // Future<void> insertOrg( ) async {
  //   String url = "https://test-pranav-kale.000webhostapp.com/scripts/insert_org.php?name='${this.org_name}'&mail='${this.org_email}'";
  //
  //   await http.get( Uri.parse( url ) );
  // }

  @override
  Widget build(BuildContext context) {
    return ViewOrganizations();
  }
}

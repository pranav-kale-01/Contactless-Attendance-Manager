import 'package:flutter/material.dart';
import 'package:test_app/Cards/ManageOrganizations.dart';

class SuperAdmin extends StatelessWidget {
  final data;

  SuperAdmin({Key? key, required this.data }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewOrganizations( userInfo: this.data );
  }
}

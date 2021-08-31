import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:test_app/Cards/ManageBranch.dart';

class OrgAdmin extends StatefulWidget {
  final data;

  const OrgAdmin({Key? key, required this.data}) : super(key: key);

  @override
  _OrgAdminState createState() => _OrgAdminState(data: data);
}

class _OrgAdminState extends State<OrgAdmin> {
  final data;

  _OrgAdminState({required this.data }  );

  @override
  Widget build(BuildContext context) {
    return ViewBranch(setState: setState, context: context, userInfo: data,);
  }
}

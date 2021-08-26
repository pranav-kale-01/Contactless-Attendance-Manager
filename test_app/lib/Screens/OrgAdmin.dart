import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:test_app/Cards/ManageBranch.dart';

class OrgAdmin extends StatelessWidget {
  final data;

  OrgAdmin({Key? key, required this.data }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewBranch(userInfo: data,);
  }
}

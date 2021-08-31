import 'package:flutter/material.dart';
import 'package:test_app/Cards/ManageEmployee.dart';

class BranchAdmin extends StatefulWidget {
  final data;

  const BranchAdmin({Key? key, required this.data}) : super(key: key);

  @override
  _BranchAdminState createState() => _BranchAdminState();
}

class _BranchAdminState extends State<BranchAdmin> {
  @override
  Widget build(BuildContext context) {
    return ManageEmployee(context: context, setState: setState, userInfo: widget.data );
  }
}

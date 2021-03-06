import 'package:flutter/material.dart';
import 'package:test_app/Cards/ManageScan.dart';

class Employee extends StatefulWidget {
  final data;

  Employee({Key? key, required this.data }) : super(key: key);

  _EmployeeState createState() => _EmployeeState();
}

class _EmployeeState extends State<Employee> {
  @override
  Widget build( BuildContext context ) {
    return ManageScan( userInfo: widget.data );
  }
}

import 'package:flutter/material.dart';

class GradientContainer extends StatelessWidget {
  final Widget? child ;

  GradientContainer( {Key? key, required this.child } );

  @override
  Widget build( BuildContext context ) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all( 20.0 ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFECECEC), Color(0xFFC2C2C2), ],
          begin: Alignment.topRight,
          end: Alignment.centerLeft,
        ),
     ),
     child: this.child,
    );
  }
}

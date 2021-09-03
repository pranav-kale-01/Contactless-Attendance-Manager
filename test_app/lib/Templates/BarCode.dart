import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';

class BarCode extends StatelessWidget{
  final String generatorString;

  BarCode({Key? key, required this.generatorString }) : super( key: key );

  @override
  Widget build( BuildContext context ) {
    return Scaffold(
      body: Center(
        child: Container(
          height: 300,
          child: SfBarcodeGenerator(
            value: generatorString,
            symbology: QRCode(),
          )
        ),
      )
    );
  }
}

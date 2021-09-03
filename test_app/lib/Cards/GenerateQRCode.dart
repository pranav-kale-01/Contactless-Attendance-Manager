import 'package:flutter/material.dart';
import 'package:test_app/Templates/BarCode.dart';

class GenerateQRCode extends StatefulWidget {
  final String qrString;

  GenerateQRCode( {Key? key, required this.qrString }) : super( key: key );

  @override
  _GenerateQRCodeState createState() => _GenerateQRCodeState();
}

class _GenerateQRCodeState extends State<GenerateQRCode> {
  @override
  Widget build(BuildContext context ) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Container(
          color: Colors.black38,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: Colors.white,
              ),
              alignment: Alignment.bottomCenter,
              margin: EdgeInsets.only( top: 400.0 ),
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      child: Container(
                        height: 300.0,
                        width: 400.0,
                        padding: EdgeInsets.all( 5.0 ),
                        child: BarCode( generatorString: widget.qrString, ),
                      )
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: MaterialButton(
                        onPressed: () {
                          print("printed!!!!") ;
                        },
                        child: Text("Print"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      )
    );
  }
}
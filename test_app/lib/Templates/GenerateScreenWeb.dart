import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:qr_flutter/qr_flutter.dart';

import 'package:universal_html/html.dart' as html ;

class GenerateScreenWeb extends StatefulWidget {
  final String qrString;

  GenerateScreenWeb( {Key? key, required this.qrString }) : super( key: key );

  @override
  GenerateScreenWebState createState() => GenerateScreenWebState();
}

class GenerateScreenWebState extends State<GenerateScreenWeb> {
  GlobalKey globalKey = new GlobalKey();

  @override
  Widget build( BuildContext context ) {
    return Scaffold(
      backgroundColor: Colors.black45,
      body: GestureDetector(
        onTap: () {
          Navigator.pop( context );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black45,
          ) ,
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only( topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0) ),
              color: Colors.white,
            ),
            // margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3 ),
            width: MediaQuery.of(context).size.width,
            child: Container(
              child: GestureDetector(
                onTap: () {},
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    _contentWidget(),
                    Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular( 20.0 ),
                          color: Colors.blue,
                        ),
                        margin: EdgeInsets.only( bottom: 10.0, ),
                        padding: EdgeInsets.symmetric( horizontal: 20.0 ),
                        child: MaterialButton(
                          onPressed: () {
                            _captureAndSharePdf();
                          },
                          child: Icon(
                            Icons.download_sharp,
                            color: Colors.white,
                          ),
                        )
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _captureAndSharePdf( ) async {
    if( kIsWeb ) {
      try{
        RenderRepaintBoundary? boundary = globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary?;
        var image = await boundary!.toImage();
        ByteData? byteData = await image.toByteData( format: ImageByteFormat.png );
        Uint8List pngBytes = byteData!.buffer.asUint8List();

        final blob = html.Blob( [pngBytes], 'png' );

        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.document.createElement('a') as html.AnchorElement
          ..href = url
          ..style.display
          ..download = 'Scanner QR.png';
        html.document.body!.children.add( anchor );
        anchor.click();

        html.document.body!.children.remove( anchor );
        html.Url.revokeObjectUrl( url );
      }
      catch( e ) {
        print( e.toString() );
      }
    }
  }

  _contentWidget( )  {
    final bodyHeight = MediaQuery.of(context).size.height - MediaQuery.of(context).viewInsets.bottom;

    return Container(
      child: Center(
        child: RepaintBoundary(
          key: globalKey,
          child: Container(
            padding: EdgeInsets.symmetric( vertical: 30.0, horizontal: 10.0 ),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.only( top: 30.0, bottom: 20.0,   ),
                  child: Text(
                    "JMK infosoft Hajeri",
                    style: TextStyle(
                      fontSize: 54.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only( top: 10.0, bottom: 50.0, ),
                  child: Text(
                    "Contactless Attendance Manager",
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all( 4.0, ),
                  decoration: BoxDecoration(
                    border: Border.all( color: Colors.black ),
                  ),
                  child: QrImage(
                    data: widget.qrString,
                    size: 0.5 * bodyHeight,
                  ),
                ),
                Container(
                  padding: EdgeInsets.only( top: 30.0, ),
                  child: Text(
                    "Scan the Above code to mark your attendance",
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


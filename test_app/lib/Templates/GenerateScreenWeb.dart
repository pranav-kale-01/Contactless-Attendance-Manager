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
          color: Colors.black45,
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only( topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0) ),
              color: Colors.white,
            ),
            margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3 ),
            width: MediaQuery.of(context).size.width,
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
                      padding: EdgeInsets.symmetric( horizontal: 20.0 ),
                      child: MaterialButton(
                        onPressed: () {
                          _captureAndSharePdf();
                        },
                        child: Icon(
                          Icons.share,
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
      color: Colors.white,
      child: Center(
        child: RepaintBoundary(
          key: globalKey,
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                Text(
                  "Contactless Attendance Manager (Web version)",
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w200,
                  ),
                ),
                QrImage(
                  data: widget.qrString,
                  size: 0.5 * bodyHeight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


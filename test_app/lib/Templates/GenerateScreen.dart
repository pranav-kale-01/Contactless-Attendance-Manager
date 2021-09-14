import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GenerateScreen extends StatefulWidget {
  final String qrString;

  GenerateScreen( {Key? key, required this.qrString }) : super( key: key );

  @override
  State<StatefulWidget> createState() => GenerateScreenState();
}

class GenerateScreenState extends State<GenerateScreen> {
  GlobalKey globalKey = new GlobalKey();

  @override
  Widget build( BuildContext context ) {
    return Scaffold(
      backgroundColor: Colors.black12,
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only( topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0) ),
          color: Colors.white,
        ),
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3 ),
        // height: 400.0,
        width: MediaQuery.of(context).size.width,
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
                  _captureAndSharePng();
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
    );
  }

  Future<void> _captureAndSharePng( ) async {
    try{
      if( !kIsWeb ) {
        RenderRepaintBoundary? boundary = globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary?;
        var image = await boundary!.toImage();
        ByteData? byteData = await image.toByteData( format: ImageByteFormat.png );
        Uint8List pngBytes = byteData!.buffer.asUint8List();

        final tempDir = await getExternalStorageDirectory();
        String dir = tempDir.toString().split(": ")[1];
        dir = dir.substring(1, dir.length - 1 ) + '/image.png';

        final file = await new File( dir ).create();
        await file.writeAsBytes(pngBytes);
      }
    }
    catch(e) {
      print( e.toString() );
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
                    "Contactless Attendance Manager",
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


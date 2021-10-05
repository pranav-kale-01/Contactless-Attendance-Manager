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
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.blueAccent),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
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
                      Icons.download_sharp,
                      color: Colors.white,
                  ),
                )
              )
            ],
          ),
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


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:test_app/Screens/SignUp.dart';
import 'package:test_app/utils/CredentialController.dart';

class HomeScreenBuilder extends StatelessWidget {
  final Widget body;
  final ListView? listView;
  final AppBar? appbar;

  HomeScreenBuilder( {Key? key, required this.body, this.listView, this.appbar } ) : super( key: key );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Container(
        width: 180.0,
        child: Drawer(
          child: this.listView == null ? ListView(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [
                          Colors.blue,
                          Colors.blueAccent,
                          Colors.lightBlueAccent,
                        ]
                    )
                ),
                child: Icon(
                  Icons.account_circle,
                  color: Colors.white,
                ),
              ),
              ListTile(
                title: Text(
                    'Sign Out',
                ),
                onTap: () async {

                  // Signing the User Out
                  if( !kIsWeb) {
                    await CredentialController.clearFile();
                  }

                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SignUp()
                      ),
                          (Route<dynamic> route) => false
                  );
                },
              ),
            ],
          )
          : this.listView,
        ),
      ),
      appBar: this.appbar == null ? AppBar(
          backgroundColor: Color(0xFF10B5FC),
          title: Text('Home'),
      ) : this.appbar ,
      body: this.body,
    );
  }
}
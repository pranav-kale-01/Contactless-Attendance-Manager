import 'package:flutter/material.dart';

import 'package:test_app/Screens/Home.dart';

import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatelessWidget {
  late String _email;
  late String _pass;
  late String statusString;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  void registerToFb(BuildContext context){
    firebaseAuth
        .createUserWithEmailAndPassword(
      email: this._email,
      password: this._pass,
    ).then( (result) {
      Navigator.pushReplacement(
        context, MaterialPageRoute(
        builder: (context) => Home( email: result.user!.email! ),
      ),
      );
    }).catchError( (err) {
      showDialog(
          context: context,
          builder: (BuildContext context ){
            return AlertDialog(
                title: Text("Error"),
                content:  Text(err.message),
                actions: [
                  TextButton(
                      child: Text("Ok"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      }
                  ),
                ]
            );
          }
      );
    });
  }

  @override
  Widget build( BuildContext context ) {
    return Scaffold(
        body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  onChanged: (value) {
                    this._email = value;
                  },
                  decoration: InputDecoration(
                    labelText: 'email',
                  ),
                ),
                TextField(
                  onChanged: (value) {
                    this._pass = value;
                  },
                  decoration: InputDecoration(
                    labelText: 'password',
                  ),
                  obscureText: true,
                ),
                MaterialButton(
                  onPressed: () {
                    registerToFb( context );
                  },
                  child: Text('Register'),
                ),
              ],
            )
        )
    );
  }
}




// import 'package:flutter/material.dart';
//
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// import 'package:test_app/Screens/UserLogin.dart';
//
// import 'package:test_app/Templates/UserCredentials.dart';
//
// class RegisterScreen extends StatefulWidget {
//   static final String id= '/register';
//
//   RegisterScreen({Key? key}) : super( key: key );
//
//   @override
//   _RegisterScreenState createState() => _RegisterScreenState();
// }
//
// class _RegisterScreenState extends State<RegisterScreen> {
//
//   // initializing firebase_core
//   final Future<FirebaseApp> _initialization = Firebase.initializeApp();
//
//   late String _email;
//   late String _pass;
//   String statusString = '';
//
//   void _SignOut( FirebaseAuth auth ) async  {
//     await FirebaseAuth.instance.signOut();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: _initialization,
//       builder: (context, snapshot) {
//         if( snapshot.hasError ) {
//           print( snapshot.error );
//
//           return Scaffold(
//             body: SafeArea(
//               child: Container(
//                 child: Text('something went wrong'),
//               ),
//             ),
//           );
//         }
//
//         else if( snapshot.connectionState == ConnectionState.done ){
//           return Scaffold(
//             body: SafeArea(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     this.statusString,
//                     style: TextStyle(
//                       color: Colors.red,
//                       decoration: TextDecoration.underline,
//                     ),
//                   ),
//                   TextField(
//                     onChanged: (value) {
//                       this._email = value;
//                     },
//                     decoration: InputDecoration(
//                       labelText: 'email',
//                     ),
//                   ),
//                   TextField(
//                     onChanged: (value) {
//                       this._pass = value;
//                     },
//                     decoration: InputDecoration(
//                       labelText: 'password',
//                     ),
//                     obscureText: true,
//                   ),
//                   MaterialButton(
//                     onPressed: () {
//                       // // authenticate user login with the credentials
//                       // FirebaseAuth auth = FirebaseAuth.instance;
//                       // auth.authStateChanges()
//                       //     .listen( (User? user) async {
//                       //       if(user != null ){
//                       //         try {
//                       //           UserCredential userCredential = await auth
//                       //               .createUserWithEmailAndPassword(
//                       //             email: this._email,
//                       //             password: this._pass,
//                       //           );
//                       //
//                       //           if( user == null )
//                       //             print("no user found");
//                       //
//                       //           // creating new UserCredentials Object
//                       //           UserCredentials creds = UserCredentials(auth: auth, user: user! );
//                       //
//                       //           Navigator.pushNamed(context, UserLogin.id, arguments: creds );
//                       //         }
//                       //         on FirebaseAuthException catch( fae ) {
//                       //           if( fae.code == 'weak-password' ) {
//                       //             this.statusString = 'weak password';
//                       //           }
//                       //           else{
//                       //             this.statusString = fae.code;
//                       //           }
//                       //
//                       //           setState( () {} );
//                       //         }
//                       //         catch (e) {
//                       //           print('exception $e');
//                       //         }
//                       //       }
//                       //       else {
//                       //         print("else");
//                       //         //user = null ;
//                       //         //_SignOut( auth );
//                       //       }
//                       // });
//                     },
//                     child: Text(
//                       "Login",
//                       textDirection: TextDirection.ltr,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }
//
//         else {
//           return Scaffold(
//             body: SafeArea(
//               child: Container(
//                 alignment: Alignment.center,
//                 child: CircularProgressIndicator(),
//               ),
//             ),
//           );
//         }
//       },
//     );
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class UserCredentials {
  FirebaseAuth auth;
  User user;

  UserCredentials( {required this.auth, required this.user });
}
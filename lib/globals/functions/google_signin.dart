import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../api/apis.dart';
import '../../home.dart';
// ignore: library_prefixes

// fAuth.FirebaseAuth firebaseAuth = fAuth.FirebaseAuth.instance;
GoogleSignIn googleSignIn = GoogleSignIn();

// ignore: non_constant_identifier_names
GoogleSignInButton(context) {
  signInWithGoogle().then((user) async {
    if ((await APIs.userExist())) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: ((context) => const HomePage())));
    } else {
      await APIs.createUser().then((value) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: ((context) => const HomePage())));
      });
    }
  });
}

Future<UserCredential> signInWithGoogle() async {
  // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  // Once signed in, return the UserCredential
  return await APIs.auth.signInWithCredential(credential);
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import 'home.dart';
import 'views/login.dart';

class SplaceScreen extends StatefulWidget {
  const SplaceScreen({super.key});

  @override
  State<SplaceScreen> createState() => _SplaceScreenState();
}

var firebaseAuth = FirebaseAuth.instance;

class _SplaceScreenState extends State<SplaceScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      //exit full screen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.transparent,
          statusBarColor: Colors.transparent));
      //navigate home screen
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => firebaseAuth.currentUser != null
                ? const HomePage()
                : const LoginScreen(),
          ));
    });
  }

  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          AnimatedPositioned(
            top: mq.height * .25,
            right: mq.width * .15,
            width: mq.width * .75,
            duration: const Duration(seconds: 2),
            child: Image.asset('assets/images/login.jpg'),
          ),
          Positioned(
              bottom: mq.height * .35,
              width: mq.width,
              child: const Text(
                'WELCOME TO RABLOCHAT',
                style: TextStyle(
                    fontSize: 25,
                    color: Colors.black,
                    letterSpacing: .75,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              )),
        ],
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gocar_apps/global/global.dart';
import 'package:gocar_apps/screens/authScreens/login_screen.dart';
import 'package:gocar_apps/screens/mainScreens/main_screen.dart';

import '../assistants/assistant_methods.dart';

class SplashScreen extends StatefulWidget  {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  startTimer() {

    firebaseAuth.currentUser != null ? AssistantMethods.readCurrentOnlineUserInfo() : null;

    Timer(const Duration(seconds: 3), () async {
      if(await firebaseAuth.currentUser != null){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const MainScreen()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const LoginScreen()));
      }
    });
  }

  @override
  void initState(){
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/logo.png"),
              const SizedBox(height: 10),
              const Text(
                "DriverIt Apps",
                style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

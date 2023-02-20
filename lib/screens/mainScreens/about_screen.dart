import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ListView(
        children: [
          Container(
            height: 230,
            child: Center(
              child: Image.asset(
                  "assets/car_logo.png",
                width: 260,
              ),
            ),
          ),
          Column(
            children: [
              const Text(
                "Gocar Like Apps",
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white54,
                  fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Aplikasi Coba - coba buat Latihan Flutter yang lebih kompleks",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.white54,
                    //fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              ElevatedButton(
                  onPressed: (){
                    SystemNavigator.pop();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white54
                  ),
                  child: const Text(
                    "Close",
                    style: TextStyle(
                        color: Colors.white
                    ),
                  )
              )
            ],
          )
        ],
      ),
    );
  }
}

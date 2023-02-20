import 'package:flutter/material.dart';
import 'package:gocar_apps/global/global.dart';
import 'package:gocar_apps/screens/mainScreens/about_screen.dart';
import 'package:gocar_apps/screens/mainScreens/profile_screen.dart';
import 'package:gocar_apps/screens/mainScreens/trips_history_screen.dart';
import 'package:gocar_apps/screens/splash_screen.dart';


class MyDrawer extends StatefulWidget {
  String? name;
  String? email;

  MyDrawer({super.key,
    this.name,
    this.email
  });

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          Container(
            height: 165,
            color: Colors.grey,
            child: DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.black,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 16,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.name.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      SizedBox(height: 10,),
                      Text(
                        widget.email.toString(),
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 12,),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (c)=> const TripsHistoryScreen()));
            },
            child: const ListTile(
              leading: Icon(
                Icons.history,
                color: Colors.white54,
              ),
              title: Text(
                "History",
                style: TextStyle(
                  color: Colors.white54
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (c)=> const ProfileScreen()));

            },
            child: const ListTile(
              leading: Icon(
                Icons.person,
                color: Colors.white54,
              ),
              title: Text(
                "Visit Profile",
                style: TextStyle(
                    color: Colors.white54
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (c)=> const AboutScreen()));
            },
            child: const ListTile(
              leading: Icon(
                Icons.info,
                color: Colors.white54,
              ),
              title: Text(
                "About",
                style: TextStyle(
                    color: Colors.white54
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              firebaseAuth.signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (c)=> const SplashScreen()));
            },
            child: const ListTile(
              leading: Icon(
                Icons.logout,
                color: Colors.white54,
              ),
              title: Text(
                "Logout",
                style: TextStyle(
                    color: Colors.white54
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

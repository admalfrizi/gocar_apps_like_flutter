import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gocar_apps/components/info_design_ui.dart';
import 'package:gocar_apps/global/global.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              userModelCurrentInfo!.name!,
              style: const TextStyle(
                fontSize: 50,
                color: Colors.white,
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(
              height: 20,
              width: 200,
              child: Divider(
                color: Colors.white,
              ),
            ),
            const SizedBox(
              height: 38,
            ),
            InfoDesignUI(
              textInfo: userModelCurrentInfo!.email!,
              iconData: Icons.email,
            ),
            InfoDesignUI(
              textInfo: userModelCurrentInfo!.phone!,
              iconData: Icons.phone_iphone,
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: (){
                  SystemNavigator.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white54
                ),
                child: Text(
                  "Close",
                  style: TextStyle(
                    color: Colors.white
                  ),
                )
            )
          ],
        ),
      ),
    );
  }
}

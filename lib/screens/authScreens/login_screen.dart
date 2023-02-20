import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gocar_apps/screens/authScreens/register_screen.dart';

import '../../components/progress_dialog.dart';
import '../../global/global.dart';
import '../splash_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  FToast? fToast;

  TextEditingController emailTxtEditController = TextEditingController();
  TextEditingController passwordTxtEditController = TextEditingController();

  @override
  void initState(){
    super.initState();
    fToast = FToast();
    fToast?.init(context);
  }

  _showToast(String? toastMsg){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.red,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 12.0,
          ),
          Text(
            toastMsg!,
            style: const TextStyle(
                color: Colors.white
            ),
          ),
        ],
      ),
    );
  }

  validateForm(){
    if(!emailTxtEditController.text.contains("@")){
      fToast?.showToast(
          child: _showToast("Emailnya Salah"),
          gravity: ToastGravity.BOTTOM,
          toastDuration: const Duration(seconds: 3)
      );
    } else if(passwordTxtEditController.text.isEmpty){
      fToast?.showToast(
        child: _showToast("Passwordnya Harus Di Isi !"),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 3),
      );
    }else {
      loginUser();
    }
  }

  loginUser() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext c) {
          return ProgressDialog(msg: "Sedang Di Proses...",);
        }
    );

    final User? fbUser = (
        await firebaseAuth.signInWithEmailAndPassword(
        email: emailTxtEditController.text.trim(),
        password: passwordTxtEditController.text.trim()
        ).catchError((msg){
          Navigator.pop(context);
          fToast?.showToast(
            child: _showToast("Error : $msg")
          );
      })
    ).user;

    if(fbUser != null){

      DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users");
      userRef.child(fbUser.uid).once().then((userKey) {
        final snap = userKey.snapshot;
        if(snap.value != null) {
          currentFirebaseUser = fbUser;
          fToast?.showToast(
            child: _showToast("Selamat Datang..."),
            gravity: ToastGravity.BOTTOM,
            toastDuration: const Duration(seconds: 3),
          );
          Navigator.push(context, MaterialPageRoute(builder: (c)=> const SplashScreen()));
        } else {
          fToast?.showToast(
            child: _showToast("Tidak ada email yang terdaftar !"),
            gravity: ToastGravity.BOTTOM,
            toastDuration: const Duration(seconds: 3),
          );
          firebaseAuth.signOut();
          Navigator.push(context, MaterialPageRoute(builder: (c)=> const SplashScreen()));
        }
      });
    } else {
      Navigator.pop(context);
      fToast?.showToast(
        child: _showToast("Terjadi Error Ketika Login"),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Image.asset("assets/logo.png"),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  "Silahkan Login Ke Driveit",
                  style: TextStyle(
                      fontSize: 24,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: emailTxtEditController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(
                      color: Colors.grey
                  ),
                  decoration: const InputDecoration(
                    labelText: "Email Anda",
                    hintText: "Masukan Email Anda",
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey)
                    ),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey)
                    ),
                    hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 14
                    ),
                    labelStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 14
                    ),
                  ),
                ),
                TextField(
                  controller: passwordTxtEditController,
                  keyboardType: TextInputType.text,
                  obscureText: true,
                  style: const TextStyle(
                      color: Colors.grey
                  ),
                  decoration: const InputDecoration(
                    labelText: "Password Anda",
                    hintText: "Masukan Password Anda",
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey)
                    ),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey)
                    ),
                    hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 14
                    ),
                    labelStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 14
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: (){
                    validateForm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreenAccent,
                  ),
                  child: const Text(
                    "Masuk",
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 18
                    ),
                  ),
                ),
                TextButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (c)=> const RegisterScreen()));
                    },
                    child: const Text(
                      "Belum Pernah Aplikasinya ? Daftar Dong!",
                      style: TextStyle(
                        color: Colors.grey
                      ),
                    )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

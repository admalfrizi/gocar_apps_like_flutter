import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gocar_apps/screens/authScreens/login_screen.dart';
import 'package:gocar_apps/screens/splash_screen.dart';

import '../../components/progress_dialog.dart';
import '../../global/global.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  FToast? fToast;

  TextEditingController nameTxtEditController = TextEditingController();
  TextEditingController emailTxtEditController = TextEditingController();
  TextEditingController phoneTxtEditController = TextEditingController();
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
    if(nameTxtEditController.text.length < 3){
      fToast?.showToast(
          child: _showToast("Nama minimal harus 3 huruf"),
          gravity: ToastGravity.BOTTOM,
          toastDuration: const Duration(seconds: 3)
      );
    } else if(!emailTxtEditController.text.contains("@")){
      fToast?.showToast(
          child: _showToast("Format Email Salah !"),
          gravity: ToastGravity.BOTTOM,
          toastDuration: const Duration(seconds: 3),
      );
    } else if(phoneTxtEditController.text.isEmpty){
      fToast?.showToast(
        child: _showToast("Nomor Hp Harus Ada !"),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 3),
      );
    } else if(passwordTxtEditController.text.length < 8){
      fToast?.showToast(
        child: _showToast("Passwordnya Harus 8 Karakter !"),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 3),
      );
    }else {
      saveUserInfo();
    }
  }

  saveUserInfo() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext c) {
          return ProgressDialog(msg: "Sedang Di Proses...",);
        }
    );

    final User? fbUser = (
      await firebaseAuth.createUserWithEmailAndPassword(
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
      Map userMap = {
        "id": fbUser.uid,
        "name": nameTxtEditController.text.trim(),
        "email": emailTxtEditController.text.trim(),
        "phone": phoneTxtEditController.text.trim()
      };

      DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users");
      userRef.child(fbUser.uid).set(userMap);

      currentFirebaseUser = fbUser;
      fToast?.showToast(
        child: _showToast("Akun anda Telah Dibuat"),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 3),
      );
      Navigator.push(context, MaterialPageRoute(builder: (c)=> const SplashScreen()));

    } else {
      Navigator.pop(context);
      fToast?.showToast(
        child: _showToast("Akun anda Belum Ada Di Sistem!"),
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
            padding: const EdgeInsets.all(16.0),
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
                  "Daftarkan Sebagai Penumpang Online",
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
                  controller: nameTxtEditController,
                  style: const TextStyle(
                    color: Colors.grey
                  ),
                  decoration: const InputDecoration(
                    labelText: "Nama Anda",
                    hintText: "Masukan Nama Anda",
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
                  controller: phoneTxtEditController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(
                      color: Colors.grey
                  ),
                  decoration: const InputDecoration(
                    labelText: "Nomor Hp Anda",
                    hintText: "Masukan Nomor Hp Anda",
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
                    labelText: "Buat Password",
                    hintText: "Buat Password Anda Disini",
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
                    //Navigator.push(context, MaterialPageRoute(builder: (c)=> CarInfoScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreenAccent,
                  ),
                  child: const Text(
                    "Buat Akun",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 18
                    ),
                  ),
                ),
                TextButton(
                    onPressed: (){
                      Navigator.pop(context, MaterialPageRoute(builder: (c)=> const LoginScreen()));
                    },
                    child: const Text(
                      "Udh Jadi Penumpang ? Ayo Cari Supir!",
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

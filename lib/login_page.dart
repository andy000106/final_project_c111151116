import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool not_registered = false;

  Future<void> login_or_register() async {
    try {
      if (not_registered) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      }
      else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("錯誤",style: TextStyle(fontSize: 18,fontFamily:"GenSekiGothic2-H",),),
          content: Text(e.toString(),style: TextStyle(fontSize: 20,),),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("確定",style: TextStyle(fontSize: 18,fontFamily:"GenSekiGothic2-H",),),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(not_registered?'註冊':'登入',style: TextStyle(fontSize: 24,fontFamily:"GenSekiGothic2-H",color: Colors.black),)
      ),
      body:Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/bg7.png'),fit: BoxFit.cover)
          ),
          child: Padding(
              padding: EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(height: 30,),
                    Image(image: AssetImage('assets/plate1.png'),height: 300,width: 300,),
                    Text(
                      '歡迎使用\n「今天吃什麼?」APP',
                      style: TextStyle(fontSize: 24,fontFamily:"GenSekiGothic2-H",color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                    TextField(
                      controller: emailController,
                      decoration:InputDecoration(
                          icon: Icon(Icons.email),
                          labelText: 'Email',
                      ),
                    ),
                    TextField(
                      controller: passwordController,
                      decoration:InputDecoration(
                          icon: Icon(Icons.password),
                          labelText: '密碼',
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 5),
                    ElevatedButton(
                      onPressed: login_or_register,
                      child: Text(not_registered?'註冊':'登入',style: TextStyle(fontSize: 24,fontFamily:"851tegaki",color: Colors.black),),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          not_registered = !not_registered;
                        });
                      },
                      child: Text(not_registered?'已有帳號?登入':'沒有帳號?註冊',style: TextStyle(fontSize: 18,color: Colors.black),),
                    ),
                  ],
                ),
              ),
          ),
        ),
    );
  }
}

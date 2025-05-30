import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frankmichaelflutterproject/pages/bottomnav.dart';
import 'package:frankmichaelflutterproject/pages/forgotpassword.dart';
import 'package:frankmichaelflutterproject/pages/signup.dart';
import 'package:frankmichaelflutterproject/service/shared_pref.dart';
import 'package:frankmichaelflutterproject/widget/widget_support.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  String email = "", password = "";
  final _formkey = GlobalKey<FormState>();

  final useremailcontroller = TextEditingController();
  final userpasswordcontroller = TextEditingController();

  Future<void> userLogin() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;
      if (user != null) {
        await SharedPreferenceHelper().saveUserId(user.uid);
        await SharedPreferenceHelper().saveUserEmail(user.email ?? "");

        // Use Firebase displayName or fallback to email prefix
        final name = user.displayName ?? user.email?.split('@').first ?? "User";
        await SharedPreferenceHelper().saveUserName(name);

        // Set default wallet if not already set
        String? wallet = await SharedPreferenceHelper().getUserWallet();
        if (wallet == null) {
          await SharedPreferenceHelper().saveUserWallet("1000");
        }

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const BottomNav()));
      }
    } on FirebaseAuthException catch (e) {
      String message = "Login failed.";
      if (e.code == 'user-not-found') {
        message = "No user found for that email";
      } else if (e.code == 'wrong-password') {
        message = "Incorrect password";
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("❌ $message", style: const TextStyle(fontSize: 16)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 2.5,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFff5c30), Color(0xFFe74b1a)],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3),
            height: MediaQuery.of(context).size.height / 2,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 60.0, left: 20.0, right: 20.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Center(
                    child: Image.asset("images/logo.png",
                        width: MediaQuery.of(context).size.width / 1.5),
                  ),
                  const SizedBox(height: 50.0),
                  Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Form(
                        key: _formkey,
                        child: Column(
                          children: [
                            const SizedBox(height: 30.0),
                            Text("Login", style: AppWidget.HeadlineTextFeildStyle()),
                            const SizedBox(height: 30.0),
                            TextFormField(
                              controller: useremailcontroller,
                              validator: (value) =>
                                  value!.isEmpty ? 'Please enter email' : null,
                              decoration: InputDecoration(
                                hintText: 'Email',
                                prefixIcon: const Icon(Icons.email_outlined),
                                hintStyle: AppWidget.semiBoldTextFeildStyle(),
                              ),
                            ),
                            const SizedBox(height: 30.0),
                            TextFormField(
                              controller: userpasswordcontroller,
                              obscureText: true,
                              validator: (value) =>
                                  value!.isEmpty ? 'Please enter password' : null,
                              decoration: InputDecoration(
                                hintText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                hintStyle: AppWidget.semiBoldTextFeildStyle(),
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const ForgotPassword()),
                                ),
                                child: Text("Forgot Password?",
                                    style: AppWidget.semiBoldTextFeildStyle()),
                              ),
                            ),
                            const SizedBox(height: 40.0),
                            GestureDetector(
                              onTap: () {
                                if (_formkey.currentState!.validate()) {
                                  setState(() {
                                    email = useremailcontroller.text.trim();
                                    password = userpasswordcontroller.text.trim();
                                  });
                                  userLogin();
                                }
                              },
                              child: Material(
                                elevation: 5.0,
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  width: 200,
                                  decoration: BoxDecoration(
                                    color: const Color(0Xffff5722),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Center(
                                    child: Text("LOGIN",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignUp()),
                    ),
                    child: Text("Don't have an account? Sign up",
                        style: AppWidget.semiBoldTextFeildStyle()),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

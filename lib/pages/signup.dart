import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frankmichaelflutterproject/pages/bottomnav.dart';
import 'package:frankmichaelflutterproject/pages/login.dart';
import 'package:frankmichaelflutterproject/service/shared_pref.dart';
import 'package:frankmichaelflutterproject/widget/widget_support.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formkey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final mailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> registration() async {
    if (_formkey.currentState!.validate()) {
      String name = nameController.text.trim();
      String email = mailController.text.trim();
      String password = passwordController.text.trim();

      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        User? user = userCredential.user;
        if (user != null) {
          // ✅ Save to SharedPreferences
          await SharedPreferenceHelper().saveUserId(user.uid);
          await SharedPreferenceHelper().saveUserName(name);
          await SharedPreferenceHelper().saveUserEmail(email);
          await SharedPreferenceHelper().saveUserWallet("1000"); // default balance

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Registered successfully!")),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BottomNav()),
          );
        }
      } on FirebaseAuthException catch (e) {
        String msg = "Registration failed.";
        if (e.code == 'weak-password') {
          msg = "Password is too weak.";
        } else if (e.code == 'email-already-in-use') {
          msg = "Account already exists.";
        }
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("❌ $msg")));
      }
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
                  const SizedBox(height: 30.0),
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
                            Text("Sign Up",
                                style: AppWidget.HeadlineTextFeildStyle()),
                            const SizedBox(height: 30.0),
                            TextFormField(
                              controller: nameController,
                              validator: (value) =>
                                  value!.isEmpty ? 'Enter your name' : null,
                              decoration: InputDecoration(
                                hintText: 'Name',
                                prefixIcon: const Icon(Icons.person_outline),
                                hintStyle: AppWidget.semiBoldTextFeildStyle(),
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            TextFormField(
                              controller: mailController,
                              validator: (value) =>
                                  value!.isEmpty ? 'Enter your email' : null,
                              decoration: InputDecoration(
                                hintText: 'Email',
                                prefixIcon: const Icon(Icons.email_outlined),
                                hintStyle: AppWidget.semiBoldTextFeildStyle(),
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            TextFormField(
                              controller: passwordController,
                              obscureText: true,
                              validator: (value) =>
                                  value!.isEmpty ? 'Enter your password' : null,
                              decoration: InputDecoration(
                                hintText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                hintStyle: AppWidget.semiBoldTextFeildStyle(),
                              ),
                            ),
                            const SizedBox(height: 30.0),
                            GestureDetector(
                              onTap: registration,
                              child: Material(
                                elevation: 5.0,
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12.0),
                                  width: 200,
                                  decoration: BoxDecoration(
                                    color: const Color(0Xffff5722),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Center(
                                    child: Text("SIGN UP",
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
                      MaterialPageRoute(builder: (_) => const LogIn()),
                    ),
                    child: Text(
                      "Already have an account? Login",
                      style: AppWidget.semiBoldTextFeildStyle(),
                    ),
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

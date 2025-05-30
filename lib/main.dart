import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:frankmichaelflutterproject/pages/details.dart';
import 'package:frankmichaelflutterproject/pages/home.dart';
import 'package:frankmichaelflutterproject/pages/onboard.dart';
import 'package:frankmichaelflutterproject/pages/login.dart';
import 'package:frankmichaelflutterproject/pages/signup.dart';
import 'package:frankmichaelflutterproject/pages/profile.dart';
import 'package:frankmichaelflutterproject/pages/bottomnav.dart';
import 'package:frankmichaelflutterproject/admin/admin_login.dart';
import 'package:frankmichaelflutterproject/admin/home_admin.dart';
import 'package:frankmichaelflutterproject/admin/delete_food.dart';
import 'package:frankmichaelflutterproject/pages/cloudinary_upload.dart';
import 'package:frankmichaelflutterproject/pages/order.dart' as order_page;

import 'package:frankmichaelflutterproject/services/notification_service.dart'; // <-- Add this

void main() async {
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Project',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Onboard(),
      routes: {
        '/login': (context) => const LogIn(),
        '/signup': (context) => const SignUp(),
        '/admin_login': (context) => const AdminLogin(),
        '/admin_home': (context) => const HomeAdmin(),
        '/profile': (context) => const Profile(),
        '/order': (context) => const order_page.Order(),
        '/bottomnav': (context) => const BottomNav(),
        '/cloudinary_upload': (context) => const CloudinaryUploadScreen(),
        '/delete_food': (context) => const DeleteFood(),
      },
    );
  }
}

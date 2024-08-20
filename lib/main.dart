import 'package:flutter/material.dart';
import 'package:flutter_test_api_call/doctor/doctor.dart';
import 'package:flutter_test_api_call/doctor/doctorLogin.dart';
import 'package:flutter_test_api_call/user/user.dart';

import 'doctor/register_doctor.dart';
import 'home.dart';
import 'user/register_user.dart';
import 'user/userLogin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'hc frontend',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/login': (context) => const UserLoginPage(),
        '/register': (context) => const RegisterPage(),
        '/loginDoctor': (context) => const DocLoginPage(),
        '/registerDoctor': (context) => const RegisterDoctorPage(),
        '/doctorScreen': (context) => const DoctorScreen(),
        '/userScreen': (context) => const UserScreen(),
      },
    );
  }
}

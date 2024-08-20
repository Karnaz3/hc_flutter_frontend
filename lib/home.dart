import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to remote health care'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _showUserTypeDialog(context);
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showUserTypeDialog(context, isLogin: false);
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }

  void _showUserTypeDialog(BuildContext context, {bool isLogin = true}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Who are you?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                      context, isLogin ? '/loginDoctor' : '/registerDoctor');
                },
                child: const Text('Doctor'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                      context, isLogin ? '/login' : '/register');
                },
                child: const Text('User'),
              ),
            ],
          ),
        );
      },
    );
  }
}
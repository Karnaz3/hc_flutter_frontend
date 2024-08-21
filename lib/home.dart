import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0), // Custom height for AppBar
        child: AppBar(
          backgroundColor: const Color(0xFF4FC3F7),
          title: const Align(
            alignment: Alignment(0.0, -0.3), // Shift title upwards slightly
            child: Text(
              'Welcome to remote health care',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          centerTitle: true, // Keep the title centered horizontally
        ),
      ),
      // Gradient background
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFB2EBF2), // Light Cyan
              Color(0xFF80DEEA), // Light Blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Spacer(),
            // Logo section with borders
            Container(
              padding: const EdgeInsets.all(12), // Space for the light border
              decoration: const BoxDecoration(
                color: Color(0xFFB2EBF2), // Light Cyan border color
                shape: BoxShape.circle,
              ),
              child: Container(
                padding: const EdgeInsets.all(8), // Space for the dark border
                decoration: const BoxDecoration(
                  color: Color(0xFF4FC3F7), // Darker blue border color
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: SizedBox(
                    height: 200, // Increased size for the logo
                    width: 200,
                    child: Image.asset(
                      'images/logo.png', // Replace with your logo asset path
                      fit: BoxFit
                          .cover, // Ensures the image fits the circular container
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(
                flex: 2), // Increased space to move buttons further down
            // Buttons section
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      _showUserTypeDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF4FC3F7), // Medium Blue color
                    ),
                    child: const Text('Login'),
                  ),
                ),
                const SizedBox(width: 20),
                SizedBox(
                  width: 150,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      _showUserTypeDialog(context, isLogin: false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF4FC3F7), // Medium Blue color
                    ),
                    child: const Text('Register'),
                  ),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  void _showUserTypeDialog(BuildContext context, {bool isLogin = true}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor:
              Colors.transparent, // Make dialog background transparent
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFB2EBF2), // Light Cyan
                  Color(0xFF80DEEA), // Light Blue
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Who are you?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 150,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context,
                          isLogin ? '/loginDoctor' : '/registerDoctor');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF4FC3F7), // Matching button color
                    ),
                    child: const Text('Doctor'),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 150,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                          context, isLogin ? '/login' : '/register');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF4FC3F7), // Matching button color
                    ),
                    child: const Text('User'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

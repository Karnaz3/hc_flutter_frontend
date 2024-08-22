import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test_api_call/network.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DocLoginPage extends StatefulWidget {
  const DocLoginPage({super.key});

  @override
  _DocLoginPageState createState() => _DocLoginPageState();
}

class _DocLoginPageState extends State<DocLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome Doctor'),
        centerTitle: true, // Center the title in the AppBar
        backgroundColor: const Color(0xFF4FC3F7), // Same medium blue color
      ),
      // Apply gradient background
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
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        // Simple email validation
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    // Login Button
                    SizedBox(
                      width: 150,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _login();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4FC3F7), // Matching button color
                        ),
                        child: const Text('Login'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
  try {
    var apiService = ApiService();
    var response = await apiService.dio.post(
      '/doctors/login',
      data: {
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Extract token, doctor's name, and email
      var token = response.data['token'];
      var doctorName = response.data['user']['name'];
      var doctorEmail = response.data['user']['email'];

      // Store token, doctor's name, and email in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('doctorName', doctorName);
      await prefs.setString('doctorEmail', doctorEmail);

      // Navigate to doctor's screen
      Navigator.pushNamed(context, '/doctorScreen');
    } else {
      // Handle other status codes (e.g., 400, 404)
      String errorMessage = response.data['message'] ?? 'Login failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
        ),
      );
    }
  } on DioException catch (e) {
    String errorMessage = 'Error occurred: ${e.message}';
    if (e.response != null && e.response?.statusCode == 404) {
      errorMessage = 'User not registered. Please check your email or register.';
    } else if (e.response != null && e.response?.statusCode == 400) {
      errorMessage = 'Invalid password. Please try again.';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Unexpected error: $e'),
      ),
    );
  }
}

}

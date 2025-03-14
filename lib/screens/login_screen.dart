import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import './register_screen.dart';
import './admin_page.dart';
import './users_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> saveAuthToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
  }

  Future<void> saveUserDetails(Map<String, dynamic> details) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Convert the object to a JSON string
    String detailsJson = jsonEncode(details);

    // Save the JSON string in SharedPreferences
    await prefs.setString('userDetails', detailsJson);
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      setState(() {
        _isLoading = false;
      });

      // if (response['token'] != null && response['token'].isNotEmpty) {
      //   Fluttertoast.showToast(msg: 'Login successful');
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(builder: (context) => HomeScreen()),
      //   );
      // } else {
      //   Fluttertoast.showToast(msg: response['message']);
      // }
      // Assuming response['user'] contains user details
      if(response['status'] != '409'){
        if (response['user_details']['user']['role'].contains('Admin')) {
          await saveAuthToken(response['token']);
          await saveUserDetails(response['user_details']);
          Fluttertoast.showToast(msg: 'Login successful');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminPage()), // Admin page
          );
        } else {
          await saveAuthToken(response['token']);
          await saveUserDetails(response['user_details']);
          Fluttertoast.showToast(msg: 'Login successful');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => UsersPage()), // User page (notes)
          );
        }
      }else{
        Fluttertoast.showToast(msg: response['message']);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.lightBlueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [// Logo Section
                Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/logo.png', // Path to your logo
                    height: 130, // Adjustable height
                    width: 130,  // Adjustable width
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                _buildTextField('Username', _emailController, false),
                SizedBox(height: 20),
                _buildTextField('Password', _passwordController, true),
                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        onPressed: _login,
                        child: Text('Login', style: TextStyle(fontSize: 18)),
                      ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterScreen()),
                    );
                  },
                  child: Text(
                    'Don’t have an account? Register',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, bool obscureText) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white70),
          borderRadius: BorderRadius.circular(25),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(25),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import './users_page.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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

  Future<void> _Register() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.register(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      setState(() {
        _isLoading = false;
      });

      if (response['token'] != null && response['token'].isNotEmpty) {
        await saveAuthToken(response['token']);
        await saveUserDetails(response['user_details']);
        if (response['isNewUser'] == true) { // Add a condition to differentiate registration
          Fluttertoast.showToast(msg: 'Register successful');
        } else {
          Fluttertoast.showToast(msg: 'User Login successful');
        }

        // Navigate to the UsersPage regardless of the condition
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UsersPage()),
        );
      } else {
        Fluttertoast.showToast(msg: 'Error: Token not found');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(msg: 'Error: ${e.toString()}');
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
                  'Register',
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
                        onPressed: _Register,
                        child: Text('Register', style: TextStyle(fontSize: 18)),
                      ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: Text(
                    'Back to Login',
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

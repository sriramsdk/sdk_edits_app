import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({Key? key}) : super(key: key);

  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  List<String> roles = ['Admin', 'User'];
  List<String> selectedRoles = [];

  Future<void> _addUser() async {
    setState(() {
      isLoading = true;
    });
    // Add user logic here
    print('Username: ${usernameController.text}');
    print('Password: ${passwordController.text}');
    print('Roles: $selectedRoles');

    Map<String, dynamic> newUser = {
      'username': usernameController.text,
      'password': passwordController.text,
      'roles': selectedRoles, // Send roles as an array
    };

    // Call your API or handle the user addition
    try {
      var response = await ApiService.addUser(newUser);
      print('response: ${response}');
      if (response['status'] == 200) {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: response['message']);
        // Clear inputs after addition
        usernameController.clear();
        passwordController.clear();
        selectedRoles.clear();
      } else {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: response['message'] ?? 'Failed to add user');
      }
    } catch (e) {
      setState(() {
          isLoading = false;
        });
      Fluttertoast.showToast(msg: 'Error: $e');
    }

    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add User',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Title
              const Text(
                'Add New User',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Username Field
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: const TextStyle(color: Colors.blue),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Password Field
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.blue),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),

              // Roles Section
              const Text(
                'Roles',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Column(
                children: roles.map((role) {
                  return CheckboxListTile(
                    title: Text(role),
                    value: selectedRoles.contains(role),
                    activeColor: Colors.blue,
                    onChanged: (bool? isChecked) {
                      setState(() {
                        if (isChecked == true) {
                          selectedRoles.add(role);
                        } else {
                          selectedRoles.remove(role);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),

              // Add User Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Add User',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

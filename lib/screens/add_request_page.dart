import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddRequestPage extends StatefulWidget {
  const AddRequestPage({Key? key}) : super(key: key);

  @override
  _AddRequestPageState createState() => _AddRequestPageState();
}

class _AddRequestPageState extends State<AddRequestPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  bool isLoading = false;

  Future<void> _addRequest() async {
    setState(() {
      isLoading = true;
    });
    // Add user logic here
    print('Title : ${titleController.text}');
    print('Text : ${descriptionController.text}');

    Map<String, dynamic> newUser = {
      'title': titleController.text,
      'text': descriptionController.text,
    };

    // Call your API or handle the user addition
    try {
      var response = await ApiService.addRequest(newUser);
      print('response: ${response}');
      if (response['status'] == 200) {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: response['message']);
        // Clear inputs after addition
        titleController.clear();
        descriptionController.clear();
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
          'Add Your Request',
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

              // Username Field
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
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
                minLines: 3, // Set this
                maxLines: 6, // and this
                keyboardType: TextInputType.multiline,
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Describe Your Request',
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
                obscureText: false,
              ),
              const SizedBox(height: 20),

              // Add User Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Add Request',
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

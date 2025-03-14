import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
// Assuming `navigatorKey` is defined globally as shown above
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class ApiService {
  static const String baseUrl = 'https://visiting-lura-sdkgroup-184d32b4.koyeb.app';

  // Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': email, 'password': password}),
    );
    var jsonResponse = jsonDecode(response.body);
    print("Response from API: $jsonResponse");
    return _processResponse(response);
  }

  static Future<bool> validateToken(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/validate-token'), // Replace with your API endpoint
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Include the token
        },
      );

      if (response.statusCode == 200) {
        print('Token is valid');
        return true;
      } else {
        print('Token validation failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error while validating token: $e');
      return false;
    }
  }

  // Register
  static Future<Map<String, dynamic>> register(String email, String password) async {
    const roles = ['users'];
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': email, 'password': password, 'roles': roles,  'type' :2}),
    );
    // var jsonResponse = jsonDecode(response.body);
    // print("Response from API: $jsonResponse");
    return _processResponse(response);
  }

  // Get auth token to pass in headers
  static Future<Map<String, String>> _getHeaders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> _getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userDetailsString = prefs.getString('userDetails');

    // Check if userDetailsString exists and parse it
    if (userDetailsString != null) {
      final userDetails = jsonDecode(userDetailsString); // Parse JSON string into a Map
      return {
        'userDetails': userDetails, // Return the parsed user details
        'userId': userDetails['user']?['id'], // Extract and include the user ID
      };
    }

    // Return an empty map if userDetailsString is null
    return {};
  }
  
  // Logout
  static Future<dynamic> logout() async {
    try{
      final headers = await _getHeaders();
      final response = await http.post(Uri.parse('$baseUrl/logout'),headers: headers);
      // Process the response
      Map<String, dynamic> responseData = _processReturnResponse(response);
      
      return responseData;
    } catch (e) {
      // Return a custom error message
      return {
        'status': 500,
        'message': 'An unexpected error occurred. Please try again.',
      };
    }
  }

  // Process HTTP response
  static Map<String, dynamic> _processResponse(http.Response response) {
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return jsonDecode(response.body);
    }
  }

  static Future<List<dynamic>> getUsers() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$baseUrl/users'),headers: headers);
    var jsonResponse = jsonDecode(response.body);
    print("Response from API: $jsonResponse");
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load users');
    }
  }

  static Future<dynamic> getNotes() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$baseUrl/notes'),headers: headers);

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      print("Response from API: $jsonResponse");
      // Extracting the 'data' from the response body
      if (jsonResponse['data'] != null) {
        return jsonResponse['data']; // Return only the data part
      } else {
        return jsonResponse['data'];
      }
    } else {
      return [];
    }
  }

  static Future<void> deleteUser( String userId, BuildContext context ) async {
    final headers = await _getHeaders();
    final response = await http.delete(Uri.parse('$baseUrl/users'),headers: headers,
      body: jsonEncode({
        'id': userId,
      }));

    try {
      Map<String, dynamic> responseData = _processResponse(response);

      // If no exception is thrown, return successfully
      print('User deleted successfully: $responseData');
    } catch (e) {
      if (response.statusCode == 401 || response.statusCode == 403) {
        // Redirect to login page
        Navigator.pushReplacementNamed(context, '/');
      } else {
        // For other errors, rethrow the exception
        rethrow;
      }
    }
  }

  static Future<Map<String, dynamic>> deleteNote( String noteId, BuildContext context ) async {
    final headers = await _getHeaders();
    print('Received data : $noteId');
    final response = await http.delete(Uri.parse('$baseUrl/notes'),headers: headers,
      body: jsonEncode({
        'id': noteId,
      }));

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Assuming the response is a JSON object
    } else {
      return {
        'status': response.statusCode,
        'message': 'Failed to delete note',
      };
    }
  }

  // Process HTTP response
  static Map<String, dynamic> _processReturnResponse(http.Response response) {
    if (response.statusCode == 200) {
      return {
        'status': response.statusCode,
        'message': jsonDecode(response.body)['message'] ?? 'An error occurred.',
      };
      // return jsonDecode(response.body);
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      // Redirect to login page
      navigatorKey.currentState?.pushReplacementNamed('/');
      return {
        'status': response.statusCode,
        'message': 'Unauthorized access. Redirecting to login.',
      };
    } else {
      // Return the error message from the response
      return {
        'status': response.statusCode,
        'message': jsonDecode(response.body)['message'] ?? 'An error occurred.',
      };
    }
  }

  static Future<Map<String, dynamic>> addUser(Map<String, dynamic> newUser) async {
    print('Data received: $newUser');
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: headers,
        body: jsonEncode({
          'username': newUser['username'],
          'password': newUser['password'],
          'roles': newUser['roles']
        }),
      );
      print('Received response: ${response.body}');
      
      // Process the response
      Map<String, dynamic> responseData = _processReturnResponse(response);
      
      return responseData;
    } catch (e) {
      // Return a custom error message
      return {
        'status': 500,
        'message': 'An unexpected error occurred. Please try again.',
      };
    }
  }

  static Future<Map<String, dynamic>> addRequest(Map<String, dynamic> newRequest) async {
    print('Data received: $newRequest');
    try {
      final headers = await _getHeaders();
      final users = await _getUserDetails();
      var userId = users["userId"];
      print('user details : ${userId}');
      final response = await http.post(
        Uri.parse('$baseUrl/notes'),
        headers: headers,
        body: jsonEncode({
          'title': newRequest['title'],
          'text': newRequest['text'],
          'user': userId,
        }),
      );
      print('Received response: ${response.body}');
      
      // Process the response
      Map<String, dynamic> responseData = _processReturnResponse(response);
      
      return responseData;
    } catch (e) {
      // Return a custom error message
      return {
        'status': 500,
        'message': 'An unexpected error occurred. Please try again.',
      };
    }
  }

  // static Future<void> deleteNote(int noteId) async {
  //   final response = await http.delete(Uri.parse('$baseUrl/notes/$noteId'));
  //   if (response.statusCode != 200) {
  //     throw Exception('Failed to delete note');
  //   }
  // }

}

import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_request_page.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  String username = "Your Requests"; // Default title
  List<dynamic> notes = [];
  List<dynamic> filteredNotes = [];
  bool isLoadingNotes = true;
  String searchQuery = "";

  Future<void> _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDetailsJson = prefs.getString('userDetails');

    if (userDetailsJson != null) {
      Map<String, dynamic> userDetails = jsonDecode(userDetailsJson);
      setState(() {
        username = "Hi, ${userDetails['user']['username']}";
      });
    } else {
      setState(() {
        username = "Your Requests";
      });
    }
  }

  Future<void> fetchNotes() async {
    try {
      var response = await ApiService.getNotes();
      setState(() {
        isLoadingNotes = false;
        notes = response.isNotEmpty ? response : [];
        filteredNotes = notes;
      });
    } catch (e) {
      setState(() {
        isLoadingNotes = false;
      });
      print("Error fetching notes: $e");
    }
  }

  Future<void> _showRequestDeleteDialog(String NoteId, BuildContext context) async {
    bool shouldDeleteUser = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Request delete'),
            content: Text('Are you sure you want to delete this Request?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;

    if (shouldDeleteUser) {
      deleteNote(NoteId, context);
    }
  }

  Future<void> deleteNote(String noteId, BuildContext context) async {
    try {
      await ApiService.deleteNote(noteId, context);
      fetchNotes();
      Fluttertoast.showToast(msg: 'Request deleted successfully');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to delete Request');
    }
  }


  void _filterNotes(String query) {
    setState(() {
      searchQuery = query;
      filteredNotes = notes
          .where((note) =>
              (note['title'] ?? '').toLowerCase().contains(query.toLowerCase()) ||
              (note['text'] ?? '').toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchNotes();
    _loadUsername();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool shouldExit = await _showExitConfirmation();
        return shouldExit;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(username),
          backgroundColor: Colors.blueAccent,
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: _showLogoutDialog,
            ),
          ],
        ),
        body: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: _filterNotes,
                decoration: InputDecoration(
                  hintText: 'Search notes...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            // Notes List
            Expanded(
              child: RefreshIndicator(
              onRefresh: fetchNotes,
              child: isLoadingNotes
                  ? Center(child: CircularProgressIndicator())
                  : filteredNotes.isEmpty
                      ? Center(
                          child: Text(
                            'No Requests available',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(12),
                          itemCount: filteredNotes.length,
                          itemBuilder: (context, index) {
                            var note = filteredNotes[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              elevation: 3,
                              child: ListTile(
                                leading: Icon(Icons.note, size: 40, color: Colors.blueAccent),
                                title: Text(
                                  note['title'] ?? 'No Title',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(note['text'] ?? 'No Requests'),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _showRequestDeleteDialog(note['_id'], context),
                                ),
                              ),
                            );
                          },
                        ),
                        
            ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddRequestPage()),
            );
          },
          backgroundColor: Colors.blueAccent,
          child: Icon(Icons.add),
          tooltip: "Add New Request",
        ),
      ),
    );
  }

  Future<bool> _showExitConfirmation() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Exit App'),
            content: Text('Are you sure you want to exit the app?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _showLogoutDialog() async {
    bool shouldLogout = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Logout'),
            content: Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;

    if (shouldLogout) {
      _performLogout();
    }
  }

  Future<void> _performLogout() async {
    try {
      var response = await ApiService.logout();
      if (response['status'] == 200) {
        Fluttertoast.showToast(msg: response['message']);
        Navigator.pushReplacementNamed(context, '/');
      } else {
        Fluttertoast.showToast(msg: response['message']);
      }
    } catch (error) {
      Fluttertoast.showToast(msg: "Logout failed");
    }
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_user_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> with SingleTickerProviderStateMixin {
  String username = "Admin Dashboard"; // Default title
  late TabController _tabController;
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> notes = [];
  List<String> roles = ['Admin', 'User'];
  bool isLoadingUsers = true;
  bool isLoadingNotes = true;
  int _currentIndex = 0;
  TextEditingController searchController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  List<String> selectedRoles = [];
  bool isAddingUser = false;

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
        username = "Hi, Admin";
      });
    }
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

  Future<void> _showUserDeleteDialog(String userId, BuildContext context) async {
    bool shouldDeleteUser = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('User delete'),
            content: Text('Are you sure you want to delete this User?'),
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
      deleteUser(userId, context);
    }
  }

  Future<void> _showRequestDeleteDialog(String userId, BuildContext context) async {
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
      deleteNote(userId, context);
    }
  }

  Future<void> _performLogout() async {
    try{
      var response = await ApiService.logout();
      if(response['status'] == 200){
        Fluttertoast.showToast(msg: response['message']);
        Navigator.pushReplacementNamed(context, '/');
      }else{
        Fluttertoast.showToast(msg: response['message']);
      }
    }catch(error){
      Fluttertoast.showToast(msg: "Logout failed");
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchUsers();
    fetchNotes();
    _loadUsername();
    searchController.addListener(() {
      setState(() {});
    });
  }

  Future<void> fetchUsers() async {
    var response = await ApiService.getUsers();
    setState(() {
      isLoadingUsers = false;
      if (response.isNotEmpty) {
        users = List<Map<String, dynamic>>.from(response);
      } else {
        users = [];
      }
    });
  }

  Future<void> fetchNotes() async {
    var response = await ApiService.getNotes();
    setState(() {
      isLoadingNotes = false;
      if (response.isNotEmpty) {
        notes = List<Map<String, dynamic>>.from(response);
      } else {
        notes = [];
      }
    });
  }

  Future<void> deleteUser(String userId, BuildContext context) async {
    try {
      await ApiService.deleteUser(userId, context);
      fetchUsers();
      Fluttertoast.showToast(msg: 'User deleted successfully');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to delete User');
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

  void _navigateToAddUserPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddUserPage()),
    ).then((_) {
      fetchUsers(); // Refresh the user list after returning from AddUserPage
    });
  }


  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Widget _getBody() {
    List<Map<String, dynamic>> filteredUsers = users
        .where((user) => (user['username'] ?? '')
            .toLowerCase()
            .contains(searchController.text.toLowerCase()))
        .toList();

    List<Map<String, dynamic>> filteredNotes = notes
        .where((note) => (note['title'] ?? '')
            .toLowerCase()
            .contains(searchController.text.toLowerCase()))
        .toList();

    if (_currentIndex == 0) {
      return isLoadingUsers
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search Users',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: fetchUsers,
                    child: filteredUsers.isEmpty
                        ? Center(child: Text('No users available'))
                        : ListView.builder(
                            padding: EdgeInsets.all(12),
                            itemCount: filteredUsers.length,
                            itemBuilder: (context, index) {
                              var user = filteredUsers[index];
                              return Card(
                                margin: EdgeInsets.symmetric(vertical: 8),
                                elevation: 3,
                                child: ListTile(
                                  leading: Icon(Icons.account_circle, size: 40, color: Colors.blueAccent),
                                  title: Text(
                                    user['username'] ?? 'N/A',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(user['roles']?.join(", ") ?? 'No roles'),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _showUserDeleteDialog(user['_id'], context),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            );
    } else {
      return isLoadingNotes
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search Requests',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: fetchNotes,
                    child: filteredNotes.isEmpty
                        ? Center(child: Text('No requests available'))
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
                                  title: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Text(
                                          note['username'] ?? 'Unknown User : ',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          note['title'] ?? 'No Title',
                                          style: TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  subtitle: Text(note['text'] ?? 'No text'),
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
            );
    }
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
          backgroundColor: Colors.blue,
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: _showLogoutDialog,
            ),
          ],
        ),
        body: _getBody(),
        floatingActionButton: _currentIndex == 0
            ? FloatingActionButton(
                onPressed: _navigateToAddUserPage,
                backgroundColor: Colors.blue,
                child: Icon(Icons.add),
              )
            : null,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          backgroundColor: Colors.blue,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Users',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notes),
              label: 'Requests',
            ),
          ],
        ),
      ),
    );
  }
}

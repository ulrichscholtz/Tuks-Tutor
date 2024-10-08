import 'package:flutter/material.dart';
import 'package:tuks_tutor_dev/components/user_tile.dart';
import 'package:tuks_tutor_dev/pages/chat_page.dart';
import 'package:tuks_tutor_dev/pages/users_page.dart';
import 'package:tuks_tutor_dev/services/auth/auth_service.dart';
import 'package:tuks_tutor_dev/components/my_drawer.dart';
import 'package:tuks_tutor_dev/services/chat/chat_service.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  // Chat & Auth services
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  void logout() async {
    // Get Auth Service
    final authService = AuthService();
    await authService.signOut();
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("C H A T S"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
      ),
      drawer: MyDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: StreamBuilder(
          stream: widget._chatService.getUsersStreamExludingBlocked(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return _buildUserList();
            } else {
              return Center(
                child: Text(
                  "N O  C H A T S",
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UsersPage(),
            ),
          );
        },
        child: Icon(Icons.search, color: Colors.white),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Build User List NOT Logged In User
  Widget _buildUserList() {
    return StreamBuilder(
      stream: widget._chatService.getUsersStreamExludingBlocked(),
      builder: (context, snapshot) {
        // Error
        if (snapshot.hasError) {
          return const Text("Error");
        }

        // Loading...
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Return List View
        List<Map<String, dynamic>> users = snapshot.data!.toList();
        users.sort((a, b) => a["email"].split('@')[0].compareTo(b["email"].split('@')[0]));
        return ListView(
          children: users
              .map<Widget>((userData) => _buildUserListItem(userData, context))
              .toList(),
        );
      },
    );
  }

  // Build User List Item
  Widget _buildUserListItem(Map<String, dynamic> userData, BuildContext context) {
    // Display all users except current logged in user
    final currentUser = widget._authService.getCurrentUser();
    if (currentUser != null && userData["email"] != null && userData["email"] != currentUser.email) {
      String userText = '${userData['studentnr']} | ${userData["email"]!.split('@')[0]}';
      if (userData["usertype"] == "Tutor") {
        userText += ' | ${userData['tutoring']} Tutor';
      }

      return UserTile(
        text: userText,
  onTap: () {
    // Tapped on user, go to chat page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          receiverEmail: userData["email"],
          receiverID: userData["uid"],
              ),
            ),
          );
        }, userType: userData["usertype"],
      );
    } else {
      return Container();
    }
  }
}


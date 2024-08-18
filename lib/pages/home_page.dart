import 'package:flutter/material.dart';
import 'package:tuks_tutor_dev/components/user_tile.dart';
import 'package:tuks_tutor_dev/pages/chat_page.dart';
import 'package:tuks_tutor_dev/services/auth/auth_service.dart';
import 'package:tuks_tutor_dev/components/my_drawer.dart';
import 'package:tuks_tutor_dev/services/chat/chat_service.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  // Chat & Auth services
  final ChatService _chatService = ChatService();
  final AuthService _authService =AuthService();

  void logout() async {
    // Get Auth Service
    final authService = AuthService();
    await authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("U S E R S"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
      ),
      drawer:   MyDrawer(),
      body: StreamBuilder(
        stream: _chatService.getUsersStreamExludingBlocked(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return _buildUserList();
          } else {
            return Center(
              child: Text(
                "No students or tutors available.",
              ),
            );
          }
        },
      ),
    );
  }

  // Build User List NOT Logged In User
  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUsersStreamExludingBlocked(),
      builder: (context, snapshot) {
        // Error
        if (snapshot.hasError) {
          return const Text("Error");
        }

        // Loading...
        if(snapshot.connectionState == ConnectionState.waiting) {
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
    if (userData["email"] != _authService.getCurrentUser()!.email) {
      return UserTile(
      text: userData["email"].split('@')[0],
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
      }
    );
    } else {
      return Container();
    }
  }
}


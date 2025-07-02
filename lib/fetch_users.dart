import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'chat_screen.dart';

class SelectUserScreen extends StatefulWidget {
  const SelectUserScreen({super.key});

  @override
  _SelectUserScreenState createState() => _SelectUserScreenState();
}

class _SelectUserScreenState extends State<SelectUserScreen> {
  List<dynamic> users = [];
  bool isLoading = false;

  void fetchUsers() async {
    setState(() => isLoading = true);
    try {
      List<dynamic> fetchedUsers = await ApiService.getUsers();
      setState(() {
        users = fetchedUsers;
      });
    } catch (e) {
      print("Error fetching users: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void createPrivateRoom(int selectedUserId, String selectedUserName) async {
    await ApiService.loadUserId();
    int currentUserId = ApiService.currentUserId!;
    List<int> userIds = [currentUserId, selectedUserId];

    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/create-room'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "room_name": "private_${currentUserId}_${selectedUserName}",
        "user_ids": userIds
      }),
    );

    final responseData = jsonDecode(response.body);
    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            roomId: responseData["room_id"],
            username: selectedUserName,
            userId: ApiService.currentUserId!,
          ),
        ),
      );
    } else {
      print("❌ Failed to create room: ${responseData['detail']}");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF36393F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1F22),
        title: const Text('Select a User', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : users.isEmpty
          ? const Center(
        child: Text('No users found', style: TextStyle(color: Colors.white70)),
      )
          : ListView.separated(
        itemCount: users.length,
        separatorBuilder: (context, index) => const Divider(
          color: Colors.white12,
          height: 1,
          thickness: 0.5,
        ),
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            leading: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF4F545C),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(10),
              child: const Icon(Icons.person, color: Colors.white),
            ),
            title: Text(
              user['name'],
              style: const TextStyle(color: Colors.white),
            ),
            onTap: () {
              int? selectedUserId = int.tryParse(user['id'].toString());
              if (selectedUserId == null) return;
              createPrivateRoom(selectedUserId, user['name']);
            },
          );
        },
      ),
    );
  }
}

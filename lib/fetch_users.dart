import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart'; // Ensure this contains API calls
import 'chat_screen.dart'; // Ensure this exists

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
        "room_name": "private_${currentUserId}_${selectedUserId}",
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
            userId: ApiService.currentUserId!, // ✅ Add userId here
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
      appBar: AppBar(title: const Text('Select a User')),
      body: users.isEmpty
          ? const Center(child: Text('No users found'))
          : ListView.separated(
        itemCount: users.length,
        separatorBuilder: (context, index) => const Divider(thickness: 0.5, height: 1),
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            title: Text(user['name']),
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

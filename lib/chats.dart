import 'fetch_users.dart';
import 'package:flutter/material.dart';
import 'api_service.dart'; // Ensure this contains API calls
import 'chat_screen.dart'; // Ensure this exists

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<dynamic> rooms = [];
  bool isLoading = false;

  void fetchRooms() async {
    setState(() => isLoading = true);
    try {
      List<dynamic> fetchedRooms = await ApiService.getUserRooms();
      setState(() {
        rooms = fetchedRooms;
      });
    } catch (e) {
      print("Error fetching rooms: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRooms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: rooms.isEmpty
          ? const Center(child: Text('No chats found'))
          : ListView.separated(
        itemCount: rooms.length,
        separatorBuilder: (context, index) => const Divider(thickness: 0.5, height: 1),
        itemBuilder: (context, index) {
          final room = rooms[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
            ),
            title: Text(room['room_name']),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    roomId: room["room_id"],
                    username: room["room_name"],
                    userId: ApiService.currentUserId!, // ✅ Add userId here
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SelectUserScreen()),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.message),
      ),
    );
  }
}


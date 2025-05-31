import 'package:flutter/material.dart';
import 'api_service.dart';
import 'chat_screen.dart';
import 'fetch_users.dart';

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
      backgroundColor: const Color(0xFF36393F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F3136),
        title: const Text('Chats', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : rooms.isEmpty
          ? const Center(
        child: Text('No chats found', style: TextStyle(color: Colors.white70)),
      )
          : ListView.separated(
        itemCount: rooms.length,
        separatorBuilder: (context, index) => const Divider(
          color: Colors.white12,
          height: 1,
          thickness: 0.5,
        ),
        itemBuilder: (context, index) {
          final room = rooms[index];
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
              room['room_name'],
              style: const TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    roomId: room["room_id"],
                    username: room["room_name"],
                    userId: ApiService.currentUserId!,
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "all_users",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SelectUserScreen()),
              );
            },
            backgroundColor: const Color(0xFF3BA55C), // Discord green
            child: const Icon(Icons.people, color: Colors.white),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "message_icon",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SelectUserScreen()),
              );
            },
            backgroundColor: const Color(0xFF5865F2), // Discord blue
            child: const Icon(Icons.message, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

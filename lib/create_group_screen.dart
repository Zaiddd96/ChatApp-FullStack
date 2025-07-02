import 'package:flutter/material.dart';
import 'package:student_registration/api_service.dart';


class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  List<dynamic> users = [];
  Set<int> selectedUserIds = {};
  int? currentUserId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await ApiService.loadUserId();
    currentUserId = ApiService.currentUserId;
    selectedUserIds.add(currentUserId!);

    try {
      final fetchedUsers = await ApiService.getUsers();
      setState(() {
        users = fetchedUsers.where((u) => u['id'] != currentUserId).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  void toggleSelection(int userId) {
    setState(() {
      if (selectedUserIds.contains(userId)) {
        selectedUserIds.remove(userId);
      } else {
        selectedUserIds.add(userId);
      }
    });
  }

  void showCreateRoomDialog() {
    String roomName = "";
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2F3136),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Enter Group Name", style: TextStyle(color: Colors.white)),
        content: TextField(
          onChanged: (value) => roomName = value,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Group name",
            hintStyle: TextStyle(color: Colors.white38),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
          ),ElevatedButton(
            onPressed: () async {
              if (roomName.trim().isEmpty) return;

              Navigator.pop(context); // Close the dialog

              await ApiService.createRoom(
                userIds: selectedUserIds.toList(),
                roomName: roomName.trim(),
              );

              Navigator.pop(context); // Go back after room creation
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            child: const Text("Create", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF36393F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1F22),
        title: const Text("Select Users", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: selectedUserIds.length > 1 ? showCreateRoomDialog : null,
            child: const Text("Next", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          final isSelected = selectedUserIds.contains(user['id']);

          return ListTile(
            tileColor: isSelected ? const Color(0xFF5865F2).withOpacity(0.3) : Colors.transparent,
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
            onLongPress: () => toggleSelection(user['id']),
            onTap: () => toggleSelection(user['id']),
          );
        },
      ),
    );
  }
}

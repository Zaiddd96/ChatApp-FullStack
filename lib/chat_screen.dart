import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'api_service.dart';

class ChatScreen extends StatefulWidget {
  final int roomId;
  final String username;
  final int userId;

  const ChatScreen({super.key, required this.roomId, required this.username, required this.userId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<dynamic> messages = [];
  bool isLoading = false;
  final TextEditingController messageController = TextEditingController();
  late IOWebSocketChannel channel;

  @override
  void initState() {
    super.initState();
    fetchMessages();
    connectWebSocket();
  }

  void fetchMessages() async {
    setState(() => isLoading = true);
    try {
      List<dynamic> fetchedMessages = await ApiService.getRoomMessages(widget.roomId);
      setState(() => messages = fetchedMessages);
    } catch (e) {
      print("Error loading messages: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void connectWebSocket() {
    channel = IOWebSocketChannel.connect("ws://your-backend-url/ws/${widget.roomId}/${widget.userId}");

    channel.stream.listen((data) {
      setState(() {
        messages.add(jsonDecode(data));
      });
    });
  }

  void sendMessage() {
    if (messageController.text.isEmpty) return;

    final message = {
      "room_id": widget.roomId,
      "user_id": widget.userId,
      "content": messageController.text,
    };

    channel.sink.add(jsonEncode(message));

    setState(() {
      messages.add({
        "user_id": widget.userId,
        "content": messageController.text,
        "timestamp": DateTime.now().toIso8601String(),
      });
    });

    messageController.clear();
  }

  @override
  void dispose() {
    channel.sink.close();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.username)),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : messages.isEmpty
                ? const Center(child: Text("No messages yet"))
                : ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                bool isMe = msg["user_id"] == widget.userId;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(msg["content"], style: TextStyle(color: isMe ? Colors.white : Colors.black)),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

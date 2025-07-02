import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'api_service.dart';
import 'package:intl/intl.dart';


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
  final ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    super.initState();
    fetchMessages();
    connectWebSocket();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void fetchMessages() async {
    setState(() => isLoading = true);

    try {
      List<dynamic> fetchedMessages = await ApiService.getRoomMessages(widget.roomId);
      setState(() => messages = fetchedMessages);
      scrollToBottom();
    } catch (e) {
      print("Error loading messages: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void connectWebSocket() {
    channel = IOWebSocketChannel.connect("ws://tr8lhmndjg.ap.loclx.io/ws/${widget.roomId}/${widget.userId}");

    channel.stream.listen((data) {
      final decoded = jsonDecode(data);

      if (decoded is Map &&
          decoded["content"] != null &&
          decoded["user_id"] != null &&
          decoded["timestamp"] != null) {
        setState(() {
          messages.add(decoded);
        });
        scrollToBottom();
      } else {
        print("⚠️ Skipped invalid or incomplete message: $decoded");
      }
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
      backgroundColor: const Color(0xFF36393F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1F22),
        title: Text(widget.username, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : messages.isEmpty
                ? const Center(child: Text("No messages yet", style: TextStyle(color: Colors.white70)))
                : ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                bool isMe = msg["user_id"] == widget.userId;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFF5865F2) : const Color(0xFF4F545C),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(
                    msg["content"] ?? '',
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      msg["timestamp"] != null
                          ? DateFormat('hh:mm a').format(DateTime.parse(msg["timestamp"]).toLocal())
                          : '',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white54,
                      ),
                    ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: const Color(0xFF2F3136),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF40444B),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF5865F2)),
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

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';


class ApiService {
  static const String baseUrl = "https://chatapp-backend-x4uo.onrender.com";

  // Store the logged-in user's ID
  static int? currentUserId;

  // ✅ Save User ID to SharedPreferences
  static Future<void> saveUserId(int userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("current_user_id", userId);
    currentUserId = userId;
    print("✅ Saved User ID: $currentUserId");
  }

  // ✅ Load User ID from SharedPreferences
  static Future<void> loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentUserId = prefs.getInt("current_user_id");
    print("🔄 Loaded User ID: $currentUserId");
  }

  static Future<List<dynamic>> getUserRooms() async {
    await loadUserId();
    if (currentUserId == null) {
      throw Exception("User ID not loaded");
    }

    final response = await http.get(Uri.parse('$baseUrl/rooms?user_id=$currentUserId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load rooms");
    }
  }

  static Future<Map<String, dynamic>> createRoom({
    required List<int> userIds,
    required String roomName,
  }) async {
    final url = Uri.parse('$baseUrl/create-room');
    final headers = {"Content-Type": "application/json"};
    final body = jsonEncode({
      "user_ids": userIds,
      "room_name": roomName,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create room: ${response.body}');
    }
  }

  static Future<List<dynamic>> getRoomMessages(int roomId) async {
    final response = await http.get(Uri.parse("$baseUrl/get-messages/$roomId"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Error fetching messages: ${response.body}");
      return [];
    }
  }

  // Function to hash OTP before sending
  static String hashOTP(String otp) {
    var bytes = utf8.encode(otp); // Convert OTP to bytes
    var digest = sha256.convert(bytes); // Hash using SHA-256
    return digest.toString(); // Return hashed OTP as a string
  }

  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      print("Login API Response (${response.statusCode}): ${response.body}"); // Debugging print

      if (response.statusCode == 200) {
        try {
          Map<String, dynamic> responseData = jsonDecode(response.body);

          if (responseData.containsKey("message")) {
            // ✅ Login successful, now send OTP
            bool otpSent = await sendOTP(email);

            if (otpSent) {
              return {
                "message": "Login successful. OTP sent to email.",
                "email": email,
                "access_token": responseData["access_token"]
              };
            } else {
              return {"error": "Login successful, but failed to send OTP."};
            }
          } else {
            return {"error": "Login failed: No access token received."};
          }
        } catch (e) {
          print("JSON Parsing Error: $e");
          return {"error": "Invalid server response format."};
        }
      } else if (response.statusCode == 401) {
        return {"error": "Unauthorized: Invalid email or password."};
      } else if (response.statusCode == 500) {
        return {"error": "Server error: Please try again later."};
      } else {
        return {"error": "Unexpected error: ${response.statusCode}."};
      }
    } catch (e) {
      print("Login API Error: $e");
      return {"error": "Network error: Please check your connection."};
    }
  }

  static Future<bool> sendOTP(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send-otp'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      print("Send OTP API Response (${response.statusCode}): ${response
          .body}"); // Debugging print

      if (response.statusCode == 200) {
        return true; // OTP sent successfully
      } else {
        return false; // Failed to send OTP
      }
    } catch (e) {
      print("Send OTP API Error: $e");
      return false; // Handle network failure
    }
  }

  static Future<Map<String, dynamic>?> verifyOTP(String email,
      String otp) async {

    final prefs = await SharedPreferences.getInstance();

    final response = await http.post(
      Uri.parse('$baseUrl/verify-otp'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "otp": otp}), // ✅ Send raw OTP
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData.containsKey("current_user_id")) {
        int userId = responseData["current_user_id"];
        // ✅ Save User ID
        await ApiService.saveUserId(userId);
      }
      if (responseData.containsKey("username")) {
        String username = responseData["username"];
        await prefs.setString("username", username); // ✅ Store username
      }

      return responseData;
    } else {
      return {"error": "Invalid OTP"};
    }
}


  static Future<Map<String, dynamic>> register(String name, String email, String password, String role) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "email": email, "password": password, "role": role}),
    );
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getUsers() async {
    final response = await http.get(Uri.parse("$baseUrl/users"));
    return jsonDecode(response.body);
  }

  // update password functionality
  static Future<Map<String, dynamic>> sendResetOtp(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/send-reset-otp'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to send reset OTP");
    }
  }

  static Future<Map<String, dynamic>> verifyResetOtp(String email, String otp) async {

    final response = await http.post(
      Uri.parse('$baseUrl/verify-reset-otp'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "otp": otp}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Invalid OTP");
    }
  }

  static Future<Map<String, dynamic>> resetPassword(String email, String newPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reset-password'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "new_password": newPassword}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Password reset failed.");
    }
  }

  // websocket functionalities
  static const String webSocketBaseUrl = "ws://chatapp-backend-x4uo.onrender.com";
  static WebSocketChannel? _channel;

  static void connectToChat(int roomId, int userId, Function(dynamic) onMessageReceived) {
    _channel = WebSocketChannel.connect(Uri.parse("$webSocketBaseUrl/ws/$roomId/$userId"));

    _channel!.stream.listen((message) {
      onMessageReceived(jsonDecode(message));
    });
  }

  static void sendMessage(String content) {
    if (_channel != null) {
      _channel!.sink.add(content);
    }
  }

  static void disconnect() {
    _channel?.sink.close();
  }

}




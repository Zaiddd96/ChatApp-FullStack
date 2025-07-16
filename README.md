# 💬 Real-Time Chat App

A real-time chat application built with **Flutter** (Frontend), **FastAPI** (Backend), and **PostgreSQL** (Database). Includes modern authentication, encrypted OTP/password flow, biometric login, and persistent chat rooms.

---

## 🚀 Tech Stack

| Layer    | Technology          |
| -------- | ------------------- |
| Frontend | Flutter             |
| Backend  | FastAPI (WebSocket) |
| Database | PostgreSQL          |

---

## 📦 Dependencies

### Flutter

```yaml
dependencies:
  flutter:
  http:
  shared_preferences:
  web_socket_channel:
  intl:
  local_auth:
```

### Backend (Python)

```bash
fastapi
uvicorn
sqlalchemy
psycopg2-binary
python-jose[cryptography]  # for JWT
smtplib       # for sending emails
```

---

## ✅ Features

### 👤 Authentication

* JWT-based login + OTP verification (OTP & password hashed in DB)
* SharedPreferences for storing user ID and JWT token
* Password reset with OTP
* Biometric login with `local_auth`

### 💬 Chat System

* WebSocket-based real-time messaging
* Chat inside private or group rooms
* Create & join rooms
* Persistent messages (PostgreSQL)
* Auto-scroll to latest message
* Last message + timestamp shown on chat list screen

### 📂 State & Storage

* `SharedPreferences` to store:

  * `current_user_id`
  * (planned: `username` for better UX)

---

## 📁 Project Structure

```
lib/
├── auth/
│   └── screens/
│       ├── auth_gate.dart
│       ├── forgot_password_screen.dart
│       ├── login_screen.dart
│       ├── otpscreen.dart
│       ├── register_screen.dart
│       └── reset_password_screen.dart
│
├── chat/
│   └── screens/
│       ├── chat_screen.dart
│       ├── chats.dart
│       ├── create_group_screen.dart
│       └── fetch_users.dart
│
├── services/
│   ├── api_service.dart
│   └── biometric_auth.dart
│
└── main.dart
```

---

## 🛠️ Setup & Run

### 1. Backend (FastAPI)

```bash
cd backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --reload
```

### 2. Frontend (Flutter)

```bash
flutter pub get
flutter run
```

Make sure your backend URL is correctly set in `api_service.dart`.

Example:

```dart
static const baseUrl = "http://<your-localhost-or-tunnel>";
```

### 3. PostgreSQL Setup

* Create DB & Tables (Users, Messages, Rooms, RoomMembers)
* SQLAlchemy handles schema (via `Base.metadata.create_all`)

---

## 🔐 JWT Authentication

* Token is returned on successful OTP verification
* Stored in SharedPreferences
* Backend validates token on protected endpoints

---

## 📱 Biometric Login

* Uses `local_auth`
* User prompted for fingerprint before accessing app if previously authenticated

---

---

## 🧑‍💻 Author

Built as an individual project for internship learning.

---

## 📃 License

MIT License - feel free to fork & customize.

# Flutter + FastAPI Real-time Chat App

A modern real-time chat application built using **Flutter** (frontend), **FastAPI** (backend), and **PostgreSQL** (database). It supports real-time messaging using WebSocket, OTP-based login and password reset, persistent authentication with JWT, and biometric login support.

---

## 📦 Tech Stack

### Frontend

* **Framework**: Flutter
* **Language**: Dart
* **Libraries & Packages**:

  * [`http`](https://pub.dev/packages/http): REST API communication
  * [`web_socket_channel`](https://pub.dev/packages/web_socket_channel): WebSocket support
  * [`shared_preferences`](https://pub.dev/packages/shared_preferences): Persistent local storage
  * [`local_auth`](https://pub.dev/packages/local_auth): Biometric authentication (fingerprint)
  * [`intl`](https://pub.dev/packages/intl): Date and time formatting
  * [`image_picker`](https://pub.dev/packages/image_picker): Optional image capture (if used later)

### Backend

* **Framework**: FastAPI (Python 3.10+)
* **Libraries**:

  * `fastapi`, `uvicorn`, `sqlalchemy`, `psycopg2`, `pydantic`
  * `python-jose` for JWT handling
  * `hashlib` for secure OTP/password storage

### Database

* **PostgreSQL**
* Tables: `users`, `rooms`, `room_members`, `messages`

---

## 🔐 User Features

* ✅ Secure login using email + password
* ✅ OTP-based email verification
* ✅ Passwords and OTPs stored securely (hashed with SHA256)
* ✅ JWT-based authentication (token sent after OTP verification)
* ✅ Persistent login (JWT stored locally with SharedPreferences)
* ✅ Password reset flow with OTP verification
* ✅ Biometric login (fingerprint)

---

## 💬 Chat Features

* ⚡ Real-time chat using WebSocket: `/ws/{room_id}/{user_id}`
* 🧑‍🤝‍🧑 Create private and group rooms
* 💬 Chat within rooms
* 💾 Messages saved in PostgreSQL with timestamp
* 🔁 Old messages reloaded when chat is reopened
* 🕒 Timestamps displayed with formatted time (using `intl`)
* 🔽 Scrolls to bottom automatically for new messages
* 📋 Room list displays last message and its time

---

## ✅ Backend Highlights

* WebSocket endpoint: `/ws/{room_id}/{user_id}`
* `User`, `Room`, `RoomMember`, and `Message` models
* OTP and password securely hashed
* JWT token expiry handled via payload (not stored in DB)

---

## 🧠 State & Local Storage

* `SharedPreferences` stores:

  * `current_user_id`
  * (Future) `current_username` for private room naming
* `ApiService` class handles all API logic:

  * Login, OTP verification
  * Password reset
  * WebSocket connection
  * Room creation, user listing, message fetching

---

## 🚀 Getting Started

### ✅ Prerequisites

* Flutter SDK installed
* Android Studio or VS Code
* PostgreSQL running locally or via cloud (e.g. Supabase, Render DB)
* Python 3.10+
* `pipenv` or `virtualenv` (optional for backend)

### 🛠️ Backend Setup

1. **Clone repo**

```bash
cd backend/
pip install -r requirements.txt
```

2. **Run FastAPI server**

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

> Make sure DB credentials are set in `.env` or inside `database.py`.

### 💻 Flutter Setup

1. **Install packages**

```bash
cd flutter_app/
flutter pub get
```

2. **Configure base URL** in `ApiService`

```dart
static String baseUrl = "http://your-ip:8000"; // or tunnel url
```

3. **Run App**

```bash
flutter run
```

### ⚡ Optional (For WebSocket in Localhost)

Use `loclx`, `ngrok`, or similar tunnel to expose local server:

```bash
loclx tunnel --port 8000 --https
```

Then update `WebSocket` connection URL in Flutter accordingly.

---

## 📁 Project Structure

```
/backend
  |- main.py
  |- models/
  |- routes/
  |- database.py
  |- utils.py

/flutter_app
  |- lib/
     |- auth/
     |- chat/
     |- services/api_service.dart
     |- screens/login_screen.dart
     |- main.dart
```

---

## 🤝 Contribution

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

---

## 📜 License

[MIT](https://choosealicense.com/licenses/mit/)

---

## 🔑 Key Highlights

* Clean architecture for both frontend and backend
* Real-time WebSocket-powered messaging
* Fully secure OTP + JWT auth
* Auto scroll, room metadata, fingerprint login support
* Ready for extensions like typing indicators, image sharing, read receipts

---

> Feel free to fork, modify, and use this template for your own projects.

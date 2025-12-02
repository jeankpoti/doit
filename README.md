# Do It - Todo App

A beautiful and feature-rich todo application built with Flutter. This project is now open source and available on GitHub for the community to contribute and learn from.

## Features

- ✅ **Full Offline Support** - Works completely offline with automatic sync when online
- 📝 Create, edit, and delete todos with instant responsiveness
- ✨ Mark todos as completed with smooth animations
- 📅 Sync todos with device calendar
- 🔄 Pull-to-refresh functionality
- 🍅 Built-in Pomodoro timer for productivity
- 📊 Statistics and analytics for task tracking
- 🌙 Dark/Light theme support
- 🔔 Local notifications
- ⭐ Rate and share the app with friends
- 🎨 Clean and intuitive user interface

## Screenshots

![App Screenshot](assets/screenshots/Work%20Snap%20UI%20Kit.jpg)

## Architecture

This project follows **Clean Architecture** principles with a feature-based modular structure:

### 🏗️ **Project Structure**
```
lib/
├── features/                    # Feature modules
│   ├── account/                # Authentication & account management
│   ├── pomodoro/               # Pomodoro timer functionality  
│   ├── stats/                  # Statistics and analytics
│   └── todo/                   # Todo/task management
│       ├── data/               # Data layer (repositories)
│       ├── domain/             # Business logic (models, interfaces)
│       └── presentation/       # UI layer (pages, cubits, widgets)
├── common_widget/              # Reusable UI components
├── constants/                  # App constants
├── theme/                      # Theme management
└── utils/                      # Utility functions
```

### 🧠 **State Management**
- **Flutter BLoC (Cubit)** - Primary state management solution
- **Key Cubits**: `TodoCubit`, `PomodoroCubit`, `AccountCubit`, `ThemeCubit`
- **Local Storage**: `SharedPreferences` for user preferences

### 💾 **Data Layer**
- **Primary Database**: [Sembast](https://pub.dev/packages/sembast) (NoSQL document database)
- **Remote Storage**: Firebase Firestore for cloud sync
- **Hybrid Repository Pattern**: Seamless local/remote data management

## 🌐 Offline-First Architecture

This app implements a **production-ready offline-first architecture** ensuring full functionality without internet connection:

### **Key Offline Features:**

- **📱 Instant Responsiveness**: All operations work immediately from local database
- **🔄 Automatic Sync**: Background synchronization when connectivity is restored
- **⚡ Smart Conflict Resolution**: "Latest wins" strategy for data merging
- **🏷️ Sync Flags**: Intelligent tracking of changes that need synchronization
- **📊 Local Analytics**: Statistics and charts work completely offline
- **🔔 Offline Notifications**: Local notifications function without internet
- **📅 Calendar Integration**: Sync to device calendar with deferred cloud sync

### **How It Works:**

1. **Write Operations**: Instantly saved locally with sync flags
2. **Read Operations**: Always served from local database for speed
3. **Connectivity Detection**: Automatic monitoring of internet status
4. **Background Sync**: Seamless data synchronization when online
5. **Graceful Degradation**: App remains fully functional when offline

### **Technical Implementation:**
```dart
// Hybrid Repository Pattern
SembastTodoRepo (local) + FirebaseTodoRepo (remote)
├── Offline: All operations use local database
├── Online: Background sync with cloud storage
└── Conflict Resolution: Smart merging strategies
```

## Getting Started

This is a Flutter application. To run this project:

1. Make sure you have Flutter installed on your machine
2. Clone this repository
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the app

## Contributing

This project is open source! Contributions are welcome. Please feel free to submit issues, feature requests, or pull requests.

## Resources

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [Flutter documentation](https://docs.flutter.dev/)

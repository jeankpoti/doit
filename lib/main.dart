import 'package:do_it/splash_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'features/account/data/repository/account_repo.dart';
import 'features/account/domain/repository/account_repo.dart';
import 'features/account/presentation/account_cubit.dart';
import 'features/pomodoro/data/repository/pomodoro_repo.dart';
import 'features/pomodoro/presentation/pomodoro_cubit.dart';
import 'features/todo/data/repository/sembast_todo_repo.dart';
import 'features/todo/domain/repository/todo_repo.dart';
import 'features/todo/presentation/todo_cubit.dart';
import 'firebase_options.dart';
import 'theme/theme_cubit.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // This is critical: must happen *before* runApp().
  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions.currentPlatform, // If using the FlutterFire CLI
  );

  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;

  // 1) Time zone initialization
  tz.initializeTimeZones();

  // Get the current time zone name
  final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();

  // Optionally set local location:
  tz.setLocalLocation(tz.getLocation(timeZoneName));

  // 2) Request (and/or check) notification permission on iOS/macOS
  await _requestPermissions();

  // 3) Initialize local notifications
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings iosSettings =
      DarwinInitializationSettings();

  const InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
    macOS: iosSettings, // if you want to support macOS
  );

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (details) {
      // Handle tapped notification if needed
      debugPrint('Notification tapped: ${details.payload}');
    },
  );

  // get the application documents directory
  final dir = await getApplicationDocumentsDirectory();
// make sure it exists
  await dir.create(recursive: true);
// build the database path
  final dbPath = path.join(dir.path, 'my_database.db');
// open the database
  final db = await databaseFactoryIo.openDatabase(dbPath);

  //initialize repo with isar database
  final isarTodoRepo = SembastTodoRepo(db);

  final pomodoroRepo = IsarPomodoroRepo();

  final accountRepo = FirebaseRepo();

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<TodoCubit>(
        create: (context) => TodoCubit(isarTodoRepo),
      ), // Ensure this is added
      BlocProvider<ThemeCubit>(
        create: (context) => ThemeCubit(isDarkMode),
      ), // Ensure this is added
      BlocProvider<PomodoroCubit>(
        create: (context) => PomodoroCubit(pomodoroRepo),
      ),
      BlocProvider<AccountCubit>(
        create: (context) => AccountCubit(accountRepo),
      ),
    ],
    child: MyApp(
      todoRepo: isarTodoRepo,
    ),
  ));
}

/// For iOS/macOS: request notification permission
Future<void> _requestPermissions() async {
  final iosPlugin =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
  final macPlugin =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin>();

  await iosPlugin?.requestPermissions(
    alert: true,
    badge: true,
    sound: true,
  );
  await macPlugin?.requestPermissions(
    alert: true,
    badge: true,
    sound: true,
  );
}

class MyApp extends StatelessWidget {
  // Database injection through the app
  final TodoRepo todoRepo;

  const MyApp({super.key, required this.todoRepo});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeData>(
      builder: (context, currentTheme) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Work Snap',
          theme: currentTheme,
          home: SplashPage(todoRepo: todoRepo),
          // TodoPage(todoRepo: todoRepo),
        );
      },
    );
  }
}

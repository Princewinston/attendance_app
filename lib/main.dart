import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'db/settings_storage.dart';
import 'db/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage
  await SettingsStorage.instance.init();
  
  // Initialize DB (creates tables and populates default data)
  await DatabaseHelper.instance.database;

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final SettingsStorage _settings = SettingsStorage.instance;
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = _settings.isDarkMode;
  }

  void _changeTheme(bool isDark) {
    setState(() {
      _isDarkMode = isDark;
      _settings.setDarkMode(isDark);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CR Attendance App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: HomeScreen(onThemeChanged: _changeTheme),
    );
  }
}

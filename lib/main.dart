// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'text_editor_page.dart';

void main() {
  runApp(const BreezeApp());
}

class BreezeApp extends StatefulWidget {
  const BreezeApp({super.key});

  @override
  _BreezeAppState createState() => _BreezeAppState();
}

class _BreezeAppState extends State<BreezeApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    _saveThemePreference(_isDarkMode);
  }

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _saveThemePreference(bool isDarkMode) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('isDarkMode', isDarkMode);
  }

  Future<void> _loadThemePreference() async {
    final preferences = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = preferences.getBool('isDarkMode') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Breeze Editor',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: TextEditorPage(isDarkMode: _isDarkMode, toggleTheme: _toggleTheme),
    );
  }
}

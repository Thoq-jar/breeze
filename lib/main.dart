// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Breeze',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: TextEditorPage(isDarkMode: _isDarkMode, toggleTheme: _toggleTheme),
    );
  }
}

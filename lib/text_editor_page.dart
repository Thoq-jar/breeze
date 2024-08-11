// ignore_for_file: use_build_context_synchronously, avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

class TextEditorPage extends StatefulWidget {
  final bool isDarkMode;
  final Function toggleTheme;

  const TextEditorPage({
    super.key,
    required this.isDarkMode,
    required this.toggleTheme,
  });

  @override
  _TextEditorPageState createState() => _TextEditorPageState();
}

class _TextEditorPageState extends State<TextEditorPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        RawKeyboard.instance.addListener(_handleKeyEvent);
      } else {
        RawKeyboard.instance.removeListener(_handleKeyEvent);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.isControlPressed && event.logicalKey == LogicalKeyboardKey.keyS) {
        _saveFile();
      } else if (event.isControlPressed && event.logicalKey == LogicalKeyboardKey.keyO) {
        _openFile();
      }
    }
  }

  Future<void> _saveFile() async {
    await saveFile(_controller.text);
  }

  Future<void> _openFile() async {
    await openFile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Breeze Editor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveFile,
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: _openFile,
          ),
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.wb_sunny : Icons.nights_stay),
            onPressed: () => widget.toggleTheme(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: RawKeyboardListener(
          focusNode: _focusNode,
          child: Column(
            children: [
              Expanded(
                child: TextField(
                  maxLines: null,
                  expands: true,
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Start typing here...',
                    hintStyle: TextStyle(color: widget.isDarkMode ? Colors.grey : Colors.black54),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> saveFile(String content) async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final result = await FilePicker.platform.saveFile(
          dialogTitle: 'Please select an output file:',
          fileName: 'my_text.txt',
          type: FileType.custom,
          allowedExtensions: [
            'txt', 'md', 'dart', 'json', 'yaml', 'yml', 'toml', 'csv', 'xml',
            'html', 'css', 'js', 'ts', 'sh', 'bat', 'ps1', 'java', 'kt', 'swift',
            'php', 'rb', 'py', 'go', 'rs', 'sql', 'pl', 'r', 'cs', 'cpp', 'h', 'm',
          ],
        );

        if (result != null) {
          final file = File(result);
          await file.writeAsString(content);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File saved to $result')),
          );
        }
      } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        final result = await FilePicker.platform.saveFile(
          dialogTitle: 'Please select an output file:',
          fileName: 'my_text.txt',
          type: FileType.custom,
          allowedExtensions: [
            'txt', 'md', 'dart', 'json', 'yaml', 'yml', 'toml', 'csv', 'xml',
            'html', 'css', 'js', 'ts', 'sh', 'bat', 'ps1', 'java', 'kt', 'swift',
            'php', 'rb', 'py', 'go', 'rs', 'sql', 'pl', 'r', 'cs', 'cpp', 'h', 'm',
          ],
        );

        if (result != null) {
          final file = File(result);
          await file.writeAsString(content);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File saved to $result')),
          );
        }
      } else if (kIsWeb) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Web support is not (yet) implemented!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error saving file')),
      );
    }
  }

  Future<void> openFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'txt', 'md', 'dart', 'json', 'yaml', 'yml', 'toml', 'csv', 'xml',
          'html', 'css', 'js', 'ts', 'sh', 'bat', 'ps1', 'java', 'kt', 'swift',
          'php', 'rb', 'py', 'go', 'rs', 'sql', 'pl', 'r', 'cs', 'cpp', 'h', 'm',
        ],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        String content = '';

        if (file.bytes != null) {
          content = String.fromCharCodes(file.bytes!);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error reading file bytes')),
          );
          return;
        }

        setState(() {
          _controller.text = content;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error opening file')),
      );
    }
  }
}

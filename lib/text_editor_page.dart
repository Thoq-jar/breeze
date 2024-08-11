// ignore_for_file: library_private_types_in_public_api

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Breeze'),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.wb_sunny : Icons.nights_stay),
            onPressed: () => widget.toggleTheme(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await saveFile(_controller.text);
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await openFile();
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> saveFile(String content) async {
    String? outputFilePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an output file:',
      fileName: 'my_text.txt',
      type: FileType.custom,
      allowedExtensions: ['txt', 'md'],
    );

    if (outputFilePath != null) {
      await File(outputFilePath).writeAsString(content);
    }
  }

  Future<void> openFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'md'],
    );

    if (result != null && result.files.isNotEmpty) {
      PlatformFile file = result.files.first;
      String content = await File(file.path!).readAsString();
      setState(() {
        _controller.text = content;
      });
    }
  }
}

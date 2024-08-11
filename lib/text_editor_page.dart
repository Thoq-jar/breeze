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
  // ignore: library_private_types_in_public_api
  _TextEditorPageState createState() => _TextEditorPageState();
}

class _TextEditorPageState extends State<TextEditorPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Breeze Text Editor'),
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
                  hintText: 'Edit your text here...',
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
    FilePickerResult? result = await FilePicker.platform.pickSaveFile(
      type: FileType.text,
    );

    PlatformFile file = result.files.first;
    await file.writeAsString(content);
    if (kDebugMode) {
      if (kDebugMode) {
      }
    }
    }

  Future<void> openFile() async {
    FilePickerResult? result = await FilePicker.platform.showFilesPicker(
      type: FileType.custom,
      allowedExtensions: ['txt', 'md'],
    );

    PlatformFile file = result.files.first;
    String content = await file.readAsString();
    if (kDebugMode) {
    }
    setState(() {
      _controller.text = content;
    });
    }
}

extension on FilePicker {
  showFilesPicker({required FileType type, required List<String> allowedExtensions}) {}
}

extension on PlatformFile {
  readAsString() {}
}

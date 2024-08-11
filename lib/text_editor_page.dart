// ignore_for_file: use_build_context_synchronously, avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

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
  bool _isPreviewMode = false;
  double _fontSize = 16.0;
  
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

  Future<void> _openSettings() async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SettingsPage(
          isDarkMode: widget.isDarkMode,
          toggleTheme: widget.toggleTheme,
          changeFontSize: changeFontSize,
          about: about,
        ),
      ),
    );
  }
  
    void about() {
      showAboutDialog(context: context, applicationName: 'Breeze Editor', applicationVersion: '1.0.0', applicationIcon: const Icon(Icons.edit), children: [
        const Text('A lightweight, fast and simple and open source Text/Markdown editor.'),
        const Text('Made with <3 by the Thoq.'),
        const Text('Source code available at https://github.com/Thoq-jar/breeze'),
      ]);
    }

    void changeFontSize() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          double selectedFontSize = _fontSize;
          return AlertDialog(
            title: const Text('Change Font Size'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return Column(
                        children: [
                          Slider(
                            value: selectedFontSize,
                            min: 10.0,
                            max: 30.0,
                            onChanged: (double value) {
                              setState(() {
                                selectedFontSize = value;
                              });
                            },
                          ),
                          Text('Selected Font Size: ${selectedFontSize.toStringAsFixed(1)}'),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Apply'),
                onPressed: () {
                  setState(() {
                    _fontSize = selectedFontSize;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    void _togglePreviewMode() {
    setState(() {
      _isPreviewMode = !_isPreviewMode;
    });
  }
 
   Future<void> _openActions() async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ActionsPage(
          saveFile: _saveFile,
          openFile: _openFile,
          togglePreviewMode: _togglePreviewMode,
        ),
      ),
    );
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Breeze Editor',
          style: TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.w300,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Actions',
            icon: const Icon(Icons.menu),
            onPressed: _openActions,
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: RawKeyboardListener(
          focusNode: _focusNode,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  child: _isPreviewMode
                      ? Markdown(data: _controller.text)
                        : TextField(
                          maxLines: null,
                          expands: true,
                          controller: _controller,
                          style: TextStyle(fontSize: _fontSize),
                          decoration: InputDecoration(
                          hintText: 'Start typing here...',
                          hintStyle: TextStyle(color: widget.isDarkMode ? Colors.grey : Colors.black54, fontSize: _fontSize),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Future<void> saveFile(String content) async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final result = await FilePicker.platform.saveFile(
          dialogTitle: 'Save:',
          fileName: 'foo.txt',
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
          fileName: 'foo.txt',
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
        SnackBar(content: Text('Error saving file $e')),
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

class SettingsPage extends StatelessWidget {
  final bool isDarkMode;
  final Function toggleTheme;
  final Function changeFontSize;
  final Function about;

  const SettingsPage({
    super.key,
    required this.isDarkMode,
    required this.toggleTheme,
    required this.changeFontSize,
    required this.about,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Breeze Settings'),
      ),
      body: Column(
        children: [
          ListTile(
            leading: Icon(isDarkMode ? Icons.wb_sunny : Icons.nights_stay),
            title: const Text('Toggle Theme'),
            onTap: () => toggleTheme(),
          ),
          ListTile(
            leading: const Icon(Icons.font_download),
            title: const Text('Font Size'),
            onTap: () => changeFontSize(),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () => about(),
          ),
          ListTile(
            leading: const Icon(Icons.close),
            title: const Text('Close'),
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class ActionsPage extends StatelessWidget {
  final Future<void> Function() saveFile;
  final Future<void> Function() openFile;
  final void Function() togglePreviewMode;

  const ActionsPage({
    super.key,
    required this.saveFile,
    required this.openFile,
    required this.togglePreviewMode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actions'),
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.save),
            title: const Text('Save File'),
            onTap: () => saveFile(),
          ),
          ListTile(
            leading: const Icon(Icons.open_in_new),
            title: const Text('Open File'),
            onTap: () => openFile(),
          ),
          ListTile(
            leading: const Icon(Icons.preview),
            title: const Text('Toggle Markdown Preview'),
            onTap: () => togglePreviewMode(),
          ),
          ListTile(
            leading: const Icon(Icons.close),
            title: const Text('Close'),
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

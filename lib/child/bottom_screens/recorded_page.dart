import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

class RecordedFilesPage extends StatefulWidget {
  const RecordedFilesPage({super.key});

  @override
  State<RecordedFilesPage> createState() => _RecordedFilesPageState();
}

class _RecordedFilesPageState extends State<RecordedFilesPage> {
  List<FileSystemEntity>? recordedFiles = [];
  late AudioPlayer _audioPlayer;
  int fileCount = 0;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRecordedFiles();
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // Load recorded files from the app's directory
  Future<void> _loadRecordedFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory.listSync().where((file) => file.path.endsWith('.m4a')).toList();
    setState(() {
      recordedFiles = files;
      fileCount = files.length;
    });
    print("Loaded ${files.length} recorded files");
  }

  // Play the selected recording
  Future<void> _playRecording(String path) async {
    await _audioPlayer.stop();
    await _audioPlayer.play(DeviceFileSource(path));
  }

  // Delete a recording
  Future<void> _deleteRecording(FileSystemEntity file) async {
    try {
      await file.delete();
      Fluttertoast.showToast(msg: "Recording deleted successfully");
      _loadRecordedFiles();
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to delete recording");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recorded Files'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(12),
          child: recordedFiles!.isEmpty
              ? Center(child: Text("No recordings found"))
              : ListView.builder(
                  itemCount: fileCount,
                  itemBuilder: (BuildContext context, int index) {
                    final file = recordedFiles![index];
                    final fileName = file.path.split('/').last;

                    return Card(
                      child: ListTile(
                        title: Text(fileName),
                        trailing: Container(
                          width: 100,
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () => _playRecording(file.path),
                                icon: Icon(Icons.play_arrow),
                                color: Colors.blue,
                              ),
                              IconButton(
                                onPressed: () => _deleteRecording(file),
                                icon: Icon(Icons.delete),
                                color: Colors.red,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

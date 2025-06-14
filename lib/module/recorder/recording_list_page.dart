import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:codelens_v2/module/transcription_process.dart';

class DeterminateLinearIndicator extends StatelessWidget {
  final String label;
  final double progress;

  const DeterminateLinearIndicator({
    super.key,
    required this.label,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: progress),
          duration: const Duration(milliseconds: 500),
          builder: (context, value, _) {
            return LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.grey[300],
              color: Colors.red[700],
              minHeight: 8,
            );
          },
        ),
      ],
    );
  }
}

class RecordingsListPage extends StatefulWidget {
  @override
  State<RecordingsListPage> createState() => _RecordingsListPageState();
}

class _RecordingsListPageState extends State<RecordingsListPage> {
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isPlaying = false;
  int? _playingIndex;
  List<FileSystemEntity> _recordings = [];

  bool _isLoading = true;
  bool _isTranscribing = false;
  double _progress = 0.0;
  String _progressLabel = "Loading...";

  @override
  void initState() {
    super.initState();
    _initPlayer();
    _loadFiles();
  }

  Future<void> _initPlayer() async {
    try {
      await _player.openPlayer();
    } catch (e) {
      print("Error initializing player: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to initialize audio player")),
      );
    }
  }

  Future<void> _loadFiles() async {
    setState(() {
      _isLoading = true;
      _progress = 0.2;
      _progressLabel = "Loading files...";
    });

    await Future.delayed(Duration(milliseconds: 400));
    setState(() {
      _progress = 0.5;
      _progressLabel = "Filtering files...";
    });

    final dir = await getApplicationDocumentsDirectory();
    final files = dir
        .listSync()
        .where((f) => f.path.toLowerCase().endsWith('.m4a'))
        .toList();

    await Future.delayed(Duration(milliseconds: 300));
    setState(() {
      _recordings = files.reversed.toList();
      _progress = 1.0;
      _progressLabel = "Done!";
    });

    await Future.delayed(Duration(milliseconds: 300));
    setState(() {
      _isLoading = false;
      _progress = 0.0;
      _progressLabel = "";
    });
  }

  Future<void> _play(String path, int index) async {
    final file = File(path);
    if (!await file.exists()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("File not found")),
      );
      return;
    }

    if (_isPlaying && _playingIndex == index) {
      await _player.stopPlayer();
      setState(() {
        _isPlaying = false;
        _playingIndex = null;
      });
      return;
    }

    try {
      await _player.startPlayer(
        fromURI: path,
        codec: Codec.aacMP4,
        whenFinished: () {
          if (mounted) {
            setState(() {
              _isPlaying = false;
              _playingIndex = null;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _isPlaying = true;
          _playingIndex = index;
        });
      }
    } catch (e) {
      print("❌ Error playing audio: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to play recording: ${e.toString()}")),
        );
      }
    }
  }

  Future<void> _delete(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
    await _loadFiles();
  }

  Future<void> _transcribe(String filePath, String filename) async {
    setState(() {
      _isTranscribing = true;
      _progress = 0.1;
      _progressLabel = "Preparing transcription...";
    });

    await processAndSaveTranscription(
      context: context,
      filePath: filePath,
      onProgress: (msg) {
        setState(() {
          _progressLabel = msg;
        });
      },
      onComplete: (result) async {
        setState(() {
          _progress = 1.0;
          _progressLabel = "Done!";
        });
        await Future.delayed(const Duration(milliseconds: 500));
        setState(() {
          _isTranscribing = false;
          _progress = 0.0;
          _progressLabel = "";
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Yeay!'),
            content: const Text('Transcription complete!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
      onError: (error) {
        setState(() {
          _isTranscribing = false;
          _progress = 0.0;
          _progressLabel = "Error occurred";
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error)));
      },
      onProgressUpdate: (double progressValue) {
        setState(() {
          _progress = progressValue.clamp(0.0, 1.0);
        });
      },
    );
  }

  String _formatTimestamp(DateTime dt) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dt);
  }

  @override
  void dispose() {
    _player.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = _isLoading || _isTranscribing;

    return Scaffold(
      body: isBusy
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/animations/Pen.gif',
                      width: 100,
                      height: 100,
                    ),
                    const SizedBox(height: 16),
                    DeterminateLinearIndicator(
                      label: _progressLabel,
                      progress: _progress,
                    ),
                  ],
                ),
              ),
            )
          : _recordings.isEmpty
              ? const Center(child: Text("No recordings found"))
              : ListView.builder(
                  itemCount: _recordings.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        color: Colors.yellow[100],
                        child: const Text(
                          "\ud83d\udca1 Swipe left/right to delete. Long press to transcribe.",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      );
                    }

                    final file = _recordings[index - 1];
                    final filename = file.path.split('/').last;
                    final nameOnly = filename.replaceAll('.m4a', '');

                    DateTime modified = DateTime.now();
                    try {
                      modified = File(file.path).lastModifiedSync();
                    } catch (_) {}

                    final formattedTimestamp = _formatTimestamp(modified);

                    return Dismissible(
                      key: Key(file.path),
                      direction: DismissDirection.horizontal,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Confirm Deletion"),
                            content: const Text(
                                "Are you sure you want to delete this recording?"),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text("Delete",
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (_) async {
                        final filePath = file.path;
                        setState(() {
                          _recordings.removeAt(index - 1);
                        });
                        await _delete(filePath);
                      },
                      child: GestureDetector(
                        onLongPress: () => _transcribe(file.path, filename),
                        child: Card(
                          color: Colors.red[100],
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: ListTile(
                            title: Text(nameOnly,
                                style: const TextStyle(color: Colors.black)),
                            subtitle: Text(formattedTimestamp,
                                style: const TextStyle(color: Colors.black54)),
                            trailing: IconButton(
                              icon: Container(
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.red, width: 2.0),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _isPlaying && _playingIndex == index - 1
                                      ? Icons.stop
                                      : Icons.play_arrow,
                                  color: Colors.red,
                                ),
                              ),
                              onPressed: () => _play(file.path, index - 1),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

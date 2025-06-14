import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'recorder/recorder_page.dart';
import 'recorder/recording_list_page.dart';

class VoiceModule extends StatefulWidget {
  const VoiceModule({super.key});

  @override
  State<VoiceModule> createState() => _VoiceModuleState();
}

class _VoiceModuleState extends State<VoiceModule> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    RecorderPage(),
    RecordingsListPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: const Text('Live Transcription'),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF0000), Color(0xFFB22222)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      selectedItemColor: Colors.red,             // Active icon/text color
      unselectedItemColor: Colors.grey.shade600, // Inactive icon/text color
      backgroundColor: Colors.white,             // Optional: bar background
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.mic),
          label: 'Record',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.library_music),
          label: 'Recordings',
        ),
      ],
    ),

    );
  }
}

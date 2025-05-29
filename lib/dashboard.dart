import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(      
      appBar: AppBar(
        title: const Text('Dashboard'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF0000), Color(0xFFB22222)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white, // Set background color to white
        padding: const EdgeInsets.all(16.0),
        width: double.infinity,
        height: double.infinity,
        child: GridView.count(
          crossAxisCount: 2, // Creates 2 columns
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            _buildModuleCard(
              context,
              title: 'Live Transcription',
              icon: Icons.graphic_eq,
              color: Colors.blue,
              onTap: () => Navigator.pushNamed(context, '/livestream'),
            ),
            _buildModuleCard(
              context,
              title: 'Audio Transcription',
              icon: Icons.audio_file,
              color: Colors.green,
              onTap: () => Navigator.pushNamed(context, '/module2'),
            ),
            _buildModuleCard(
              context,
              title: 'View Transcription',
              icon: Icons.history,
              color: Colors.orange,
              onTap: () => Navigator.pushNamed(context, '/module3'),
            ),
            _buildModuleCard(
              context,
              title: 'Manage Profile',
              icon: Icons.settings,
              color: Colors.purple,
              onTap: () => Navigator.pushNamed(context, '/manage_profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40.0, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

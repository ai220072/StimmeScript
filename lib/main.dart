import 'package:codelens_v2/module/audio_transcription.dart';
import 'package:codelens_v2/module/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dashboard.dart';
import 'login_screen.dart';
/*import 'module/live_transcription.dart';*/
import 'module/view_transcription.dart';
import 'register_screen.dart';
import 'module/manage_profile.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase here
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light, //LIGHT THEME
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white, fontSize: 18),
          bodyMedium: TextStyle(color: Colors.white, fontSize: 16),
          bodySmall: TextStyle(color: Colors.white, fontSize: 14),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.black),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
        ),
      ),
      home: LoginPage(),
      routes: {
        '/register': (context) => RegisterPage(),
        '/login': (context) => LoginPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/manage_profile': (context) => const ManageProfile(),
        /*'/livestream': (context) => const LiveTranscriptionPage(
            ),*/
        '/module2': (context) => SpeechToTextPage(
              title: 'Audio Transcription',
            ),
        '/module3': (context) => const ViewScreen(),
        '/editprofile': (context) => const EditProfilePage(),
      },
    );
  }
}

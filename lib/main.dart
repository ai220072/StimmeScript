import 'package:codelens_v2/module/audio_transcription.dart';
import 'package:codelens_v2/module/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dashboard.dart';
import 'login_screen.dart';
import 'module/live_transcription.dart';
import 'module/view_transcription.dart';
import 'register_screen.dart';
import 'module/manage_profile.dart';
import 'package:animations/animations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StimmeScript',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.red,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: Colors.white),
          actionsIconTheme: IconThemeData(color: Colors.white),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black, fontSize: 18),
          bodyMedium: TextStyle(color: Colors.black87, fontSize: 16),
          bodySmall: TextStyle(color: Colors.black54, fontSize: 14),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.black87),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black54),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeThroughPageTransitionsBuilder(),
            TargetPlatform.iOS: FadeThroughPageTransitionsBuilder(),
          },
        ),
      ),
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        Widget page;

        switch (settings.name) {
          case '/login':
            page = LoginPage();

          case '/register':
            page = RegisterPage();

          case '/dashboard':
            page = const DashboardPage();

          case '/manage_profile':
            page = const ManageProfile();

          case '/livestream':
            page = const VoiceModule();

          case '/module2':
            page = const AudioTranscriptionPage(title: 'Audio Transcription');

          case '/module3':
            page = const ViewScreen();

          case '/editprofile':
            page = const EditProfilePage();

          default:
            page = LoginPage();
        }

        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeThroughTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              fillColor: Colors.white,
              child: child,
            );
          },
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'auth.dart';
import 'home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// import 'package:mapbox_gl/mapbox_gl.dart'; // Tambahkan impor paket mapbox_gl
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.location.request();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Konfigurasi Mapbox API key

  // MapboxGL.setAccessToken(
  //     'pk.eyJ1IjoiZ3JpeWEiLCJhIjoiY2x6ajBveWhhMG1qbDJqcjEweWc1NzU3YSJ9.74E0NT1xFxGeMImcixubHQ');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login & Registration App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        inputDecorationTheme: InputDecorationTheme(
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[200],
        ),
      ),
      initialRoute: '/auth',
      routes: {
        '/auth': (context) => const AuthPage(),
        '/home': (context) => const AppBarExample(),
      },
    );
  }
}

import 'package:chat_app/screens/auth.dart';
import 'package:chat_app/screens/friends_list.dart';
import 'package:chat_app/screens/splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeController {
  static TextTheme get defaultTextTheme =>
      GoogleFonts.exo2TextTheme(const TextTheme(
        headlineLarge: TextStyle(fontSize: 40, height: 1.3),
        headlineMedium: TextStyle(fontSize: 34, height: 1.4),
        headlineSmall: TextStyle(fontSize: 24, height: 1.23),
      ));

  static ThemeData darkTheme = ThemeData(
    textTheme: defaultTextTheme,
    colorScheme: const ColorScheme.dark(
      background: Colors.black87,
      primary: Colors.blue,
      secondary: Colors.lightGreen,
    ),
  );

  static ThemeData lightTheme = ThemeData(
    textTheme: defaultTextTheme,
    colorScheme: const ColorScheme.dark(
      background: Color.fromARGB(179, 30, 157, 241),
      primary: Color.fromARGB(255, 221, 242, 250),
      secondary: Colors.yellow,
    ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterChat',
      theme: ThemeController.lightTheme,
      darkTheme: ThemeController.darkTheme,
      themeMode: ThemeMode.system,
      home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }

            if (snapshot.hasData) {
              return const FriendsListScreen();
            }
            return const AuthScreen();
          }),
    );
  }
}

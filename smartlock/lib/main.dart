import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smartlock/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyDbx5A3_u6C-9fdDpGnxaf1YqX6Ix0hDEg",
            appId: "1:917821097423:web:0de21ffca56ba58b217eba",
            databaseURL: "https://smartlock-71146-default-rtdb.firebaseio.com",
            messagingSenderId: "917821097423",
            projectId: "smartlock-71146"));
  } catch (e) {
    print(e);
  }
  runApp(const Home());
}

class Home extends StatelessWidget {
  const Home({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Splash(),
    );
  }
}

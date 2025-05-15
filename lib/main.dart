import 'package:flutter/material.dart';
import 'package:iscae_app/auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const ISCAEApp());
}

class ISCAEApp extends StatelessWidget {
  const ISCAEApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ISCAE App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Arial',
        primarySwatch: Colors.teal,
      ),
      home: const Auth(),
    );
  }
}

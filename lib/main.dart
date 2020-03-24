import 'package:flutter/material.dart';
import 'package:safeout/screens/homePage.dart';
import 'package:flutter_config/flutter_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  
  await FlutterConfig.loadEnvVariables();

  runApp(SafeOutApp());
}

class SafeOutApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: FlutterConfig.get("APP_NAME"),
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: HomePage(title: FlutterConfig.get("APP_NAME")),
    );
  }
}

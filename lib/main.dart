import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lystra/app.dart';
import 'package:lystra/core/di/service_locator.dart';
import 'package:lystra/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  setupServiceLocator();
  runApp(const LystraApp());
}

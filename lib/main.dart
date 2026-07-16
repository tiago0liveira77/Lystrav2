import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lystra/app.dart';
import 'package:lystra/core/di/service_locator.dart';
import 'package:lystra/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Catch Flutter framework errors (widget build, rendering, etc.)
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  // Catch async errors that escape the Flutter zone (Future, Stream, isolates)
  PlatformDispatcher.instance.onError = (error, stack) {
    FlutterError.reportError(FlutterErrorDetails(exception: error, stack: stack));
    return true;
  };

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  setupServiceLocator();
  runApp(const LystraApp());
}

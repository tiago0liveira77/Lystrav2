import 'package:flutter/material.dart';
import 'package:lystra/core/router/app_router.dart';
import 'package:lystra/core/theme/app_theme.dart';

class LystraApp extends StatelessWidget {
  const LystraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Lystra',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}

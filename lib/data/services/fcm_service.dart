import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:lystra/data/repositories/user_repository.dart';

class FcmService {
  FcmService({required UserRepository userRepository})
      : _userRepo = userRepository;

  final UserRepository _userRepo;
  final _messaging = FirebaseMessaging.instance;

  // Call once after successful login
  Future<void> initialize(String uid, BuildContext context) async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      final token = await _messaging.getToken();
      if (token != null) {
        await _userRepo.saveFcmToken(uid, token);
      }
      _messaging.onTokenRefresh.listen((newToken) {
        _userRepo.saveFcmToken(uid, newToken);
      });
    }

    // Foreground message handler — shows a SnackBar
    FirebaseMessaging.onMessage.listen((message) {
      if (!context.mounted) return;
      final notification = message.notification;
      if (notification == null) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${notification.title ?? ''}: ${notification.body ?? ''}',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'firestore_service.dart';

/// Registers notification permission (where supported), stores FCM token on the user doc.
/// Server-side scheduling (Cloud Functions + FCM) is still required to send at chosen times.
class FcmService {
  FcmService._();

  static Future<void> registerIfSignedIn() async {
    if (kIsWeb) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        return;
      }

      final token = await messaging.getToken();
      if (token == null || token.isEmpty) return;

      final firestore = FirestoreService();
      await firestore.saveFcmToken(token);

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        if (FirebaseAuth.instance.currentUser == null) return;
        try {
          await FirestoreService().saveFcmToken(newToken);
        } catch (_) {}
      });
    } catch (_) {
      // FCM may be unavailable on some simulators or misconfigured platforms.
    }
  }
}

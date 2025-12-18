import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OneSignalService {
  static Future<void> init() async {
    OneSignal.initialize("ONESIGNAL_APP_ID");
    OneSignal.Notifications.requestPermission(true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final playerId = OneSignal.User.pushSubscription.id;
    if (playerId == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({
      'playerId': playerId,
    });
  }
}

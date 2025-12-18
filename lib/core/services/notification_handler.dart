import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class NotificationHandler {
  static void setup(BuildContext context) {
    OneSignal.Notifications.addClickListener((event) {
      final data = event.notification.additionalData;
      if (data == null) return;

      // 👉 khusus notif pengajuan warga
      if (data['type'] == 'request_detail') {
        final requestId = data['requestId'];

        context.go(
          '/wg/pengajuan/detail',
          extra: {'id': requestId},
        );
      }
    });
  }
}

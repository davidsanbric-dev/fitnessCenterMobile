import 'package:fitnesscenter_mobile/app/core/services/local_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class NotificationTestCard extends StatelessWidget {
  const NotificationTestCard({super.key});

  LocalNotificationService get _localNotifications =>
      Get.find<LocalNotificationService>();

  Future<void> _handleShowTest() async {
    await _localNotifications.showLocalNotification(
      title: 'Test notification',
      body: 'If you can see this, local notifications are working.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 16),
      color: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(LucideIcons.bellRing, size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Test notification',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Send a local notification to validate setup on this device.',
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _handleShowTest,
              child: const Text('Test'),
            ),
          ],
        ),
      ),
    );
  }
}

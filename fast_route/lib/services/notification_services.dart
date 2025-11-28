import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    tz.initializeTimeZones();

    try {
      tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));
    } catch (e) {
      print(e);
    }

    const AndroidInitializationSettings initializationSettingsAndroid = 
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await notificationsPlugin.initialize(initializationSettings);

    final platform = notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await platform?.requestNotificationsPermission();
  }

    Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
    }) async {
      const androidDetails = AndroidNotificationDetails(
        'canal_status_imediato',
        'Status do Compromisso',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      );

      const notificationDetails = NotificationDetails(android: androidDetails);

      await notificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
    );
  }
}
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotifications {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  getNotificationPlugin() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    var initializationSettingsIOS = IOSInitializationSettings(
      onDidReceiveLocalNotification: (
        int id,
        String title,
        String body,
        String payload,
      ) async {
        print(payload.toString());
        onSelectNotification(payload);
      },
    );

    flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(
        initializationSettingsAndroid,
        initializationSettingsIOS,
      ),
      onSelectNotification: onSelectNotification,
    );

    return flutterLocalNotificationsPlugin;
  }

  Future onSelectNotification(payload) async {}
}

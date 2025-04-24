import 'dart:io';
import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../utils/logger.dart';
import '../../presentation/utils/riverpod_framework.dart';

part 'local_notifications_service.g.dart';

/// Provides local notifications functionality throughout the app.
///
/// This Riverpod provider creates and maintains a singleton instance of [LocalNotificationsService].
/// Access this service via `ref.read(localNotificationsServiceProvider)`.
@Riverpod(keepAlive: true)
LocalNotificationsService localNotificationsService(Ref ref) {
  return LocalNotificationsService(ref: ref);
}

/// Service that handles local notification functionality.
///
/// This service manages the initialization of the Flutter Local Notifications Plugin,
/// requests necessary permissions, and provides methods to display notifications.
/// Must call [initialization] before using the service.
class LocalNotificationsService {
  /// Creates a new [LocalNotificationsService] instance with the provided [ref].
  LocalNotificationsService({required this.ref});

  /// Default Android notification details with high priority.
  late final AndroidNotificationDetails androidNotificationDetails =
      const AndroidNotificationDetails(
    'local/notification',
    'Trip Status',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );

  /// Default notification details for all platforms.
  late final NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);

  /// Riverpod reference for potential dependency injection.
  final Ref ref;

  /// The Flutter Local Notifications Plugin instance.
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  /// Initialization settings for the notifications plugin.
  late InitializationSettings initializationSettings;

  /// Initializes the local notifications service.
  ///
  /// This method must be called before using any other method of this service.
  /// It sets up the Flutter Local Notifications Plugin and requests necessary permissions.
  ///
  /// [checkPermission] - Whether to check for notification permissions on Android.
  /// Set to false if you want to handle permissions separately.
  ///
  /// Returns a [Future] that completes when initialization is done.
  Future<void> initialization([bool checkPermission = true]) async {
    // init plugin
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    if (Platform.isAndroid && checkPermission) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher_foreground');
    const initializationSettingsDarwin = DarwinInitializationSettings();

    initializationSettings = const InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {},
      // onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  /// Shows a notification with the given content.
  ///
  /// Displays a local notification with the app name as the title
  /// and the provided [content] as the notification body.
  /// Uses a random ID for each notification to ensure uniqueness.
  ///
  /// [content] - The message text to display in the notification.
  ///
  /// Returns a [Future] that completes when the notification is shown.
  Future<void> showNotification(String content) async {
    logger.log('Showing notification: $content');
    await flutterLocalNotificationsPlugin.show(
      Random(1000).nextInt(1100000),
      'ShineDump App',
      content,
      notificationDetails,
    );
  }
}

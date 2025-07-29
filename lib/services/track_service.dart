import 'dart:developer';

import 'package:background_location_tracker/background_location_tracker.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

const knotificationClockOutKey = 'clock_out';

class TrackingService {
  // Private constructor
  TrackingService._privateConstructor();

  // The single instance of this service
  static final TrackingService _instance =
      TrackingService._privateConstructor();

  // Factory to return the same instance every time
  factory TrackingService() {
    return _instance;
  }

  Future<void> startTracking() async {
    await BackgroundLocationTrackerManager.stopTracking();
    await BackgroundLocationTrackerManager.startTracking();
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'attandance_track',
        title: 'Clocked In – Tracking Started 🟢',
        body: 'Tracking of your shift has started.',
        locked: true,
        autoDismissible: false,
        displayOnForeground: true,
        displayOnBackground: true,
        category: NotificationCategory.Service,
      ),
      actionButtons: [
        NotificationActionButton(
          key: knotificationClockOutKey,
          label: "Clock Out",
          actionType: ActionType.Default,
          autoDismissible: false,
        ),
      ],
    );
  }

  Future<void> stopTracking() async {
    bool currentlyTracking =
        await BackgroundLocationTrackerManager.isTracking();

    if (currentlyTracking) {
      await BackgroundLocationTrackerManager.stopTracking();
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 1,
          channelKey: 'attandance_track',
          title: 'Clocked Out – Tracking Stopped 🔴',
          body: 'Background location tracking has stopped.',
          autoDismissible: true,
          locked: false,
          category: NotificationCategory.Service,
        ),
      );
      await AwesomeNotifications().cancel(1);
    }
  }

  Future<bool> isTracking() async {
    return await BackgroundLocationTrackerManager.isTracking();
  }
}

class NotificationController {
  /// Use this method to detect when a new notification or a schedule is created
  // @pragma("vm:entry-point")
  // static Future<void> onNotificationCreatedMethod(
  //     ReceivedNotification receivedNotification) async {
  //   // Your code goes here
  // }

  /// /// Use this method to detect every time that a new notification is displayed
  /// @pragma("vm:entry-point")
  /// static Future<void> onNotificationDisplayedMethod(
  ///     ReceivedNotification receivedNotification) async {
  ///   // Your code goes here
  /// }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // Your code goes here
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {}
}

// Background callback must be a top-level or static function
@pragma('vm:entry-point')
void backgroundCallback() {
  BackgroundLocationTrackerManager.handleBackgroundUpdated(
      (data) async => Repo().update(data));
}

class Repo {
  static Repo? _instance;

  Repo._();

  factory Repo() => _instance ??= Repo._();

  Future<void> update(BackgroundLocationUpdateData data) async {
    final text =
        'Location Update: Lat: ${data.lat} Lon: ${data.lon} Course: ${data.course} Speed: ${data.speed}';
    log(text); // ignore: avoid_print
  }
}

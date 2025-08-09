// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:background_location_tracker/background_location_tracker.dart';
// import 'package:shared_preferences/shared_preferences.dart';

import 'package:vcare_attendance/api/api.dart';
import 'package:vcare_attendance/api/location_api.dart';

const knotificationClockOutKey = 'clock_out';

const kattendanceTypeKey = "attendance-type-key";
const kattendanceidKey = "attendance-id-key";
const knotificationId = 1;

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

  // Future<void> startTracking(AttendanceType at, int attId) async {
  //   await BackgroundLocationTrackerManager.stopTracking();
  //   await AwesomeNotifications().cancel(knotificationId);
  //   final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
  //   await asyncPrefs.setString(kattendanceTypeKey, at.name);
  //   await asyncPrefs.setInt(kattendanceidKey, attId);
  //   await BackgroundLocationTrackerManager.startTracking();
  //   await AwesomeNotifications().createNotification(
  //     content: NotificationContent(
  //       id: knotificationId,
  //       channelKey: 'attandance_track',
  //       title: 'Clocked In – Tracking Started 🟢',
  //       body: 'Tracking of your shift has started.',
  //       locked: true,
  //       autoDismissible: false,
  //       displayOnForeground: true,
  //       displayOnBackground: true,
  //       category: NotificationCategory.Service,
  //     ),
  //     actionButtons: [
  //       NotificationActionButton(
  //         key: knotificationClockOutKey,
  //         label: "Clock Out",
  //         actionType: ActionType.Default,
  //         autoDismissible: false,
  //       ),
  //     ],
  //   );
  // }

  // Future<void> stopTracking() async {
  //   bool currentlyTracking =
  //       await BackgroundLocationTrackerManager.isTracking();
  //
  //   if (currentlyTracking) {
  //     await BackgroundLocationTrackerManager.stopTracking();
  //     await AwesomeNotifications().createNotification(
  //       content: NotificationContent(
  //         id: knotificationId,
  //         channelKey: 'attandance_track',
  //         title: 'Clocked Out – Tracking Stopped 🔴',
  //         body: 'Background location tracking has stopped.',
  //         autoDismissible: true,
  //         locked: false,
  //         category: NotificationCategory.Service,
  //       ),
  //     );
  //     await AwesomeNotifications().cancel(knotificationId);
  //   }
  // }
  //
  // Future<bool> isTracking() async {
  //   return await BackgroundLocationTrackerManager.isTracking();
  // }
}

// Background callback must be a top-level or static function
// @pragma('vm:entry-point')
// void backgroundCallback() {
//   BackgroundLocationTrackerManager.handleBackgroundUpdated(
//       (data) async => Repo().update(data));
// }
//
// class Repo {
//   static Repo? _instance;
//   Repo._();
//
//   factory Repo() => _instance ??= Repo._();
//
//   Future<void> update(BackgroundLocationUpdateData data) async {
//     // final text =
//     //     'Location Update: Lat: ${data.lat} Lon: ${data.lon} Course: ${data.course} Speed: ${data.speed}';
//     // print(text);
//     final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
//     final attTypeStr = await asyncPrefs.getString(kattendanceTypeKey);
//     final anyAttId = await asyncPrefs.getInt(kattendanceidKey);
//     if (attTypeStr == null && anyAttId == null) return;
//     final attType = AttendanceType.values.byName(attTypeStr!);
//     final attId = attType == AttendanceType.attendance ? anyAttId : null;
//     final otAttId = attType == AttendanceType.otAttendance ? anyAttId : null;
//     final locApi = Api.location;
//     await locApi.postLocation(data.lat, data.lon, attId, otAttId, false);
//   }
// }
//
// Future<void> reShowNotification() async {
//   final isShowing =
//       await AwesomeNotifications().isNotificationActiveOnStatusBar(id: 1);
//   if (!isShowing) return;
//
//   await AwesomeNotifications().createNotification(
//     content: NotificationContent(
//       id: knotificationId,
//       channelKey: 'attandance_track',
//       title: 'Clocked In – Tracking Started 🟢',
//       body: 'Tracking of your shift has started.',
//       locked: true,
//       autoDismissible: false,
//       displayOnForeground: true,
//       displayOnBackground: true,
//       category: NotificationCategory.Service,
//     ),
//   );
// }

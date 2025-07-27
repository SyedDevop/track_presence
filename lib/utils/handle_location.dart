import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestLocationPermission(BuildContext context) async {
  // Request the permission
  PermissionStatus status = await Permission.locationAlways.request();

  // Handle the different permission states
  switch (status) {
    case PermissionStatus.granted:
      debugPrint('Location permission granted');
      return true;

    case PermissionStatus.denied:
      debugPrint('Location permission denied');
      return false;

    case PermissionStatus.permanentlyDenied:
      debugPrint('Location permission permanently denied');
      // Show dialog to open app settings
      showPermissionDialog(context);
      return false;

    case PermissionStatus.restricted:
      debugPrint('Location permission restricted');
      return false;

    default:
      return false;
  }
}

void showPermissionDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Location Permission Required'),
      content: const SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This app needs location permission to function properly. Follow these steps:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('Steps to enable:'),
            SizedBox(height: 8),
            Text('1. Tap "Settings" below'),
            Text('2. Find this app in the list'),
            Text('3. Tap on "Permissions" or "App Permissions"'),
            Text('4. Select "Location"'),
            Text('5. Choose "Allow all the time"'),
            Text('6. Return to the app'),
            SizedBox(height: 12),
            Text(
              '💡 Note: You may need to restart the app after changing permissions.',
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            openAppSettings(); // Opens device settings
          },
          child: const Text('Settings'),
        ),
      ],
    ),
  );
}

Future<void> handleLocationPermission(BuildContext context) async {
  // Check current permission status first
  PermissionStatus status = await Permission.locationAlways.status;
  if (status.isGranted) {
    debugPrint('Permission already granted');
    return;
  }
  // Request permission if not granted
  await requestLocationPermission(context);
}

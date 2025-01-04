import 'package:flutter/material.dart';

void snackbarError(BuildContext context, {required String message}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14.0,
          ),
        ),
        duration: const Duration(seconds: 4),
        backgroundColor: const Color.fromRGBO(255, 51, 51, 1),
        showCloseIcon: true,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
}

void snackbarSuccess(BuildContext context, {required String message}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          fontSize: 14.0,
        ),
      ),
      duration: const Duration(seconds: 5),
      backgroundColor: Colors.tealAccent,
      showCloseIcon: true,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    ));
}

void snackbarNotefy(
  BuildContext context, {
  required String message,

  /// [duration] in seconds of the snackBar default is 2 seconds
  int duration = 2,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14.0,
        ),
      ),
      duration: const Duration(seconds: 2),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      showCloseIcon: true,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    ));
}

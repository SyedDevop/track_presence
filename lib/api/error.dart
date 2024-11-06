class ApiError {
  final int status;
  final String error;
  final String message;
  ApiError({required this.status, required this.error, required this.message});

  factory ApiError.fromJson(Map<String, dynamic> data) => ApiError(
        status: data['status'],
        error: data['error'],
        message: data['message'],
      );
}

const kAlreadyClocked = "already-clocked ";
const kReasonRequired = "reason-required";
const kAttendanceNotFound = "attendance-not-found";
const kReacchedOvertimeLimit = "reached-overtime-limit";

class ApiException implements Exception {
  final int status;
  final String error;
  final String message;
  ApiException(ApiError err)
      : message = err.message,
        status = err.status,
        error = err.error;
  @override
  String toString() => message;
}

// Exception? getApiException(ApiError err) {
//   switch (err.error) {
//     case kAlreadyClocked:
//       return AlreadyClockedException(err);
//     case kReasonRequired:
//       return ReasonRequirdException(err);
//     case kAttendanceNotFound:
//       return AttenNotFoundException(err);
//     default:
//       return null;
//   }
// }
//
// class ReasonRequirdException implements Exception {
//   final String message;
//   final String error;
//   ReasonRequirdException(ApiError err)
//       : message = err.message,
//         error = err.error;
//
//   @override
//   String toString() => message;
// }
//
// class AlreadyClockedException implements Exception {
//   final String message;
//   final String error;
//   AlreadyClockedException(ApiError err)
//       : message = err.message,
//         error = err.error;
//   @override
//   String toString() => message;
// }
//
// class AttenNotFoundException implements Exception {
//   final String message;
//   final String error;
//   AttenNotFoundException(ApiError err)
//       : message = err.message,
//         error = err.error;
//   @override
//   String toString() => message;
// }

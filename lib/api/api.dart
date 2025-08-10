import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:vcare_attendance/api/account_api.dart';
import 'package:vcare_attendance/api/attendance_api.dart';
import 'package:vcare_attendance/api/leave_api.dart';
import 'package:vcare_attendance/api/loan_api.dart';
import 'package:vcare_attendance/api/location_api.dart';
import 'package:vcare_attendance/api/payslip_api.dart';
import 'package:vcare_attendance/api/shift.dart';
import 'package:vcare_attendance/api/user_api.dart';
import 'package:vcare_attendance/interceptor/auth.dart';
import 'package:vcare_attendance/interceptor/error.dart';
import 'package:vcare_attendance/interceptor/logger.dart';
import 'package:vcare_attendance/utils/token_storage.dart';

//const kBaseApi = "http://192.168.1.120:6969/api/";
//const kBaseApi = "http://192.168.1.2:6969/api/";
const kBaseApi = "https://vcarehospital.in/hmsversion8.2/payroll/api/";

final tokenStorage = TokenStorage();

Dio dioConfig() {
  final Dio dioConf = Dio(
    BaseOptions(
      baseUrl: kBaseApi,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ),
  );
  dioConf.interceptors.add(customErrorInterceptor);
  dioConf.interceptors.add(AuthInterceptor(dioConf, tokenStorage));
  if (kDebugMode) dioConf.interceptors.add(dioLoggerInterceptor);
  return dioConf;
}

final Dio rootDio = dioConfig();

// TODO: Remove the employee_id||id any type of id for the current logged in
// because the jwt will have it.
class Api {
  static LeaveApi leave = LeaveApi(dio: rootDio);
  static AccountApi account = AccountApi(dio: rootDio);
  static ShiftApi shift = ShiftApi(dio: rootDio);
  static AttendanceApi attendance = AttendanceApi(dio: rootDio);
  static UserApi user = UserApi(dio: rootDio);
  static LoanApi loan = LoanApi(dio: rootDio);
  static PayslipApi payslip = PayslipApi(dio: rootDio);
  static LocationApi location = LocationApi(dio: rootDio);
}

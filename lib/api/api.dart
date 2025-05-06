import 'package:vcare_attendance/api/account_api.dart';
import 'package:vcare_attendance/api/attendance_api.dart';
import 'package:vcare_attendance/api/leave_api.dart';
import 'package:vcare_attendance/api/loan_api.dart';
import 'package:vcare_attendance/api/payslip_api.dart';
import 'package:vcare_attendance/api/shift.dart';
import 'package:vcare_attendance/api/user_api.dart';

//const kBaseApi = "http://192.168.1.120:6969/api";
//const kBaseApi = "http://192.168.1.2:6969/api";
const kBaseApi = "https://vcarehospital.in/hmsversion8.2/payroll/api";

class Api {
  static LeaveApi leave = LeaveApi(baseUrl: kBaseApi);
  static AccountApi account = AccountApi(baseUrl: kBaseApi);
  static ShiftApi shift = ShiftApi(baseUrl: kBaseApi);
  static AttendanceApi attendance = const AttendanceApi(baseUrl: kBaseApi);
  static UserApi user = const UserApi(baseUrl: kBaseApi);
  static LoanApi loan = LoanApi(baseUrl: kBaseApi);
  static PayslipApi payslip = PayslipApi(baseUrl: kBaseApi);
}

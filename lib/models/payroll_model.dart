import 'dart:convert';

import 'package:flutter/material.dart';

class PayrollRaw {
  Payroll payroll;
  PayrollInfo info;
  PayrollRaw({
    required this.payroll,
    required this.info,
  });
  factory PayrollRaw.fromRawJson(String str) =>
      PayrollRaw.fromJson(json.decode(str));

  factory PayrollRaw.fromJson(Map<String, dynamic> json) => PayrollRaw(
        payroll: Payroll.fromJson(json["data"]),
        info: PayrollInfo.fromJson(json["info"]),
      );
}

List<Payroll> payrollRawList(String str) => List<Payroll>.from(
      jsonDecode(str).map((x) => Payroll.fromJson(x)),
    );

class PayrollInfo {
  double basicSalary;
  double salaryPerDay;
  double salaryPerHour;
  double salaryPerMinute;

  PayrollInfo({
    required this.basicSalary,
    required this.salaryPerDay,
    required this.salaryPerHour,
    required this.salaryPerMinute,
  });
  factory PayrollInfo.fromRawJson(String str) =>
      PayrollInfo.fromJson(json.decode(str));
  factory PayrollInfo.fromJson(Map<String, dynamic> json) => PayrollInfo(
        basicSalary: json["basic_salary"].toDouble(),
        salaryPerDay: json["salary_per_day"],
        salaryPerHour: json["salary_per_hour"],
        salaryPerMinute: json["salary_per_minute"],
      );
}

class Payroll {
  String date;
  AttendanceRawMin attendance;
  int overtimeMin;
  bool isLeave;
  bool isHoliday;
  bool isAbsent;
  bool hasShift;

  Payroll({
    required this.date,
    required this.attendance,
    required this.overtimeMin,
    required this.isLeave,
    required this.isHoliday,
    required this.isAbsent,
    required this.hasShift,
  });
  factory Payroll.fromRawJson(String str) {
    return Payroll.fromJson(jsonDecode(str));
  }
  factory Payroll.fromJson(Map<String, dynamic> json) => Payroll(
        date: json["date"],
        attendance: AttendanceRawMin.fromJson(json["attendance"]),
        overtimeMin: json["overtime_min"],
        isLeave: json["is_leave"],
        isHoliday: json["is_holiday"],
        isAbsent: json["is_absent"],
        hasShift: json["has_shift"],
      );
  Map<String, dynamic> tojson() => {
        "date": date,
        "attendance": attendance.tojson(),
        "overtime_min": overtimeMin,
        "is_leave": isLeave,
        "is_holiday": isHoliday,
        "is_absent": isAbsent,
        "has_shift": hasShift,
      };

  String todayIs() {
    if (attendance.attendanceMin > 0) return "Present";
    if (isLeave) return "Leave";
    if (isHoliday) return "Holiday";
    return "Absent";
  }

  Color payrollRawColor() {
    if (attendance.attendanceMin > 0) return Colors.greenAccent;
    if (isLeave) return Colors.lightBlue;
    if (isHoliday) return Colors.yellowAccent;
    return Colors.redAccent;
  }

  Color payrollRawColor2() {
    if (attendance.attendanceMin > 0) {
      return Colors.green.shade500;
    } // Balanced green for presence
    if (isLeave) return Colors.blue.shade400; // Softer blue for leave
    if (isHoliday) return Colors.amber.shade600; // Warmer gold for holidays
    return Colors.red.shade600; // Deeper red for absence
  }
}

class AttendanceRawMin {
  int shiftMin;
  int attendanceMin;
  int attendanceOTMin;
  int attendanceLOHMin;
  AttendanceRawMin({
    required this.shiftMin,
    required this.attendanceMin,
    required this.attendanceOTMin,
    required this.attendanceLOHMin,
  });

  factory AttendanceRawMin.fromRawJson(String str) {
    return AttendanceRawMin.fromJson(jsonDecode(str));
  }

  factory AttendanceRawMin.fromJson(Map<String, dynamic> json) =>
      AttendanceRawMin(
        shiftMin: json["shift_min"],
        attendanceMin: json["attendance_min"],
        attendanceOTMin: json["attendance_ot_min"],
        attendanceLOHMin: json["attendance_loh_min"],
      );
  Map<String, dynamic> tojson() => {
        "shift_min": shiftMin,
        "attendance_min": attendanceMin,
        "attendance_ot_min": attendanceOTMin,
        "attendance_loh_min": attendanceLOHMin
      };
}

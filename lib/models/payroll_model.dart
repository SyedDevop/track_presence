import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PayrollRaw {
  Payroll? payroll;
  List<Payroll>? payrolls;
  PayrollInfo info;

  PayrollRaw({
    required this.info,
    this.payroll,
    this.payrolls,
  });
  factory PayrollRaw.fromRawJson(String str) =>
      PayrollRaw.fromJson(json.decode(str));

  factory PayrollRaw.fromJson(Map<String, dynamic> json) {
    final data = json["data"];
    Payroll? payroll;
    List<Payroll>? payrolls;
    if (data is List) {
      payrolls = data.map<Payroll>((x) => Payroll.fromJson(x)).toList();
    } else if (data is Map<String, dynamic>) {
      payroll = Payroll.fromJson(json["data"]);
    } else {
      throw Exception("Unexpected 'data' format in PayrollRaw");
    }

    return PayrollRaw(
      payroll: payroll,
      payrolls: payrolls,
      info: PayrollInfo.fromJson(json["info"]),
    );
  }

  /// Returns true if it's a list of payrolls, false if it's a single payroll.
  bool get isPayrollList => payrolls != null && payrolls!.isNotEmpty;
}

List<Payroll> payrollRawList(String str) => List<Payroll>.from(
      jsonDecode(str).map((x) => Payroll.fromJson(x)),
    );

abstract class PayrollInfo {
  double salary;
  double salaryPerDay;
  double salaryPerHour;
  double salaryPerMinute;

  PayrollInfo({
    required this.salary,
    required this.salaryPerDay,
    required this.salaryPerHour,
    required this.salaryPerMinute,
  });
  factory PayrollInfo.fromRawJson(String str) =>
      PayrollInfo.fromJson(json.decode(str));

  factory PayrollInfo.fromJson(Map<String, dynamic> json) {
    if (json.containsKey("present_count")) {
      return MonthlyPayrollInfo.fromJson(json);
    } else {
      return DailyPayrollInfo.fromJson(json);
    }
  }
}

class DailyPayrollInfo extends PayrollInfo {
  DailyPayrollInfo({
    required super.salary,
    required super.salaryPerDay,
    required super.salaryPerHour,
    required super.salaryPerMinute,
  });

  factory DailyPayrollInfo.fromJson(Map<String, dynamic> json) =>
      DailyPayrollInfo(
        salary: json["salary"].toDouble(),
        salaryPerDay: json["salary_per_day"],
        salaryPerHour: json["salary_per_hour"],
        salaryPerMinute: json["salary_per_minute"],
      );
}

class MonthlyPayrollInfo extends PayrollInfo {
  final int appliedLeave;
  final int allowedPaidLeaves;
  final int leavesCount;
  final int presentCount;
  final int absentCount;
  final int holidayCount;

  MonthlyPayrollInfo({
    required super.salary,
    required super.salaryPerDay,
    required super.salaryPerHour,
    required super.salaryPerMinute,
    required this.appliedLeave,
    required this.allowedPaidLeaves,
    required this.leavesCount,
    required this.presentCount,
    required this.absentCount,
    required this.holidayCount,
  });

  factory MonthlyPayrollInfo.fromJson(Map<String, dynamic> json) =>
      MonthlyPayrollInfo(
        salary: json["salary"].toDouble(),
        salaryPerDay: json["salary_per_day"],
        salaryPerHour: json["salary_per_hour"],
        salaryPerMinute: json["salary_per_minute"],
        appliedLeave: json["applied_leave"],
        allowedPaidLeaves: json["allowed_paid_leaves"],
        leavesCount: json["leaves_count"],
        presentCount: json["present_count"],
        absentCount: json["absent_count"],
        holidayCount: json["holiday_count"],
      );
}

class Payroll {
  String date;
  String dateDay;
  AttendanceRawMin attendance;
  OtMetrics otMetrics;
  int extratimeMin;
  bool isLeave;
  bool isHoliday;
  bool isAbsent;
  bool hasShift;

  Payroll({
    required this.date,
    required this.dateDay,
    required this.attendance,
    required this.otMetrics,
    required this.extratimeMin,
    required this.isLeave,
    required this.isHoliday,
    required this.isAbsent,
    required this.hasShift,
  });
  factory Payroll.fromRawJson(String str) {
    return Payroll.fromJson(jsonDecode(str));
  }
  factory Payroll.fromJson(Map<String, dynamic> json) {
    print("Hello from Payroll json: $json");
    return Payroll(
      date: json["date"],
      dateDay: json["date_word"],
      attendance: AttendanceRawMin.fromJson(json["attendance"]),
      otMetrics: OtMetrics.fromJson(json["ot_metrics"]),
      extratimeMin: json["extratime_min"],
      isLeave: json["is_leave"],
      isHoliday: json["is_holiday"],
      isAbsent: json["is_absent"],
      hasShift: json["has_shift"],
    );
  }
  Map<String, dynamic> tojson() => {
        "date": date,
        "date_word": dateDay,
        "attendance": attendance.tojson(),
        "extratime_min": extratimeMin,
        "is_leave": isLeave,
        "is_holiday": isHoliday,
        "is_absent": isAbsent,
        "has_shift": hasShift,
      };

  String day() {
    return DateFormat("EEE dd MMM yyyy").format(DateTime.parse(date));
  }

  String todayIs() {
    if (attendance.workedMin > 0) return "Present";
    if (isLeave) return "Leave";
    if (isHoliday) return "Holiday";
    return "Absent";
  }

  Color payrollRawColor() {
    if (attendance.workedMin > 0) return Colors.greenAccent;
    if (isLeave) return Colors.lightBlue;
    if (isHoliday) return Colors.yellowAccent;
    return Colors.redAccent;
  }

  Color payrollRawColor2() {
    if (attendance.workedMin > 0) {
      return Colors.green.shade500;
    } // Balanced green for presence
    if (isLeave) return Colors.blue.shade400; // Softer blue for leave
    if (isHoliday) return Colors.amber.shade600; // Warmer gold for holidays
    return Colors.red.shade600; // Deeper red for absence
  }
}

class AttendanceRawMin {
  int shiftMin;
  int workedMin;
  int totalOtMin;
  int totalLohMin;
  int lateOutOtMin;
  int lateInLohMin;
  int earlyInOtMin;
  int earlyOutLohMin;

  AttendanceRawMin({
    required this.shiftMin,
    required this.workedMin,
    required this.totalOtMin,
    required this.totalLohMin,
    required this.lateOutOtMin,
    required this.lateInLohMin,
    required this.earlyInOtMin,
    required this.earlyOutLohMin,
  });

  factory AttendanceRawMin.fromRawJson(String str) {
    return AttendanceRawMin.fromJson(jsonDecode(str));
  }

  factory AttendanceRawMin.fromJson(Map<String, dynamic> json) =>
      AttendanceRawMin(
        shiftMin: json["shift_minutes"],
        workedMin: json["worked_minutes"],
        totalOtMin: json["total_overtime_minutes"],
        totalLohMin: json["total_loh_minutes"],
        lateInLohMin: json["late_in_loh_minutes"],
        lateOutOtMin: json["late_out_overtime_minutes"],
        earlyInOtMin: json["early_in_overtime_minutes"],
        earlyOutLohMin: json["early_out_loh_minutes"],
      );
  Map<String, dynamic> tojson() => {
        "shift_min": shiftMin,
        "worked_minutes": workedMin,
        "total_overtime_minutes": totalOtMin,
        "total_loh_minutes": totalLohMin,
        "late_in_loh_minutes": lateInLohMin,
        "late_out_overtime_minutes": lateOutOtMin,
        "early_in_overtime_minutes": earlyInOtMin,
        "early_out_loh_minutes": earlyOutLohMin,
      };
}

class OtMetrics {
  OtMetric? lateOut;
  OtMetric? earlyIn;
  OtMetrics({
    this.earlyIn,
    this.lateOut,
  });
  factory OtMetrics.fromRawJson(String str) =>
      OtMetrics.fromJson(jsonDecode(str));

  factory OtMetrics.fromJson(Map<String, dynamic> json) => OtMetrics(
        lateOut: _tryParseOtMetric(json["late_out"]),
        earlyIn: _tryParseOtMetric(json["early_in"]),
      );

  static OtMetric? _tryParseOtMetric(dynamic data) {
    if (data == null) return null;
    return OtMetric.fromJson(data);
  }

  Map<String, dynamic> tojson() => {
        "late_out": lateOut?.tojson(),
        "early_in": earlyIn?.tojson(),
      };
}

class OtMetric {
  int minutes;
  double pay;
  OtMetric({required this.minutes, required this.pay});

  factory OtMetric.fromRawJson(String str) =>
      OtMetric.fromJson(jsonDecode(str));

  factory OtMetric.fromJson(Map<String, dynamic> json) =>
      OtMetric(minutes: json["minutes"], pay: json["pay"].toDouble());

  Map<String, dynamic> tojson() => {"minutes": minutes, "pay": pay};
}

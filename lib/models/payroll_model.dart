import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vcare_attendance/utils/utils.dart';

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

  /// Returns true if it's a single payroll, false if it's a list of payrolls.
  bool get isSinglePayroll => payroll != null;

  /// Generates a formatted list of payroll entries along with a total summary.
  ///
  /// This function processes each `Payroll` entry in [payrolls], formats them
  /// into either [FormattedPayroll] (for present employees) or [FormattedPayrollSpecial]
  /// (for leave, holiday, or absent days), and calculates the cumulative totals.
  ///
  /// If [payrolls] is `null` or if [info] is not of type [MonthlyPayrollInfo],
  /// it returns an empty list and an empty [PayrollTotal].
  ///
  /// Returns a tuple of:
  /// - A list of formatted payroll records [FormattedPayroll] or [FormattedPayrollSpecial].
  /// - The computed [PayrollTotal].
  ///
  /// The function internally updates leave balances and computes additional payments
  /// such as overtime and extra time.
  (List<dynamic>, PayrollTotal) generateFormatPayrolls() {
    if (payrolls == null) return ([], PayrollTotal.empty());
    if (info is! MonthlyPayrollInfo) return ([], PayrollTotal.empty());

    final monthlyInfo = info as MonthlyPayrollInfo;
    int allowedPaidLeaves = monthlyInfo.allowedPaidLeaves;
    final total = PayrollTotal.empty();
    total.addPaidLeave(allowedPaidLeaves * monthlyInfo.salaryPerDay);

    final payrollList = payrolls!.map((payroll) {
      final fmtExtraTimeMin = minToHrMin(payroll.extratimeMin);
      final extratimePay = payroll.extratimeMin * info.salaryPerMinute;
      final fmtExtraTimePay = fmtInr(extratimePay);
      if (payroll.isPresent) {
        return _formatPresent(payroll, total, monthlyInfo);
      } else if (payroll.isLeave) {
        String type = "Leave";
        String message = "Leave";
        double leavePay = 0;
        if (allowedPaidLeaves > 0) {
          allowedPaidLeaves--;
          message = "Paid Leave";
          type = "Paid";
          leavePay = monthlyInfo.salaryPerDay;
        }
        return FormattedPayrollSpecial(
          monthDay: payroll.dateDay,
          date: payroll.date,
          type: type,
          message: message,
          pay: fmtInr(leavePay),
          extratimeMin: fmtExtraTimeMin,
          extratimePay: fmtExtraTimePay,
          total: leavePay + extratimePay,
        );
      } else if (payroll.isHoliday) {
        String type = "Holiday";
        String message = "Holiday";
        double leavePay = 0;
        if (allowedPaidLeaves > 0) {
          allowedPaidLeaves--;
          message = "Paid Leave";
          type = "Paid";
          leavePay = monthlyInfo.salaryPerDay;
        }
        return FormattedPayrollSpecial(
          monthDay: payroll.dateDay,
          date: payroll.date,
          type: type,
          message: message,
          pay: fmtInr(leavePay),
          extratimeMin: fmtExtraTimeMin,
          extratimePay: fmtExtraTimePay,
          total: leavePay + extratimePay,
        );
      }
      return FormattedPayrollSpecial(
        monthDay: payroll.dateDay,
        date: payroll.date,
        type: "Absent",
        message: "Absent",
        pay: fmtInr(0),
        extratimeMin: fmtExtraTimeMin,
        extratimePay: fmtExtraTimePay,
        total: extratimePay,
      );
    }).toList();
    return (payrollList, total);
  }

  /// Formats a [Payroll] entry where the employee was present,
  /// calculates base salary, overtime, and extra time,
  /// and updates the [PayrollTotal] accordingly.
  ///
  /// - [payroll]: The [Payroll] record to format.
  /// - [total]: The [PayrollTotal] accumulator being updated.
  /// - [info]: The [MonthlyPayrollInfo] containing salary details.
  ///
  /// Returns a [FormattedPayroll] object with detailed breakdowns
  /// of hours and salary components.
  FormattedPayroll _formatPresent(
      Payroll payroll, PayrollTotal total, MonthlyPayrollInfo info) {
    final attendance = payroll.attendance;
    double overtimePay = 0;
    String? approvedLateOutMin;
    String? approvedEarlyInMin;
    String? approvedLateOutPay;
    String? approvedEarlyInPay;

    if (payroll.otMetrics.lateOut != null) {
      final pay = payroll.otMetrics.lateOut!.pay * info.salaryPerMinute;
      approvedLateOutMin = minToHrMin(payroll.otMetrics.lateOut!.minutes);
      approvedLateOutPay = fmtInr(pay);
      overtimePay += pay;
    }
    if (payroll.otMetrics.earlyIn != null) {
      final pay = payroll.otMetrics.earlyIn!.pay * info.salaryPerMinute;
      approvedEarlyInMin = minToHrMin(payroll.otMetrics.earlyIn!.minutes);
      approvedEarlyInPay = fmtInr(pay);
      overtimePay += pay;
    }

    double basePay = attendance.workedMin * info.salaryPerMinute;
    double mainPay = basePay + overtimePay;
    double totalPay = mainPay;
    double extratimePay = payroll.extratimeMin * info.salaryPerMinute;
    String fmtExtraTimeMin = minToHrMin(payroll.extratimeMin);
    String fmtExtraTimePay = fmtInr(extratimePay);
    total.addBase(basePay);
    total.addOvertime(overtimePay);
    total.addExtraTime(extratimePay);
    total.addTotal(totalPay + extratimePay);

    return FormattedPayroll(
      monthDay: payroll.dateDay,
      date: payroll.date,
      shiftMins: minToHrMin(attendance.shiftMin),
      clockMins: minToHrMin(attendance.workedMin),
      earlyInMins: minToHrMin(attendance.earlyInOtMin),
      earlyOutMins: minToHrMin(attendance.earlyOutLohMin),
      lateInMins: minToHrMin(attendance.lateInLohMin),
      lateOutMins: minToHrMin(attendance.lateOutOtMin),
      extraTimeMin: fmtExtraTimeMin,
      shiftPay: fmtInr(attendance.shiftMin * info.salaryPerMinute),
      clockPay: fmtInr(basePay),
      earlyInPay: fmtInr(attendance.earlyInOtMin * info.salaryPerMinute),
      earlyOutPay: fmtInr(attendance.earlyOutLohMin * info.salaryPerMinute),
      lateInPay: fmtInr(attendance.lateInLohMin * info.salaryPerMinute),
      lateOutPay: fmtInr(attendance.lateOutOtMin * info.salaryPerMinute),
      extraTimePay: fmtExtraTimePay,
      total: totalPay,
      netTotal: totalPay + extratimePay,
      approvedLateOutMins: approvedLateOutMin,
      approvedLateOutPay: approvedLateOutPay,
      approvedEarlyInMins: approvedEarlyInMin,
      approvedEarlyInPay: approvedEarlyInPay,
    );
  }
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
  bool isPresent;
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
    required this.isPresent,
  });
  factory Payroll.fromRawJson(String str) {
    return Payroll.fromJson(jsonDecode(str));
  }
  factory Payroll.fromJson(Map<String, dynamic> json) {
    // print("Hello from Payroll json: $json");
    return Payroll(
      date: json["date"],
      dateDay: json["date_word"],
      attendance: AttendanceRawMin.fromJson(json["attendance_metric"]),
      otMetrics: OtMetrics.fromJson(json["ot_metrics"]),
      extratimeMin: json["extratime_min"],
      isLeave: json["is_leave"],
      isHoliday: json["is_holiday"],
      isAbsent: json["is_absent"],
      isPresent: json["is_present"],
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
        "is_present": isPresent,
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

class FormattedPayrollSpecial {
  /// Date in Format ex:"01 Jan" [monthDay]
  String monthDay;

  /// Date in Format ex:"2025-01-28" [date]
  String date;

  /// Type of special day (e.g., leave, holiday, or absent) [type].
  String type;

  /// Message Show On leave, holiday, or absent and is its paid leave[message]
  String message;

  /// Type of leave, holiday, or absent [pay].
  String pay;

  String extratimeMin;
  String extratimePay;

  /// Total for pay + extratimePay [total]
  double total;
  FormattedPayrollSpecial({
    required this.monthDay,
    required this.date,
    required this.type,
    required this.message,
    required this.pay,
    required this.extratimeMin,
    required this.extratimePay,
    required this.total,
  });

  Color typeColor() {
    if (type == "Leave") {
      return Colors.lightBlue.shade400; // Softer, richer blue
    }
    if (type == "Holiday") {
      return Colors.amber.shade400; // Warmer, richer yellow
    }
    if (type == "Paid") {
      return Colors.indigo.shade500; // A fresh teal instead of blue-grey
    }
    return Colors.redAccent.shade400; // Slightly softer red accent
  }

  Color typeColor2() {
    if (type == "Leave") return Colors.lightBlue;
    if (type == "Holiday") return Colors.yellowAccent;
    if (type == "Paid") return Colors.blueGrey;
    return Colors.redAccent;
  }
}

class FormattedPayroll {
  /// Date in Format ex:"01 Jan" [monthDay]
  String monthDay;

  /// Date in Format ex:"2025-01-28" [date]
  String date;

  String shiftMins;
  String shiftPay;
  String clockMins;
  String clockPay;

  String lateInMins;
  String lateInPay;
  String earlyOutMins;
  String earlyOutPay;

  String lateOutMins;
  String lateOutPay;
  String earlyInMins;
  String earlyInPay;

  String? approvedLateOutMins;
  String? approvedLateOutPay;
  String? approvedEarlyInMins;
  String? approvedEarlyInPay;

  String extraTimeMin;
  String extraTimePay;

  /// Total Of the Attendance [total]
  double total;

  /// Total Of Attendance + ExtraTime [netTotal]
  double netTotal;

  FormattedPayroll({
    required this.monthDay,
    required this.date,
    required this.shiftMins,
    required this.shiftPay,
    required this.clockMins,
    required this.clockPay,
    required this.lateInMins,
    required this.lateInPay,
    required this.lateOutMins,
    required this.lateOutPay,
    required this.earlyInMins,
    required this.earlyInPay,
    required this.earlyOutMins,
    required this.earlyOutPay,
    required this.extraTimeMin,
    required this.extraTimePay,
    required this.total,
    required this.netTotal,
    this.approvedLateOutMins,
    this.approvedLateOutPay,
    this.approvedEarlyInMins,
    this.approvedEarlyInPay,
  });
}

class PayrollTotal {
  /// Amount paid for approved paid leave [paidLeave].
  double paidLeave;

  /// Earnings from the main shift, excluding overtime [baseEarned].
  double baseEarned;

  /// Earnings from approved overtime hours [overtimeEarned]
  double overtimeEarned;

  /// Earnings from additional extra time worked beyond regular shifts [extratimeEarned]
  double extratimeEarned;

  /// Total earnings including base, overtime, extra time, and paid leave [total]
  double total;
  PayrollTotal({
    required this.baseEarned,
    required this.overtimeEarned,
    required this.extratimeEarned,
    required this.paidLeave,
    required this.total,
  });

  factory PayrollTotal.empty() => PayrollTotal(
        baseEarned: 0,
        overtimeEarned: 0,
        extratimeEarned: 0,
        paidLeave: 0,
        total: 0,
      );

  void addBase(double amount) => baseEarned += amount;
  void addOvertime(double amount) => overtimeEarned += amount;
  void addExtraTime(double amount) => extratimeEarned += amount;
  void addTotal(double amount) => total += amount;
  void addPaidLeave(double amount) => paidLeave += amount;
}

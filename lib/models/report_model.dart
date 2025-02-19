import 'dart:convert';

import 'package:vcare_attendance/models/attendance_model.dart';
import 'package:vcare_attendance/models/extra_hour_modeal.dart';
import 'package:vcare_attendance/models/leave_model.dart';

class Report {
  InfoReport info;
  List<AttendanceRecord> data;

  Report({
    required this.info,
    required this.data,
  });

  factory Report.fromRawJson(String str) => Report.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Report.fromJson(Map<String, dynamic> json) => Report(
        info: InfoReport.fromJson(json["info"]),
        data: List<AttendanceRecord>.from(
            json["data"].map((x) => AttendanceRecord.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "info": info.toJson(),
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class AttendanceRecord {
  String dateLong;
  String dateShort;
  String date;
  bool shift;
  String? leaveStatus;
  Leave? leave;
  Attendance? attendance;
  List<ExtraHour> extraHour;

  AttendanceRecord({
    required this.dateLong,
    required this.dateShort,
    required this.date,
    required this.shift,
    required this.leaveStatus,
    required this.leave,
    required this.attendance,
    required this.extraHour,
  });

  factory AttendanceRecord.fromRawJson(String str) =>
      AttendanceRecord.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      AttendanceRecord(
        dateLong: json["date_long"],
        dateShort: json["date_short"],
        date: json["date"],
        shift: json["shift"],
        leaveStatus: json["leave_status"],
        leave: json["leave"] == null ? null : Leave.fromJson(json["leave"]),
        attendance: json["attendance"] == null
            ? null
            : Attendance.fromJson(json["attendance"]),
        extraHour: List<ExtraHour>.from(
          json["overtime"].map((x) => ExtraHour.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
        "date_long": dateLong,
        "date_short": dateShort,
        "date": date,
        "shift": shift,
        "leave_status": leaveStatus,
        "leave": leave?.toJson(),
        "attendance": attendance?.toJson(),
        "overtime": List<dynamic>.from(extraHour.map((x) => x.toJson())),
      };
}

class InfoReport {
  int appliedLeave;
  int leavesCount;

  InfoReport({
    required this.appliedLeave,
    required this.leavesCount,
  });

  factory InfoReport.fromRawJson(String str) =>
      InfoReport.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory InfoReport.fromJson(Map<String, dynamic> json) => InfoReport(
        appliedLeave: json["applied_leave"],
        leavesCount: json["leaves_count"],
      );

  Map<String, dynamic> toJson() => {
        "applied_leave": appliedLeave,
        "leaves_count": leavesCount,
      };
}

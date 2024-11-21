import 'dart:convert';

class Report {
  InfoReport info;
  List<AttendanceReport> attendance;
  Map<String, List<ExtraHourReport>> extraHours;

  Report({
    required this.info,
    required this.attendance,
    required this.extraHours,
  });

  factory Report.fromRawJson(String str) => Report.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Report.fromJson(Map<String, dynamic> json) => Report(
        info: InfoReport.fromJson(json["info"]),
        attendance: List<AttendanceReport>.from(
            json["attendance"].map((x) => AttendanceReport.fromJson(x))),
        extraHours: Map.from(json["extra_hours"]).map((k, v) =>
            MapEntry<String, List<ExtraHourReport>>(
                k,
                List<ExtraHourReport>.from(
                    v.map((x) => ExtraHourReport.fromJson(x))))),
      );

  Map<String, dynamic> toJson() => {
        "info": info.toJson(),
        "attendance": List<dynamic>.from(attendance.map((x) => x.toJson())),
        "extra_hours": Map.from(extraHours).map((k, v) =>
            MapEntry<String, dynamic>(
                k, List<dynamic>.from(v.map((x) => x.toJson())))),
      };
}

class AttendanceReport {
  String id;
  String employeeName;
  String inTime;
  String shiftTime;
  String status;
  String employeeId;
  String date;
  String date1;
  String date2;
  List<ExtraHourReport> extraHours;

  String? outTime;
  String? lossOfHours;
  String? maintainance;
  String? reason;
  String? clockInEarly;
  String? clockInLate;
  String? clockOutEarly;
  String? clockOutLate;
  String? reasonEarly;
  String? reasonLate;

  AttendanceReport({
    required this.id,
    required this.inTime,
    required this.shiftTime,
    required this.date,
    required this.date1,
    required this.date2,
    required this.employeeName,
    required this.status,
    required this.employeeId,
    required this.extraHours,
    this.outTime,
    this.lossOfHours,
    this.maintainance,
    this.reason,
    this.clockInEarly,
    this.clockInLate,
    this.clockOutEarly,
    this.clockOutLate,
    this.reasonEarly,
    this.reasonLate,
  });

  factory AttendanceReport.fromRawJson(String str) =>
      AttendanceReport.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AttendanceReport.fromJson(Map<String, dynamic> json) =>
      AttendanceReport(
        id: json["id"],
        employeeName: json["employee_name"],
        inTime: json["in_time"],
        outTime: json["out_time"],
        shiftTime: json["shift_time"],
        lossOfHours: json["loss_of_hours"],
        maintainance: json["maintainance"],
        reason: json["reason"],
        status: json["status"],
        employeeId: json["employee_id"],
        date: json["date"],
        date1: json["date1"],
        date2: json["date2"],
        clockInEarly: json["clock_in_early"],
        clockInLate: json["clock_in_late"],
        clockOutEarly: json["clock_out_early"],
        clockOutLate: json["clock_out_late"],
        reasonEarly: json["reason_early"],
        reasonLate: json["reason_late"],
        extraHours: List<ExtraHourReport>.from(
            json["extra_hours"].map((x) => ExtraHourReport.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "employee_name": employeeName,
        "in_time": inTime,
        "out_time": outTime,
        "shift_time": shiftTime,
        "loss_of_hours": lossOfHours,
        "maintainance": maintainance,
        "reason": reason,
        "status": status,
        "employee_id": employeeId,
        "date": date,
        "date1": date1,
        "date2": date2,
        "clock_in_early": clockInEarly,
        "clock_in_late": clockInLate,
        "clock_out_early": clockOutEarly,
        "clock_out_late": clockOutLate,
        "reason_early": reasonEarly,
        "reason_late": reasonLate,
        "extra_hours": List<dynamic>.from(extraHours.map((x) => x.toJson())),
      };
}

class ExtraHourReport {
  String id;
  String employeeId;
  String inTime;
  String? outTime;
  String reason;
  String date;
  String date1;
  DateTime createdAt;

  ExtraHourReport({
    required this.id,
    required this.employeeId,
    required this.inTime,
    this.outTime,
    required this.reason,
    required this.date,
    required this.date1,
    required this.createdAt,
  });

  factory ExtraHourReport.fromRawJson(String str) =>
      ExtraHourReport.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ExtraHourReport.fromJson(Map<String, dynamic> json) =>
      ExtraHourReport(
        id: json["id"],
        employeeId: json["employee_id"],
        inTime: json["in_time"],
        outTime: json["out_time"],
        reason: json["reason"],
        date: json["date"],
        date1: json["date1"],
        createdAt: DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "employee_id": employeeId,
        "in_time": inTime,
        "out_time": outTime,
        "reason": reason,
        "date": date,
        "date1": date1,
        "created_at": createdAt.toIso8601String(),
      };
}

class InfoReport {
  String? presentCount;
  String? absentCount;
  String entryCount;
  String daysInMonth;
  String otEntryCount;

  InfoReport({
    this.presentCount,
    this.absentCount,
    required this.entryCount,
    required this.daysInMonth,
    required this.otEntryCount,
  });

  factory InfoReport.fromRawJson(String str) =>
      InfoReport.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory InfoReport.fromJson(Map<String, dynamic> json) => InfoReport(
        presentCount: json["present_count"],
        absentCount: json["absent_count"],
        entryCount: json["entry_count"],
        daysInMonth: json["days_in_month"],
        otEntryCount: json["ot_entry_count"],
      );

  Map<String, dynamic> toJson() => {
        "present_count": presentCount,
        "absent_count": absentCount,
        "entry_count": entryCount,
        "days_in_month": daysInMonth,
        "ot_entry_count": otEntryCount,
      };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}

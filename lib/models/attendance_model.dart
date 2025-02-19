import 'dart:convert';

class Attendance {
  String id;
  String employeeName;
  String inTime;
  String? outTime;
  String shiftTime;
  String? lossOfHours;
  String? maintainance;
  String? reason;
  String status;
  String employeeId;
  String location;
  String? outLocation;
  String authType;
  String idType;
  String date;
  String date1;
  String date2;
  String? clockInEarly;
  String? clockInLate;
  String? clockOutEarly;
  String? clockOutLate;
  String? reasonEarly;
  String? reasonLate;

  Attendance({
    required this.id,
    required this.employeeName,
    required this.inTime,
    required this.shiftTime,
    required this.status,
    required this.employeeId,
    required this.location,
    required this.authType,
    required this.idType,
    required this.date,
    required this.date1,
    required this.date2,
    this.outTime,
    this.outLocation,
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

  factory Attendance.fromRawJson(String str) =>
      Attendance.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Attendance.fromJson(Map<String, dynamic> json) => Attendance(
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
        location: json["location"],
        outLocation: json["out_location"],
        authType: json["auth_type"],
        idType: json["id_type"],
        date: json["date"],
        date1: json["date1"],
        date2: json["date2"],
        clockInEarly: json["clock_in_early"],
        clockInLate: json["clock_in_late"],
        clockOutEarly: json["clock_out_early"],
        clockOutLate: json["clock_out_late"],
        reasonEarly: json["reason_early"],
        reasonLate: json["reason_late"],
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
        "location": location,
        "out_location": outLocation,
        "auth_type": authType,
        "id_type": idType,
        "date": date,
        "date1": date1,
        "date2": date2,
        "clock_in_early": clockInEarly,
        "clock_in_late": clockInLate,
        "clock_out_early": clockOutEarly,
        "clock_out_late": clockOutLate,
        "reason_early": reasonEarly,
        "reason_late": reasonLate,
      };
}

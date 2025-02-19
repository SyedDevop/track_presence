import 'dart:convert';

class ExtraHour {
  String id;
  String employeeId;
  String inTime;
  String? outTime;
  String location;
  String? outLocation;
  String authType;
  String reason;
  String date;
  String date1;
  String createdAt;

  ExtraHour({
    required this.id,
    required this.employeeId,
    required this.inTime,
    this.outTime,
    required this.location,
    this.outLocation,
    required this.authType,
    required this.reason,
    required this.date,
    required this.date1,
    required this.createdAt,
  });

  factory ExtraHour.fromRawJson(String str) =>
      ExtraHour.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ExtraHour.fromJson(Map<String, dynamic> json) => ExtraHour(
        id: json["id"],
        employeeId: json["employee_id"],
        inTime: json["in_time"],
        outTime: json["out_time"],
        location: json["location"],
        outLocation: json["out_location"],
        authType: json["auth_type"],
        reason: json["reason"],
        date: json["date"],
        date1: json["date1"],
        createdAt: json["created_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "employee_id": employeeId,
        "in_time": inTime,
        "out_time": outTime,
        "location": location,
        "out_location": outLocation,
        "auth_type": authType,
        "reason": reason,
        "date": date,
        "date1": date1,
        "created_at": createdAt,
      };
}

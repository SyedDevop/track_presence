import 'dart:convert';

class ShiftReport {
  final List<ShiftTable> data;

  ShiftReport({
    required this.data,
  });

  factory ShiftReport.fromRawJson(String str) =>
      ShiftReport.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ShiftReport.fromJson(Map<String, dynamic> json) => ShiftReport(
        data: List<ShiftTable>.from(
            json["data"].map((x) => ShiftTable.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class ShiftTable {
  final String id;
  final String empId;
  final String empName;
  final String department;
  final String shiftTime;
  final String fromDate;
  final String toDate;
  final String date1;
  final String date2;
  final String? reason;

  ShiftTable({
    required this.id,
    required this.empId,
    required this.empName,
    required this.department,
    required this.shiftTime,
    required this.fromDate,
    required this.toDate,
    required this.date1,
    required this.date2,
    this.reason,
  });

  factory ShiftTable.fromRawJson(String str) =>
      ShiftTable.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ShiftTable.fromJson(Map<String, dynamic> json) => ShiftTable(
        id: json["id"],
        empId: json["emp_id"],
        empName: json["emp_name"],
        department: json["department"],
        shiftTime: json["shift_time"],
        fromDate: json["from_date"],
        toDate: json["to_date"],
        date1: json["date1"],
        date2: json["date2"],
        reason: json["reason"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "emp_id": empId,
        "emp_name": empName,
        "department": department,
        "shift_time": shiftTime,
        "from_date": fromDate,
        "to_date": toDate,
        "date1": date1,
        "date2": date2,
        "reason": reason,
      };
}

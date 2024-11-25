import 'dart:convert';

import 'package:flutter/material.dart';

class LeaveReport {
  List<Leave> data;
  LeaveReport({
    required this.data,
  });

  factory LeaveReport.fromRawJson(String str) =>
      LeaveReport.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LeaveReport.fromJson(Map<String, dynamic> json) => LeaveReport(
        data: List<Leave>.from(json["data"].map((x) => Leave.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Leave {
  String id;
  String empId;
  String empName;
  String startDate;
  String endDate;
  String reason;
  String status;
  String department;

  Leave({
    required this.id,
    required this.empId,
    required this.empName,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    required this.department,
  });

  Color? get statusColor {
    switch (status) {
      case "Pending":
        return Colors.yellowAccent;
      case "Approved":
        return Colors.greenAccent;
      case "Declined":
        return Colors.redAccent;
      default:
        return null;
    }
  }

  factory Leave.fromRawJson(String str) => Leave.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Leave.fromJson(Map<String, dynamic> json) => Leave(
        id: json["id"],
        empId: json["emp_id"],
        empName: json["emp_name"],
        startDate: json["start_date"],
        endDate: json["end_date"],
        reason: json["reason"],
        status: json["status"],
        department: json["department"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "emp_id": empId,
        "emp_name": empName,
        "start_date": startDate,
        "end_date": endDate,
        "reason": reason,
        "status": status,
        "department": department,
      };
}

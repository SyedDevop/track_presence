import 'dart:convert';

List<Payslip> payrollFromJson(String str) => List<Payslip>.from(
      json.decode(str).map((x) => Payslip.fromJson(x)),
    );

class Payslip {
  int id;
  String empId;
  String empName;
  String department;
  int basicSalary;
  int totalAllowances;
  int totalDeductions;
  int netSalary;
  String date1;
  int status;
  int totalDays;
  int daysSalary;
  int extraHrs;
  int extraOtHrs;
  Map<String, dynamic> allowances;
  Map<String, dynamic> deductions;
  int lostDays;

  Payslip({
    required this.id,
    required this.empId,
    required this.empName,
    required this.department,
    required this.basicSalary,
    required this.totalAllowances,
    required this.totalDeductions,
    required this.netSalary,
    required this.date1,
    required this.status,
    required this.totalDays,
    required this.daysSalary,
    required this.extraHrs,
    required this.extraOtHrs,
    required this.allowances,
    required this.deductions,
    required this.lostDays,
  });

  factory Payslip.fromRawJson(String str) => Payslip.fromJson(json.decode(str));

  factory Payslip.fromJson(Map<String, dynamic> json) => Payslip(
        id: json["id"],
        empId: json["emp_id"],
        empName: json["emp_name"],
        department: json["department"],
        basicSalary: json["basic_salary"],
        totalAllowances: json["total_allowances"],
        totalDeductions: json["total_deductions"],
        netSalary: json["net_salary"],
        date1: json["date1"],
        status: json["status"],
        totalDays: json["total_days"],
        daysSalary: json["days_salary"],
        extraHrs: json["extra_hrs"],
        extraOtHrs: json["extra_ot_hrs"],
        allowances: json["allowances"],
        deductions: json["deductions"],
        lostDays: json["lost_days"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "emp_id": empId,
        "emp_name": empName,
        "department": department,
        "basic_salary": basicSalary,
        "total_allowances": totalAllowances,
        "total_deductions": totalDeductions,
        "net_salary": netSalary,
        "date1": date1,
        "status": status,
        "total_days": totalDays,
        "days_salary": daysSalary,
        "extra_hrs": extraHrs,
        "extra_ot_hrs": extraOtHrs,
        "allowances": allowances,
        "deductions": deductions,
        "lost_days": lostDays,
      };
}

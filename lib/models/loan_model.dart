import 'dart:convert';

class LoanReport {
  List<Loan> data;
  LoanReport({required this.data});

  factory LoanReport.formRawJson(String str) =>
      LoanReport.fromJson(jsonDecode(str));

  factory LoanReport.fromJson(Map<String, dynamic> json) {
    return LoanReport(
      data: List<Loan>.from(
        json["data"].map((x) => Loan.fromJson(x)),
      ),
    );
  }
}

class Loan {
  final int id;
  final String payrollId;
  final String department;
  final String loanType;
  final double loanAmount;
  final double loanBalance;
  final String date1;
  final String date2;
  final String status;
  final String approval;
  final bool credited;
  final String? approvedBy;

  Loan({
    required this.id,
    required this.payrollId,
    required this.department,
    required this.loanType,
    required this.loanAmount,
    required this.loanBalance,
    required this.date1,
    required this.date2,
    required this.status,
    required this.approval,
    required this.credited,
    this.approvedBy,
  });

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: json['id'],
      payrollId: json['payroll_id'],
      department: json['department'],
      loanType: json['loan_type'],
      loanAmount: double.tryParse(json['loan_amount']) ?? 0.0,
      loanBalance: double.tryParse(json['loan_balance']) ?? 0.0,
      date1: json['date1'],
      date2: json['date2'],
      status: json['status'],
      approval: json['approval_status'],
      credited: json['credited'] == 1,
      approvedBy: json['approved_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'payroll_id': payrollId,
      'department': department,
      'loan_type': loanType,
      'loan_amount': loanAmount,
      'loan_balance': loanBalance,
      'date1': date1,
      'date2': date2,
      'status': status,
      'approval_status': approval,
      'credited': credited ? 1 : 0,
      'approved_by': approvedBy,
    };
  }
}

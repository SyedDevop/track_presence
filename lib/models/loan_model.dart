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

class LoanFullReport {
  Loan loan;
  List<LoanPayemt> payments;
  LoanFullReport({required this.loan, required this.payments});

  factory LoanFullReport.formRawJson(String str) =>
      LoanFullReport.fromJson(jsonDecode(str));

  factory LoanFullReport.fromJson(Map<String, dynamic> json) {
    print(json["data"]["loan_payments"]);
    return LoanFullReport(
      loan: Loan.fromJson(json["data"]["loan"]),
      payments: List<LoanPayemt>.from(
        json["data"]["loan_payments"].map((x) => LoanPayemt.fromJson(x)),
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

List<LoanPayemt> loanPaymentListFromJson(String str) => List<LoanPayemt>.from(
      json.decode(str).map((x) => LoanPayemt.fromJson(x)),
    );

class LoanPayemt {
  final int id;
  final int loanRefId;
  final int payrollRefId;
  final String employeeId;
  final String paymentDate;
  final double amountPaid;
  final double balance;
  final String? loanType;
  final bool payrollDeducted;
  final bool credited;

  LoanPayemt({
    required this.id,
    required this.loanRefId,
    required this.payrollRefId,
    required this.employeeId,
    required this.paymentDate,
    required this.amountPaid,
    required this.balance,
    required this.payrollDeducted,
    required this.credited,
    this.loanType,
  });

  factory LoanPayemt.fromJson(Map<String, dynamic> json) {
    return LoanPayemt(
      id: json['id'],
      loanRefId: json['loan_ref_id'],
      payrollRefId: json['payroll_ref_id'],
      employeeId: json['employee_id'],
      paymentDate: json['payment_date'],
      amountPaid: double.tryParse(json['amount_paid']) ?? 0.0,
      balance: double.tryParse(json['remaining_balance']) ?? 0.0,
      payrollDeducted: json['payroll_deducted'] == 1,
      credited: json['credited'] == 1,
      loanType: json['loan_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'loan_ref_id': loanRefId,
      'payroll_ref_id': payrollRefId,
      'employee_id': employeeId,
      'payment_date': paymentDate,
      'amount_paid': amountPaid,
      'remaining_balance': balance,
      'payroll_deducted': payrollDeducted ? 1 : 0,
      'credited': credited ? 1 : 0,
      'loan_type': loanType,
    };
  }
}

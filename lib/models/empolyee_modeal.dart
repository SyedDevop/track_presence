import 'dart:convert';

class Employee {
  PersonalDetails? personalDetails;
  CompanyDetails? companyDetails;
  JobHistory? jobHistory;
  BankDetails? bankDetails;

  Employee({
    this.personalDetails,
    this.companyDetails,
    this.jobHistory,
    this.bankDetails,
  });

  factory Employee.fromRawJson(String str) =>
      Employee.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
        personalDetails: json["personal_details"] != null
            ? PersonalDetails.fromJson(json["personal_details"])
            : null,
        companyDetails: json["company_details"] != null
            ? CompanyDetails.fromJson(json["company_details"])
            : null,
        jobHistory: json["job_history"] != null
            ? JobHistory.fromJson(json["job_history"])
            : null,
        bankDetails: json["bank_details"] != null
            ? BankDetails.fromJson(json["bank_details"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "personal_details": personalDetails?.toJson(),
        "company_details": companyDetails?.toJson(),
        "job_history": jobHistory?.toJson(),
        "bank_details": bankDetails?.toJson(),
      };
}

class BankDetails {
  String id;
  String accountHolderName;
  String accountNum;
  String bankName;
  String branch;
  String personalAccountHolderName;
  String personalAccountNumber;
  String personalBankName;
  String personalBranch;

  BankDetails({
    required this.id,
    required this.accountHolderName,
    required this.accountNum,
    required this.bankName,
    required this.branch,
    required this.personalAccountHolderName,
    required this.personalAccountNumber,
    required this.personalBankName,
    required this.personalBranch,
  });

  factory BankDetails.fromRawJson(String str) =>
      BankDetails.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BankDetails.fromJson(Map<String, dynamic> json) => BankDetails(
        id: json["id"],
        accountHolderName: json["account_holder_name"],
        accountNum: json["account_num"],
        bankName: json["bank_name"],
        branch: json["branch"],
        personalAccountHolderName: json["personal_account_holder_name"],
        personalAccountNumber: json["personal_account_number"],
        personalBankName: json["personal_bank_name"],
        personalBranch: json["personal_branch"],
      );

  List<(String, dynamic)> todata() => [
        ("Account Holder Name", accountHolderName),
        ("Account Number", accountNum),
        ("Bank Name", bankName),
        ("Branch", branch),
        ("Personal Account Holder Name", personalAccountHolderName),
        ("Personal Account Number", personalAccountNumber),
        ("Personal Bank Name", personalBankName),
        ("Personal Branch", personalBranch),
      ];

  Map<String, dynamic> toJson() => {
        "id": id,
        "account_holder_name": accountHolderName,
        "account_num": accountNum,
        "bank_name": bankName,
        "branch": branch,
        "personal_account_holder_name": personalAccountHolderName,
        "personal_account_number": personalAccountNumber,
        "personal_bank_name": personalBankName,
        "personal_branch": personalBranch,
      };
}

class CompanyDetails {
  String id;
  String department;
  String designation;
  String doj;
  String joiningSalary;
  String status;

  CompanyDetails({
    required this.id,
    required this.department,
    required this.designation,
    required this.doj,
    required this.joiningSalary,
    required this.status,
  });

  factory CompanyDetails.fromRawJson(String str) =>
      CompanyDetails.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CompanyDetails.fromJson(Map<String, dynamic> json) => CompanyDetails(
        id: json["id"],
        department: json["department"],
        designation: json["designation"],
        doj: json["doj"],
        joiningSalary: json["joining_salary"],
        status: json["status"],
      );

  List<(String, dynamic)> todata() => [
        ("Department", department),
        ("Designation", designation),
        ("Date Of Joining", doj),
        ("Joining Salary", joiningSalary),
        ("Status", status == "1" ? "Active" : "in Active"),
      ];

  Map<String, dynamic> toJson() => {
        "id": id,
        "department": department,
        "designation": designation,
        "doj": doj,
        "joining_salary": joiningSalary,
        "status": status,
      };
}

class JobHistory {
  String id;
  String companyName;
  String department;
  String designation;
  String startDate;
  String endDate;

  JobHistory({
    required this.id,
    required this.companyName,
    required this.department,
    required this.designation,
    required this.startDate,
    required this.endDate,
  });

  factory JobHistory.fromRawJson(String str) =>
      JobHistory.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory JobHistory.fromJson(Map<String, dynamic> json) => JobHistory(
        id: json["id"],
        companyName: json["company_name"],
        department: json["department"],
        designation: json["designation"],
        startDate: json["start_date"],
        endDate: json["end_date"],
      );

  List<(String, dynamic)> todata() => [
        ("Company Name", companyName),
        ("Department", department),
        ("Designation", designation),
        ("Start Date", startDate),
        ("End Date", endDate),
      ];

  Map<String, dynamic> toJson() => {
        "id": id,
        "company_name": companyName,
        "department": department,
        "designation": designation,
        "start_date": startDate,
        "end_date": endDate,
      };
}

class PersonalDetails {
  String id;
  String empId;
  String name;
  String fathersName;
  String dob;
  String gender;
  String phone;
  String localAddress;
  String permanentAddress;
  String nationality;
  String aadharNum;
  String panCard;
  String maritialStatus;

  PersonalDetails({
    required this.id,
    required this.empId,
    required this.name,
    required this.fathersName,
    required this.dob,
    required this.gender,
    required this.phone,
    required this.localAddress,
    required this.permanentAddress,
    required this.nationality,
    required this.aadharNum,
    required this.panCard,
    required this.maritialStatus,
  });

  factory PersonalDetails.fromRawJson(String str) =>
      PersonalDetails.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PersonalDetails.fromJson(Map<String, dynamic> json) =>
      PersonalDetails(
        id: json["id"],
        empId: json["emp_id"],
        name: json["name"],
        fathersName: json["fathers_name"],
        dob: json["dob"],
        gender: json["gender"],
        phone: json["phone"],
        localAddress: json["local_address"],
        permanentAddress: json["permanent_address"],
        nationality: json["nationality"],
        aadharNum: json["aadhar_num"],
        panCard: json["pan_card"],
        maritialStatus: json["maritial_status"],
      );

  List<(String, dynamic)> todata() => [
        ("Name", name),
        ("Fathers_name", fathersName),
        ("Date Of Birth", dob),
        ("Gender", gender),
        ("Phone", phone),
        ("Local Address", localAddress),
        ("Permanent Address", permanentAddress),
        ("Nationality", nationality),
        ("Aadhar Num", aadharNum),
        ("Pan Card", panCard),
        ("Maritial Status", maritialStatus),
      ];

  Map<String, dynamic> toJson() => {
        "id": id,
        "emp_id": empId,
        "name": name,
        "fathers_name": fathersName,
        "dob": dob,
        "gender": gender,
        "phone": phone,
        "local_address": localAddress,
        "permanent_address": permanentAddress,
        "nationality": nationality,
        "aadhar_num": aadharNum,
        "pan_card": panCard,
        "maritial_status": maritialStatus,
      };
}

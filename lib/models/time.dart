import 'package:vcare_attendance/utils/utils.dart';

class ShiftTime {
  final String name;
  final String fromTime;
  final String toTime;
  final String fromDate;
  final String toDate;
  final String shiftHours;
  const ShiftTime({
    required this.name,
    required this.fromTime,
    required this.toTime,
    required this.fromDate,
    required this.toDate,
    required this.shiftHours,
  });
  static ShiftTime fromMap(Map<String, dynamic> data) {
    final inT = dateFormat24.parse(data["from_time"]);
    final outT = dateFormat24.parse(data["to_time"]);
    final shH = durationToHrMin(outT.difference(inT));

    return ShiftTime(
      name: data["emp_name"],
      fromTime: dateFormat2.format(inT),
      fromDate: data["from_date"],
      toDate: data["to_date"],
      toTime: dateFormat2.format(outT),
      shiftHours: shH,
    );
  }
}

class ExtraHours {
  final String id;

  /// [date] Date fmt in Year-month-day ex: (2024-11-06)
  final String date;

  /// [date1] Date fmt in Month and Year ex: (November, 2024)
  final String date1;
  final String inTime;
  final String reason;
  final String createdAt;
  final String? outTime;

  const ExtraHours({
    required this.id,
    required this.date,
    required this.date1,
    required this.inTime,
    required this.reason,
    required this.createdAt,
    this.outTime,
  });

  static List<ExtraHours> fromArrayMap(List<dynamic> dataList) {
    final result = dataList
        .map(
          (data) => ExtraHours(
            id: data['id'],
            date: data['date'],
            date1: data['date1'],
            inTime: data['in_time'],
            outTime: data['out_time'],
            reason: data['reason'],
            createdAt: data['created_at'],
          ),
        )
        .toList();
    return result;
  }

  static ExtraHours fromMap(Map<String, dynamic> data) {
    return ExtraHours(
      id: data['id'],
      date: data['date'],
      date1: data['date1'],
      inTime: data['in_time'],
      outTime: data['out_time'],
      reason: data['reason'],
      createdAt: data['created_at'],
    );
  }
}

class Attendance {
  final String id;
  final String inTime;
  final String? outTime;
  final String shiftTime;
  final String? lossOfTime;
  final String? overTime;
  final String? clockHours;

  /// [date] Date fmt in Year-month-day ex: (11-16-2024)
  final String date;

  /// [date1] Date fmt in day-Month-Year ex: (16-11-2024)
  final String date1;

  /// [date2] Date fmt in Month and Year ex: (November, 2024)
  final String date2;

  final String? clockInEarly;
  final String? clockInLate;
  final String? clockOutEarly;
  final String? clockOutLate;

  const Attendance({
    required this.date,
    required this.date1,
    required this.date2,
    required this.inTime,
    required this.id,
    required this.shiftTime,
    this.lossOfTime,
    this.overTime,
    this.outTime,
    this.clockHours,
    this.clockInEarly,
    this.clockInLate,
    this.clockOutEarly,
    this.clockOutLate,
  });
  static Attendance fromMap(Map<String, dynamic> data) {
    final inTime = dateFormat2.format(dateFormat24.parse(data['in_time']));
    final outTime = data['out_time'] != null
        ? dateFormat2.format(dateFormat24.parse(data['out_time']))
        : null;
    return Attendance(
      id: data['id'],
      inTime: inTime,
      outTime: outTime,
      shiftTime: data['shift_time'],
      lossOfTime: data['loss_of_hours'],
      overTime: data['maintainance'],
      date: data['date'],
      date1: data['date1'],
      date2: data['date2'],
      clockHours: data["work_time"],
      clockInEarly: data['clock_in_early'],
      clockInLate: data['clock_in_late'],
      clockOutEarly: data['clock_out_early'],
      clockOutLate: data['clock_out_late'],
    );
  }
}

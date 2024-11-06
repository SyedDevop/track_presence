class ShiftTime {
  final String name;
  final String fromTime;
  final String toTime;
  final String shiftHours;
  const ShiftTime({
    required this.name,
    required this.fromTime,
    required this.toTime,
    required this.shiftHours,
  });
  static ShiftTime fromMap(Map<String, dynamic> data) {
    final shH =
        "${data["work_time"]["hour"]} hr ${data["work_time"]["minutes"]} min";
    return ShiftTime(
      name: data["emp_name"],
      fromTime: data["from_time"],
      toTime: data["to_time"],
      shiftHours: shH,
    );
  }
}

class ClockedTime {
  final String date;
  final String inTime;
  final String id;
  final String shiftTime;
  final String? lossOfTime;
  final String? overTime;
  final String? outTime;
  final String? clockHours;

  const ClockedTime({
    required this.date,
    required this.inTime,
    required this.id,
    required this.shiftTime,
    this.lossOfTime,
    this.overTime,
    this.outTime,
    this.clockHours,
  });
  static ClockedTime fromMap(Map<String, dynamic> data) {
    final chH = data["work_time"] != null
        ? "${data["work_time"]["hour"]} hr ${data["work_time"]["minutes"]} min"
        : null;
    return ClockedTime(
      id: data['id'],
      date: data['date1'],
      inTime: data['in_time'],
      outTime: data['out_time'],
      shiftTime: data['shift_time'],
      lossOfTime: data['loss_of_hours'],
      overTime: data['maintainance'],
      clockHours: chH,
    );
  }
}

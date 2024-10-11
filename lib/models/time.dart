class ShiftTime {
  final String name;
  final String fromTime;
  final String toTime;

  const ShiftTime({
    required this.name,
    required this.fromTime,
    required this.toTime,
  });
  static ShiftTime fromMap(Map<String, dynamic> data) {
    final time = data['time'].split(" TO ");
    return ShiftTime(
      name: data["name"],
      fromTime: time[0],
      toTime: time[1],
    );
  }
}

class ClockedTime {
  final String date;
  final String inTime;
  final String outTime;
  final String id;
  final String overTime;
  final String shiftTime;
  final String lossOfTime;

  const ClockedTime({
    required this.date,
    required this.inTime,
    required this.outTime,
    required this.id,
    required this.shiftTime,
    required this.lossOfTime,
    required this.overTime,
  });
  static ClockedTime fromMap(Map<String, dynamic> data) {
    return ClockedTime(
      id: data['id'],
      date: data['date1'],
      inTime: data['in_time'],
      outTime: data['out_time'],
      shiftTime: data['shift_time'],
      lossOfTime: data['loss_of_hours'],
      overTime: data['maintainance'],
    );
  }
}

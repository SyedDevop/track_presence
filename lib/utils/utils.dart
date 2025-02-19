import 'package:intl/intl.dart';

/// [dateFmtDMY] Date formate in "24/12/2024"
final DateFormat dateFmtDMY = DateFormat('dd/MM/yyyy');

/// [dateFmt] Date formate in "2024-12-24"
final DateFormat dateFmt = DateFormat('yyyy-MM-dd');

String minToHrMin(dynamic min) {
  if (min == null) {
    return durationToHrMin(Duration.zero);
  } else if (min is String) {
    return durationToHrMin(Duration(minutes: int.parse(min)));
  } else if (min is int) {
    return durationToHrMin(Duration(minutes: min));
  } else {
    assert(false,
        "[Error] #minToHrMin expected min to be String or int got ${min.runtimeType}");
  }
  return "";
}

String durationToHrMin(Duration d) {
  return "${d.inHours} Hr  ${d.inMinutes % 60} Min";
}

DateFormat dateFormat = DateFormat("yyyy-MM-dd h:mm a");
DateFormat dateFormat24 = DateFormat("yyyy-MM-dd HH:mm");
DateFormat dateFormat2 = DateFormat("dd-MM-yyyy h:mm a");
DateFormat dateFormat12 = DateFormat("dd-MM-yyyy HH:mm");
Duration calDiff12(String inTime, String? outTime) {
  if (outTime == null) return Duration.zero;
  final inT = dateFormat12.parse(inTime);
  final outT = dateFormat12.parse(outTime);
  return outT.difference(inT);
}

Duration calDiff(String? inTime, String? outTime) {
  if (outTime == null || inTime == null) return Duration.zero;
  try {
    final inT = dateFormat24.parse(inTime);
    final outT = dateFormat24.parse(outTime);
    return outT.difference(inT);
  } catch (e) {
    return Duration.zero;
  }
}

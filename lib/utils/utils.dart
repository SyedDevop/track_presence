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

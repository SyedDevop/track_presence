class Cord {
  final double lat;
  final double long;
  const Cord({required this.lat, required this.long});
}

/// [kminDistance] is in Meters.
const kminDistance = 25;

/// [kVacreCoration] Coordination for Vcare-hospital.
const kVacreCord = Cord(lat: 13.015923, long: 77.597281);

/// [kMedisconCord] Coordination for Vcare Mediscon.
const kMedisconCord = Cord(lat: 13.011386, long: 77.616240);

/// [kRizHomeCord] Coordination for riz home
const kRizHomeCord = Cord(lat: 12.942789, long: 77.591243);

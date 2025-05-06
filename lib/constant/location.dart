class Cord {
  final double lat;
  final double long;
  final String name;
  const Cord({required this.lat, required this.long, required this.name});
}

/// [kMinDistance] is in Meters.
const kMinDistance = 25;

/// [kVcareCord] Coordination for Vcare-hospital.
const kVcareCord = Cord(
  lat: 13.015923,
  long: 77.597281,
  name: "Vcare-hospital",
);

/// [kVcareWareHouseCord] Coordination for Vcare Mediscon.
const kVcareWareHouseCord = Cord(
  lat: 13.015602,
  long: 77.597355,
  name: "Vcare-hospital WareHouse",
);

/// [kMedfocusCord] Coordination for Vcare Mediscon.
const kMedfocusCord = Cord(
  lat: 12.937675,
  long: 77.558093,
  name: "Medfocus Healthcare",
);

/// [kMedisconCord] Coordination for Vcare Mediscon.
const kMedisconCord = Cord(lat: 13.011386, long: 77.616240, name: "Mediscon");

/// [kRizHomeCord] Coordination for riz home
const kRizHomeCord = Cord(lat: 12.942789, long: 77.591243, name: "Riz Home");

const kCoords = [
  kVcareCord,
  kVcareWareHouseCord,
  kMedisconCord,
  kMedfocusCord,
  kRizHomeCord,
];

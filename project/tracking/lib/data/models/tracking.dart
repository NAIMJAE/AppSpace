class Tracking {
  final DateTime time;
  final double latitude;
  final double longitude;
  final double distance;
  final bool verification;

  Tracking({
    required this.time,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.verification,
  });
}

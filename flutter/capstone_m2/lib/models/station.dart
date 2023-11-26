class Station {
  const Station({
    required this.name,
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.ports,
  });

  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final int ports;
}

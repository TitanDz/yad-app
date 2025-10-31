class Place {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? placeType;
  final String? phoneNumber;
  final String? website;

  Place({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.placeType,
    this.phoneNumber,
    this.website,
  });
}

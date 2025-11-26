import 'package:latlong2/latlong.dart';

/// Model untuk menyimpan data lokasi customer
class LocationData {
  final double latitude;
  final double longitude;
  final String? address;
  final String? notes;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.address,
    this.notes,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      address: json['address'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'notes': notes,
    };
  }

  LatLng toLatLng() => LatLng(latitude, longitude);

  static LocationData fromLatLng(LatLng latLng, {String? address, String? notes}) {
    return LocationData(
      latitude: latLng.latitude,
      longitude: latLng.longitude,
      address: address,
      notes: notes,
    );
  }

  @override
  String toString() => 'LocationData(lat: $latitude, lng: $longitude, address: $address)';
}

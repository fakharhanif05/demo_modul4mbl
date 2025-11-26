import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

/// Widget untuk memilih lokasi di peta
class LocationPickerWidget extends StatefulWidget {
  final LatLng? initialLocation;
  final Function(LatLng, String) onLocationSelected;
  final String title;

  const LocationPickerWidget({
    Key? key,
    this.initialLocation,
    required this.onLocationSelected,
    this.title = 'Pilih Lokasi',
  }) : super(key: key);

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  late MapController _mapController;
  late LatLng _selectedLocation;
  final TextEditingController _addressController = TextEditingController();
  bool _isLoadingLocation = false;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedLocation = widget.initialLocation ?? const LatLng(-6.2088, 106.8456); // Jakarta default
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationError = 'Layanan lokasi tidak aktif. Aktifkan di pengaturan.';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationError = 'Izin lokasi ditolak';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError = 'Izin lokasi ditolak secara permanen. Ubah di pengaturan.';
        });
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final LatLng currentLocation = LatLng(position.latitude, position.longitude);
      
      setState(() {
        _selectedLocation = currentLocation;
      });

      _mapController.move(currentLocation, 17);
    } catch (e) {
      setState(() {
        _locationError = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  void _confirmLocation() {
    String address = _addressController.text.isEmpty
        ? 'Latitude: ${_selectedLocation.latitude.toStringAsFixed(6)}, Longitude: ${_selectedLocation.longitude.toStringAsFixed(6)}'
        : _addressController.text;

    widget.onLocationSelected(_selectedLocation, address);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF667EEA),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),
          // Map
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _selectedLocation,
                      initialZoom: 15,
                      onTap: (tapPosition, point) {
                        setState(() {
                          _selectedLocation = point;
                        });
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.demomodul4',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _selectedLocation,
                            width: 40,
                            height: 40,
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Color(0xFF667EEA),
                                    size: 32,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Current location button
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: FloatingActionButton(
                      mini: true,
                      backgroundColor: const Color(0xFF667EEA),
                      onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                      child: _isLoadingLocation
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.my_location, color: Colors.white),
                    ),
                  ),
                  // Error message
                  if (_locationError != null)
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[400]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red[700]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _locationError!,
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Address input and confirm button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Koordinat: ${_selectedLocation.latitude.toStringAsFixed(6)}, ${_selectedLocation.longitude.toStringAsFixed(6)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    hintText: 'Nama atau deskripsi lokasi (opsional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: const Icon(Icons.location_on),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _confirmLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667EEA),
                        ),
                        child: const Text(
                          'Pilih Lokasi',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

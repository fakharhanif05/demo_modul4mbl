import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'location_picker_widget.dart';

/// Widget untuk menampilkan dan mengedit lokasi customer dengan map picker
class LocationAddressInputWidget extends StatefulWidget {
  final String initialAddress;
  final double? initialLatitude;
  final double? initialLongitude;
  final Function(String address, double latitude, double longitude) onLocationChanged;
  final String label;
  final bool required;

  const LocationAddressInputWidget({
    super.key,
    required this.initialAddress,
    this.initialLatitude,
    this.initialLongitude,
    required this.onLocationChanged,
    this.label = 'Alamat Pelanggan',
    this.required = true,
  });

  @override
  State<LocationAddressInputWidget> createState() => _LocationAddressInputWidgetState();
}

class _LocationAddressInputWidgetState extends State<LocationAddressInputWidget> {
  late TextEditingController _addressController;
  late double _latitude;
  late double _longitude;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(text: widget.initialAddress);
    _latitude = widget.initialLatitude ?? -6.2088;
    _longitude = widget.initialLongitude ?? 106.8456;
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _showLocationPicker() {
    showDialog(
      context: context,
      builder: (context) => LocationPickerWidget(
        initialLocation: LatLng(_latitude, _longitude),
        title: 'Pilih Lokasi ${widget.label}',
        onLocationSelected: (location, address) {
          setState(() {
            _latitude = location.latitude;
            _longitude = location.longitude;
            _addressController.text = address;
          });
          widget.onLocationChanged(address, _latitude, _longitude);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _addressController,
          readOnly: true,
          decoration: InputDecoration(
            hintText: 'Tekan tombol di bawah untuk memilih lokasi',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            suffixIcon: const Icon(Icons.location_on),
            errorText: widget.required && _addressController.text.isEmpty
                ? 'Alamat tidak boleh kosong'
                : null,
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _showLocationPicker,
                icon: const Icon(Icons.map),
                label: const Text('Pilih di Peta'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667EEA),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            if (_latitude != 0.0 && _longitude != 0.0) ...[
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    border: Border.all(color: Colors.blue[200]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Koordinat:',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${_latitude.toStringAsFixed(4)}, ${_longitude.toStringAsFixed(4)}',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

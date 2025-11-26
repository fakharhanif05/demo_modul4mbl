/// File ini adalah contoh implementasi Location Integration
/// Dapat digunakan sebagai referensi untuk membuat form input customer dengan location picker
/// 
/// Letakkan di: lib/app/modules/services/controllers/services_controller.dart
/// (Update existing services_controller.dart dengan bagian-bagian ini)

// ============== TAMBAHAN DI services_controller.dart ==============

import 'package:latlong2/latlong.dart';
import '../../../data/services/location_invoice_integration.dart';

class ServicesController extends GetxController {
  // ... existing fields ...

  // Location fields untuk form input
  final customerLocationLat = Rxn<double>();
  final customerLocationLng = Rxn<double>();
  final customerLocationAddress = ''.obs;

  // Method untuk update lokasi customer
  void updateCustomerLocation(
    double latitude,
    double longitude,
    String address,
  ) {
    customerLocationLat.value = latitude;
    customerLocationLng.value = longitude;
    customerLocationAddress.value = address;
  }

  // Method untuk reset lokasi
  void resetCustomerLocation() {
    customerLocationLat.value = null;
    customerLocationLng.value = null;
    customerLocationAddress.value = '';
  }

  // Method untuk create invoice dengan lokasi
  Future<void> createInvoiceWithLocation({
    required String customerName,
    required String customerPhone,
    required String customerAddress,
    required List<InvoiceItem> items,
    required double subtotal,
    required double discount,
    required double total,
  }) async {
    try {
      final invoice = InvoiceModel(
        id: const Uuid().v4(),
        invoiceNumber: _generateInvoiceNumber(),
        customerName: customerName,
        customerPhone: customerPhone,
        customerAddress: customerAddress,
        items: items,
        subtotal: subtotal,
        discount: discount,
        total: total,
        status: 'pending',
        createdAt: DateTime.now(),
        customerLatitude: customerLocationLat.value,
        customerLongitude: customerLocationLng.value,
      );

      // Simpan ke Hive
      await HiveService.saveInvoice(invoice);

      // Reset form
      resetCustomerLocation();
      
      // Show success message
      Get.snackbar(
        'Sukses',
        'Invoice berhasil dibuat dengan lokasi customer',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal membuat invoice: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Method untuk validasi lokasi sebelum submit
  bool validateCustomerLocation() {
    if (customerLocationLat.value == null || customerLocationLng.value == null) {
      Get.snackbar(
        'Validasi',
        'Silakan pilih lokasi customer terlebih dahulu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
      );
      return false;
    }
    return true;
  }
}

// ============== CONTOH FORM INPUT DI services_view.dart ==============

/*
import '../../../core/widgets/location_address_input_widget.dart';

class ServicesView extends GetView<ServicesController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Data Antar Jemput'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Field nama customer
            TextField(
              decoration: InputDecoration(
                labelText: 'Nama Customer',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              controller: _nameController,
            ),
            const SizedBox(height: 16),

            // Field nomor telepon
            TextField(
              decoration: InputDecoration(
                labelText: 'Nomor Telepon',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.phone,
              controller: _phoneController,
            ),
            const SizedBox(height: 16),

            // Location Address Input Widget
            Obx(() => LocationAddressInputWidget(
              initialAddress: controller.customerLocationAddress.value,
              initialLatitude: controller.customerLocationLat.value,
              initialLongitude: controller.customerLocationLng.value,
              label: 'Lokasi Antar Jemput',
              required: true,
              onLocationChanged: (address, latitude, longitude) {
                controller.updateCustomerLocation(latitude, longitude, address);
              },
            )),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (controller.validateCustomerLocation()) {
                    controller.createInvoiceWithLocation(
                      customerName: _nameController.text,
                      customerPhone: _phoneController.text,
                      customerAddress: controller.customerLocationAddress.value,
                      items: [],
                      subtotal: 0,
                      discount: 0,
                      total: 0,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667EEA),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Simpan Data Customer',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/

// ============== CONTOH FILTER DI location_view.dart ==============

/*
// Tambahkan di LocationView untuk menampilkan list customer dengan lokasi
class LocationView extends GetView<LocationController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracking Antar Jemput'),
      ),
      body: Obx(() {
        return ListView.builder(
          itemCount: controller.customerInvoices.length,
          itemBuilder: (context, index) {
            final invoice = controller.customerInvoices[index];
            final location = LocationInvoiceIntegration.extractLocationFromInvoice(invoice);

            if (location == null) {
              return const SizedBox.shrink();
            }

            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                leading: Icon(
                  Icons.location_on,
                  color: _getStatusColor(invoice.status),
                ),
                title: Text(invoice.customerName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(location.address ?? ''),
                    Text(
                      'Koordinat: ${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.map),
                  onPressed: () {
                    // Navigate to map with marker
                    controller.focusLocation(location.toLatLng());
                  },
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      }),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.yellow;
      case 'process':
        return Colors.blue;
      case 'done':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
*/

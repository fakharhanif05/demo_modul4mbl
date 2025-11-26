# MIGRATION GUIDE: Menambah Lokasi ke Invoice Lama

Jika Anda sudah memiliki invoice yang tidak memiliki data lokasi, ikuti panduan ini untuk menambahkan lokasi ke invoice tersebut.

## 📌 Opsi 1: Manual Update (UI-based)

### Langkah 1: Buat Edit Screen untuk Invoice

```dart
class EditInvoiceLocationView extends StatefulWidget {
  final InvoiceModel invoice;

  const EditInvoiceLocationView({required this.invoice});

  @override
  State<EditInvoiceLocationView> createState() => _EditInvoiceLocationViewState();
}

class _EditInvoiceLocationViewState extends State<EditInvoiceLocationView> {
  late double latitude;
  late double longitude;
  late String address;

  @override
  void initState() {
    super.initState();
    latitude = widget.invoice.customerLatitude ?? 0;
    longitude = widget.invoice.customerLongitude ?? 0;
    address = widget.invoice.customerAddress;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Lokasi Invoice'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Invoice: ${widget.invoice.invoiceNumber}'),
            const SizedBox(height: 16),
            Text('Customer: ${widget.invoice.customerName}'),
            const SizedBox(height: 32),
            
            // Location picker
            LocationAddressInputWidget(
              initialAddress: address,
              initialLatitude: latitude,
              initialLongitude: longitude,
              label: 'Pilih Lokasi Customer',
              onLocationChanged: (newAddress, newLat, newLng) {
                setState(() {
                  address = newAddress;
                  latitude = newLat;
                  longitude = newLng;
                });
              },
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // Update invoice dengan lokasi baru
                  final updatedInvoice = LocationInvoiceIntegration.updateInvoiceLocation(
                    widget.invoice,
                    LatLng(latitude, longitude),
                    address,
                  );

                  // Simpan ke database
                  await HiveService.updateInvoice(updatedInvoice);
                  
                  Get.back();
                  Get.snackbar('Sukses', 'Lokasi invoice berhasil diupdate');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667EEA),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Simpan Lokasi',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Langkah 2: Tambah Edit Button di Invoice List

```dart
// Di invoice list view, tambahkan action button untuk edit lokasi
ListTile(
  title: Text(invoice.invoiceNumber),
  trailing: IconButton(
    icon: const Icon(Icons.location_on),
    onPressed: () {
      Get.to(() => EditInvoiceLocationView(invoice: invoice));
    },
  ),
)
```

## 📌 Opsi 2: Bulk Update (Programmatic)

Gunakan kode ini jika ingin update semua invoice sekaligus.

### Langkah 1: Buat Migration Service

```dart
class InvoiceMigrationService {
  /// Migrate semua invoice yang tidak memiliki lokasi
  /// dengan menggunakan default location (misalnya toko)
  static Future<void> migrateInvoicesToDefaultLocation({
    required double defaultLatitude,
    required double defaultLongitude,
    required String defaultLocationName,
  }) async {
    try {
      print('Starting invoice migration...');
      
      final allInvoices = HiveService.getAllInvoices();
      int migratedCount = 0;

      for (var invoice in allInvoices) {
        // Skip jika sudah punya lokasi
        if (LocationInvoiceIntegration.hasValidLocation(invoice)) {
          continue;
        }

        // Update dengan default location
        final updatedInvoice = LocationInvoiceIntegration.updateInvoiceLocation(
          invoice,
          LatLng(defaultLatitude, defaultLongitude),
          defaultLocationName,
        );

        await HiveService.updateInvoice(updatedInvoice);
        migratedCount++;
      }

      print('Migration completed. Updated: $migratedCount invoices');
      return migratedCount;
    } catch (e) {
      print('Migration error: $e');
      rethrow;
    }
  }

  /// Migrate invoice dengan menggunakan alamat untuk geocoding
  /// (Memerlukan geocoding service)
  static Future<void> migrateInvoicesWithGeocoding({
    required GeocodingService geocodingService,
  }) async {
    try {
      print('Starting geocoding migration...');
      
      final allInvoices = HiveService.getAllInvoices();
      int geocodedCount = 0;
      int failedCount = 0;

      for (var invoice in allInvoices) {
        // Skip jika sudah punya lokasi
        if (LocationInvoiceIntegration.hasValidLocation(invoice)) {
          continue;
        }

        try {
          // Geocode alamat customer
          final location = await geocodingService.getCoordinates(
            invoice.customerAddress,
          );

          if (location != null) {
            final updatedInvoice = LocationInvoiceIntegration.updateInvoiceLocation(
              invoice,
              location,
              invoice.customerAddress,
            );

            await HiveService.updateInvoice(updatedInvoice);
            geocodedCount++;
          } else {
            failedCount++;
          }
        } catch (e) {
          print('Failed to geocode ${invoice.customerName}: $e');
          failedCount++;
        }
      }

      print('Geocoding completed. Updated: $geocodedCount, Failed: $failedCount');
    } catch (e) {
      print('Geocoding migration error: $e');
      rethrow;
    }
  }
}
```

### Langkah 2: Panggil Migration Saat App Start (Opsional)

```dart
// Di main.dart atau App initialization
@override
void onInit() async {
  super.onInit();
  
  // Check apakah perlu migration
  final preferences = await SharedPreferences.getInstance();
  final isMigrated = preferences.getBool('invoice_location_migrated') ?? false;

  if (!isMigrated) {
    // Tampilkan dialog untuk migration
    _showMigrationDialog();
  }
}

void _showMigrationDialog() {
  Get.dialog(
    AlertDialog(
      title: const Text('Update Data Lokasi'),
      content: const Text(
        'Kami mendeteksi beberapa invoice lama yang belum memiliki data lokasi. '
        'Apakah Anda ingin mengupdate sekarang?'
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Nanti'),
        ),
        TextButton(
          onPressed: () async {
            Get.back();
            await _performMigration();
          },
          child: const Text('Update'),
        ),
      ],
    ),
  );
}

Future<void> _performMigration() async {
  // Option A: Migrate dengan default location
  await InvoiceMigrationService.migrateInvoicesToDefaultLocation(
    defaultLatitude: -6.2088,  // Koordinat toko/kantor
    defaultLongitude: 106.8456,
    defaultLocationName: 'Lokasi Default (Silakan update manual)',
  );

  // Option B: Migrate dengan geocoding (lebih akurat tapi lebih lambat)
  // await InvoiceMigrationService.migrateInvoicesWithGeocoding(
  //   geocodingService: GeocodingService(),
  // );

  final preferences = await SharedPreferences.getInstance();
  await preferences.setBool('invoice_location_migrated', true);

  Get.snackbar(
    'Sukses',
    'Data lokasi invoice berhasil diupdate',
    snackPosition: SnackPosition.BOTTOM,
  );
}
```

## 📌 Opsi 3: Import dari File CSV

Jika memiliki data lokasi dari source lain (misalnya Excel), Anda bisa import via CSV.

### Format CSV
```
invoice_number,customer_name,latitude,longitude,address
INV-001,Budi,-6.2088,106.8456,"Jl. Sudirman No. 123"
INV-002,Ani,-6.2089,106.8457,"Jl. Gatot Subroto No. 456"
```

### Kode Import

```dart
import 'package:csv/csv.dart';

class CsvImportService {
  static Future<void> importInvoiceLocationsFromCsv(String filePath) async {
    try {
      final file = File(filePath);
      final input = file.openRead();
      
      final fields = await input
          .transform(utf8.decoder)
          .transform(const CsvToListConverter())
          .toList();

      // Skip header
      for (int i = 1; i < fields.length; i++) {
        final row = fields[i];
        
        final invoiceNumber = row[0].toString();
        final latitude = double.parse(row[2].toString());
        final longitude = double.parse(row[3].toString());
        final address = row[4].toString();

        // Find invoice dan update
        final invoice = HiveService.getInvoiceByNumber(invoiceNumber);
        if (invoice != null) {
          final updatedInvoice = LocationInvoiceIntegration.updateInvoiceLocation(
            invoice,
            LatLng(latitude, longitude),
            address,
          );
          await HiveService.updateInvoice(updatedInvoice);
        }
      }

      print('CSV import completed successfully');
    } catch (e) {
      print('CSV import error: $e');
      rethrow;
    }
  }
}
```

## 🎯 REKOMENDASI

**Untuk Kasus Anda:**

1. **Jika invoice sedikit (<50)**: Gunakan **Opsi 1 (Manual)**
   - Buka satu-satu dan pilih lokasi di peta
   - Paling akurat karena manual

2. **Jika invoice banyak (50-500)**: Gunakan **Opsi 2A (Default Location)**
   - Update semua dengan default location toko/kantor
   - User bisa edit manual yang berbeda nanti

3. **Jika invoice banyak dengan alamat terstruktur**: Gunakan **Opsi 2B (Geocoding)**
   - Geocode semua alamat automatically
   - Perlu geocoding API (bisa offline dengan local database)

4. **Jika sudah punya data lokasi di sistem lain**: Gunakan **Opsi 3 (CSV Import)**
   - Export dari sistem lama
   - Import ke aplikasi ini

## ✅ VERIFIKASI SETELAH MIGRATION

Pastikan migration berhasil:

```dart
// Test di console
final allInvoices = HiveService.getAllInvoices();
final withLocation = allInvoices
    .where((inv) => LocationInvoiceIntegration.hasValidLocation(inv))
    .length;

print('Total invoice: ${allInvoices.length}');
print('Invoice dengan lokasi: $withLocation');
print('Invoice tanpa lokasi: ${allInvoices.length - withLocation}');
```

---

**Pilih opsi yang sesuai dengan kebutuhan Anda!**

# Integrasi Lokasi dengan Nota Layanan Antar Jemput

Dokumentasi ini menjelaskan cara menggunakan fitur location picker untuk menghubungkan nota layanan antar jemput dengan tracking lokasi customer.

## Komponen yang Dibuat

### 1. LocationPickerWidget (`lib/app/core/widgets/location_picker_widget.dart`)
Widget untuk memilih lokasi di peta secara interaktif.

**Fitur:**
- Menampilkan peta OpenStreetMap
- Click pada peta untuk memilih lokasi
- Tombol "Get Current Location" untuk mengambil lokasi GPS saat ini
- Input opsional untuk nama/deskripsi lokasi
- Menampilkan koordinat (latitude, longitude)

**Cara Menggunakan:**
```dart
showDialog(
  context: context,
  builder: (context) => LocationPickerWidget(
    initialLocation: LatLng(-6.2088, 106.8456), // Lokasi awal (opsional)
    title: 'Pilih Lokasi Customer',
    onLocationSelected: (location, address) {
      // location adalah LatLng
      // address adalah string
      print('Lokasi dipilih: ${location.latitude}, ${location.longitude}');
      print('Alamat: $address');
    },
  ),
);
```

### 2. LocationAddressInputWidget (`lib/app/core/widgets/location_address_input_widget.dart`)
Widget input alamat customer yang terintegrasi dengan location picker.

**Fitur:**
- TextField untuk menampilkan alamat yang sudah dipilih
- Tombol "Pilih di Peta" untuk membuka location picker
- Menampilkan koordinat lokasi
- Validasi input jika required

**Cara Menggunakan dalam Form:**
```dart
LocationAddressInputWidget(
  initialAddress: invoice.customerAddress,
  initialLatitude: invoice.customerLatitude,
  initialLongitude: invoice.customerLongitude,
  label: 'Alamat Pelanggan',
  required: true,
  onLocationChanged: (address, latitude, longitude) {
    // Update state dengan data lokasi baru
    invoice.customerAddress = address;
    invoice.customerLatitude = latitude;
    invoice.customerLongitude = longitude;
  },
)
```

### 3. LocationData Model (`lib/app/data/models/location_model.dart`)
Model untuk menyimpan data lokasi.

```dart
class LocationData {
  final double latitude;
  final double longitude;
  final String? address;
  final String? notes;
  // ... methods
}
```

### 4. LocationInvoiceIntegration Service (`lib/app/data/services/location_invoice_integration.dart`)
Service utility untuk integrasi lokasi dengan invoice.

**Method Utama:**

#### `updateInvoiceLocation()`
Update invoice dengan lokasi yang dipilih.
```dart
InvoiceModel updatedInvoice = LocationInvoiceIntegration.updateInvoiceLocation(
  invoice,
  LatLng(-6.2088, 106.8456),
  'Jl. Sudirman No. 123'
);
```

#### `extractLocationFromInvoice()`
Ambil data lokasi dari invoice.
```dart
LocationData? location = LocationInvoiceIntegration.extractLocationFromInvoice(invoice);
if (location != null) {
  print('Lokasi: ${location.latitude}, ${location.longitude}');
  print('Alamat: ${location.address}');
}
```

#### `hasValidLocation()`
Check apakah invoice memiliki lokasi yang valid.
```dart
bool hasLocation = LocationInvoiceIntegration.hasValidLocation(invoice);
```

#### `calculateDistance()`
Hitung jarak antar dua lokasi (dalam kilometer).
```dart
double distanceKm = LocationInvoiceIntegration.calculateDistance(
  LatLng(-6.2088, 106.8456),  // Dari
  LatLng(-6.2089, 106.8457)   // Ke
);
```

## Alur Implementasi

### 1. Input Customer dengan Location Picker

Di form input customer (misalnya di halaman invoice creation):

```dart
class InvoiceFormWidget extends StatefulWidget {
  @override
  State<InvoiceFormWidget> createState() => _InvoiceFormWidgetState();
}

class _InvoiceFormWidgetState extends State<InvoiceFormWidget> {
  late TextEditingController customerNameCtrl;
  late TextEditingController customerPhoneCtrl;
  String customerAddress = '';
  double? customerLatitude;
  double? customerLongitude;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: customerNameCtrl,
          decoration: const InputDecoration(labelText: 'Nama Customer'),
        ),
        TextField(
          controller: customerPhoneCtrl,
          decoration: const InputDecoration(labelText: 'No. Telepon'),
        ),
        // Gunakan LocationAddressInputWidget
        LocationAddressInputWidget(
          initialAddress: customerAddress,
          initialLatitude: customerLatitude,
          initialLongitude: customerLongitude,
          label: 'Alamat Pelanggan',
          required: true,
          onLocationChanged: (address, latitude, longitude) {
            setState(() {
              customerAddress = address;
              customerLatitude = latitude;
              customerLongitude = longitude;
            });
          },
        ),
        // ... tombol Submit
      ],
    );
  }

  void submitForm() {
    // Buat invoice dengan lokasi
    final invoice = InvoiceModel(
      // ... field lainnya
      customerAddress: customerAddress,
      customerLatitude: customerLatitude,
      customerLongitude: customerLongitude,
    );
    
    // Simpan ke database
    // ...
  }
}
```

### 2. Tampilkan Lokasi di Tracking View

Di LocationView untuk menampilkan lokasi dari invoice:

```dart
class LocationView extends GetView<LocationController> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: controller.invoices.length,
      itemBuilder: (context, index) {
        final invoice = controller.invoices[index];
        
        // Extract lokasi dari invoice
        final location = LocationInvoiceIntegration.extractLocationFromInvoice(invoice);
        
        if (location == null) {
          return const ListTile(
            title: Text('Tidak ada lokasi'),
          );
        }
        
        return Card(
          child: ListTile(
            leading: const Icon(Icons.location_on),
            title: Text(invoice.customerName),
            subtitle: Text(location.address ?? ''),
            trailing: IconButton(
              icon: const Icon(Icons.map),
              onPressed: () {
                // Navigate ke map view dengan marker lokasi ini
                controller.focusLocation(location);
              },
            ),
          ),
        );
      },
    );
  }
}
```

### 3. Gunakan Lokasi dalam Live Tracking

Update LocationController untuk menggunakan lokasi dari invoice:

```dart
class LocationController extends GetxController {
  RxList<InvoiceModel> customerLocations = <InvoiceModel>[].obs;

  void loadCustomerLocations() {
    // Load dari database
    final invoices = invoiceService.getAll();
    
    // Filter yang memiliki lokasi valid
    customerLocations.value = invoices
        .where((inv) => LocationInvoiceIntegration.hasValidLocation(inv))
        .toList();
    
    // Update markers di map
    _updateMapMarkers();
  }

  void _updateMapMarkers() {
    final markers = customerLocations.map((invoice) {
      final location = LocationInvoiceIntegration.extractLocationFromInvoice(invoice)!;
      
      return Marker(
        point: location.toLatLng(),
        width: 40,
        height: 40,
        child: Column(
          children: [
            Icon(
              Icons.location_on,
              color: _getStatusColor(invoice.status),
            ),
          ],
        ),
      );
    }).toList();
    
    // Update marker layer
    // mapMarkers.value = markers;
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
```

## Database Schema (Supabase)

Pastikan tabel `invoices` memiliki kolom:
```sql
ALTER TABLE invoices ADD COLUMN customer_latitude FLOAT;
ALTER TABLE invoices ADD COLUMN customer_longitude FLOAT;
```

Model InvoiceModel sudah memiliki field `customerLatitude` dan `customerLongitude`.

## Permission yang Diperlukan

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Aplikasi membutuhkan akses lokasi untuk tracking antar jemput</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Aplikasi membutuhkan akses lokasi untuk tracking antar jemput</string>
```

## Testing

Untuk testing location picker di emulator:

1. **Android Emulator:**
   - Buka Extended controls
   - Pergi ke Location
   - Set latitude dan longitude

2. **iOS Simulator:**
   - Features > Location > Custom Location
   - Input koordinat yang diinginkan

## Troubleshooting

### Location picker tidak muncul
- Pastikan dependencies sudah install: `flutter pub get`
- Pastikan `geolocator` dan `flutter_map` sudah di pubspec.yaml

### Permission denied
- Check izin di pengaturan device
- Untuk Android, minta permission saat runtime

### Marker tidak tampil di map
- Pastikan LatLng sudah valid (tidak 0,0)
- Check URL OpenStreetMap tidak diblock
- Lihat console untuk error message

## Referensi

- [geolocator package](https://pub.dev/packages/geolocator)
- [flutter_map package](https://pub.dev/packages/flutter_map)
- [latlong2 package](https://pub.dev/packages/latlong2)

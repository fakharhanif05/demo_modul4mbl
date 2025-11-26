# 🚀 QUICK START - EKSEKUSI LANGSUNG (5 MENIT)

> ⏱️ Jika Anda hanya punya 5 menit, ikuti ini!

## STEP 1: COPY KODE KE CONTROLLER (2 menit)

File: `lib/app/modules/services/controllers/services_controller.dart`

Tambahkan ke class `ServicesController`:

```dart
// Tambahkan import di paling atas:
import 'package:latlong2/latlong.dart';

// Tambahkan di dalam class ServicesController:

class ServicesController extends GetxController {
  // ... existing code ...

  // ===== TAMBAHKAN INI =====
  final customerLocationLat = Rxn<double>();
  final customerLocationLng = Rxn<double>();
  final customerLocationAddress = ''.obs;

  void updateCustomerLocation(double latitude, double longitude, String address) {
    customerLocationLat.value = latitude;
    customerLocationLng.value = longitude;
    customerLocationAddress.value = address;
  }

  void resetCustomerLocation() {
    customerLocationLat.value = null;
    customerLocationLng.value = null;
    customerLocationAddress.value = '';
  }

  bool validateCustomerLocation() {
    if (customerLocationLat.value == null || customerLocationLng.value == null) {
      Get.snackbar(
        'Validasi',
        'Silakan pilih lokasi customer terlebih dahulu',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    return true;
  }
  // ===== END TAMBAHAN =====
}
```

## STEP 2: UPDATE FORM VIEW (2 menit)

File: `lib/app/modules/services/views/services_view.dart`

Tambahkan import:
```dart
import '../../../core/widgets/location_address_input_widget.dart';
```

Tambahkan ke form (setelah field telephone):
```dart
const SizedBox(height: 16),

// ===== TAMBAHKAN INI =====
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
// ===== END TAMBAHAN =====

const SizedBox(height: 32),
```

Update tombol submit untuk validate lokasi:
```dart
ElevatedButton(
  onPressed: () {
    if (controller.validateCustomerLocation()) {
      // Submit form
      controller.createInvoice(); // atau method Anda
    }
  },
  child: const Text('Simpan Data'),
)
```

## STEP 3: TEST (1 menit)

```bash
# Run aplikasi
flutter run

# Test:
# 1. Buka Services/form input
# 2. Isi nama dan telepon
# 3. Klik "Pilih di Peta"
# 4. Pilih lokasi di peta atau klik "My Location"
# 5. Klik "Pilih Lokasi"
# 6. Verifikasi koordinat muncul
# 7. Klik Submit
```

## ✅ DONE!

Aplikasi Anda sekarang sudah punya location picker! 🎉

---

## 📚 UNTUK LEBIH LANJUT

Jika ingin memahami lebih dalam, baca:

1. **README_LOCATION_INTEGRATION.md** (10 min)
   - Overview & struktur file

2. **VISUAL_GUIDE_LOCATION.md** (15 min)
   - Lihat diagram alurnya

3. **DOKUMENTASI_LOCATION_INTEGRATION.md** (30 min)
   - Penjelasan detail setiap komponen

4. **CONTOH_IMPLEMENTASI_LOCATION.md**
   - More code examples

---

**Selesai! Aplikasi Anda sudah bisa tracking lokasi customer! 🚀**

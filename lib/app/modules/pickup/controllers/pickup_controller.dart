import 'package:get/get.dart';
import '../../../data/services/supabase_service.dart';
import '../../../data/models/invoice_model.dart';

class PickupController extends GetxController {
  var pickups = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPickups();
  }

  void loadPickups() {
    isLoading.value = true;
    Future.microtask(() async {
      try {
        final List<InvoiceModel> invoices = await SupabaseService.getPickups();

        pickups.value = invoices.map((inv) {
          final weight = inv.items.isNotEmpty ? inv.items.fold<double>(0.0, (p, e) => p + e.quantity) : 0.0;
          int color;
          if (inv.status == 'done') {
            color = 0xFF51CF66;
          } else if (inv.status == 'process') {
            color = 0xFF667EEA;
          } else {
            color = 0xFF4ECDC4;
          }

          return {
            'id': inv.invoiceNumber.isNotEmpty ? inv.invoiceNumber : inv.id,
            'customer': inv.customerName,
            'address': inv.customerAddress,
            'phone': inv.customerPhone,
            'date': inv.pickupDate != null ? inv.pickupDate!.toLocal().toString().split(' ').first : inv.createdAt.toLocal().toString().split(' ').first,
            'time': inv.pickupDate != null ? '${inv.pickupDate!.toLocal().hour.toString().padLeft(2, '0')}:00' : '-',
            'status': inv.status,
            'weight': '${weight.toStringAsFixed(1)} kg',
            'color': color,
          };
        }).toList();
      } catch (e) {
        pickups.value = [];
      } finally {
        isLoading.value = false;
      }
    });
  }

  void completePickup(String id) {
    Future.microtask(() async {
      try {
        await SupabaseService.completePickup(id);
        Get.snackbar('Sukses', 'Pengambilan $id berhasil ditandai selesai');
        refreshPickups();
      } catch (e) {
        Get.snackbar('Gagal', 'Tidak dapat menandai selesai: $e');
      }
    });
  }

  void refreshPickups() {
    loadPickups();
  }
}

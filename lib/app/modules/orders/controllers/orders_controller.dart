import 'package:get/get.dart';
import '../../../data/services/supabase_service.dart';
import '../../../data/models/invoice_model.dart';

class OrdersController extends GetxController {
  var orders = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    try {
      isLoading.value = true;
      final List<InvoiceModel> invoices = await SupabaseService.getOrders();

      // map invoices to simple order maps used by the UI
      orders.value = invoices.map((inv) {
        final weight = inv.items.isNotEmpty
            ? inv.items.fold<double>(0.0, (p, e) => p + e.quantity)
            : 0.0;
        final service = inv.items.isNotEmpty ? inv.items.first.serviceName : '-';

        int color;
        switch (inv.status) {
          case 'process':
            color = 0xFF667EEA;
            break;
          case 'done':
            color = 0xFF51CF66;
            break;
          case 'pending':
          default:
            color = 0xFF4ECDC4;
        }

        return {
          'id': inv.invoiceNumber.isNotEmpty ? inv.invoiceNumber : inv.id,
          'color': color,
          'status': inv.status,
          'customer': inv.customerName,
          'weight': '${weight.toStringAsFixed(1)} kg',
          'service': service,
          'date': inv.pickupDate != null ? inv.pickupDate!.toLocal().toString().split(' ').first : inv.createdAt.toLocal().toString().split(' ').first,
          'total': 'Rp ${inv.total.toStringAsFixed(0)}',
        };
      }).toList();
    } catch (e) {
      orders.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  void refreshOrders() {
    loadOrders();
  }
}

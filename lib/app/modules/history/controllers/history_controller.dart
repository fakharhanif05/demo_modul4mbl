// ============ modules/history/controllers/history_controller.dart ============
import 'package:get/get.dart';
import '../../../data/models/invoice_model.dart';
import '../../../data/services/hive_service.dart';

class HistoryController extends GetxController {
  final invoices = <InvoiceModel>[].obs;
  final filteredInvoices = <InvoiceModel>[].obs;
  final isLoading = false.obs;
  final selectedFilter = 'all'.obs; // all, pending, process, done
  
  @override
  void onInit() {
    super.onInit();
    loadInvoices();
  }

  void loadInvoices() {
    isLoading.value = true;
    
    try {
      final allInvoices = HiveService.getAllInvoices();
      allInvoices.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      invoices.value = allInvoices;
      filterInvoices();
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat riwayat: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void filterInvoices() {
    if (selectedFilter.value == 'all') {
      filteredInvoices.value = invoices;
    } else {
      filteredInvoices.value = invoices.where(
        (invoice) => invoice.status == selectedFilter.value,
      ).toList();
    }
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    filterInvoices();
  }
}
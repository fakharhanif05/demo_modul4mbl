import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/invoice_model.dart';
import '../../../data/services/hive_service.dart';
import '../../../data/services/supabase_service.dart';
import '../../../data/services/shared_prefs_service.dart';

class HistoryController extends GetxController {
  final invoices = <InvoiceModel>[].obs;
  final filteredInvoices = <InvoiceModel>[].obs;
  final isLoading = false.obs;
  final selectedFilter = 'all'.obs; // all, pending, process, done
  
  @override
  void onInit() {
    super.onInit();
    loadInvoices();
    // Auto fetch from cloud when screen opens
    fetchFromCloud();
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

  Future<void> fetchFromCloud() async {
    // Skip if guest mode
    if (SharedPrefsService.isGuestMode) return;
    if (!SupabaseService.isLoggedIn) return;

    try {
      print('🔄 Fetching invoices from cloud...');
      final cloudInvoices = await SupabaseService.getInvoices();
      print('✓ Fetched ${cloudInvoices.length} invoices from cloud');

      // Save to local (loop each invoice)
      for (var invoice in cloudInvoices) {
        invoice.isSynced = true;
        await HiveService.saveInvoice(invoice);
      }

      // Reload from local
      loadInvoices();
      print('✓ Local data updated');
    } on PostgrestException catch (e) {
      print('⚠️ PostgrestException: ${e.message}');
    } catch (e) {
      print('⚠️ Failed to fetch from cloud: $e');
      // Don't show error to user, just use local data
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
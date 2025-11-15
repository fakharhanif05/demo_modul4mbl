// ============ modules/home/controllers/home_controller.dart ============
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/services/hive_service.dart';
import '../../../data/services/supabase_service.dart';
import '../../../data/services/shared_prefs_service.dart';

class HomeController extends GetxController {
  final todayTransactions = 0.obs;
  final todayRevenue = 0.0.obs;
  final isSyncing = false.obs;
  final isGuestMode = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    isGuestMode.value = SharedPrefsService.isGuestMode;
    loadDashboardData();
  }

  void loadDashboardData() {
    final invoices = HiveService.getAllInvoices();
    final today = DateTime.now();
    
    final todayInvoices = invoices.where((invoice) {
      return invoice.createdAt.year == today.year &&
          invoice.createdAt.month == today.month &&
          invoice.createdAt.day == today.day;
    }).toList();
    
    todayTransactions.value = todayInvoices.length;
    todayRevenue.value = todayInvoices.fold(0.0, (sum, invoice) => sum + invoice.total);
  }

  Future<void> syncData() async {
    if (isGuestMode.value) {
      Get.snackbar(
        'Guest Mode',
        'Login terlebih dahulu untuk sync data',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isSyncing.value = true;
      
      // Sync unsynced invoices to cloud
      final unsyncedInvoices = HiveService.getUnsyncedInvoices();
      await SupabaseService.syncInvoices(unsyncedInvoices);
      
      // Mark as synced
      for (var invoice in unsyncedInvoices) {
        invoice.isSynced = true;
        await HiveService.saveInvoice(invoice);
      }
      
      await SharedPrefsService.setLastSyncTime(DateTime.now());
      
      Get.snackbar(
        'Berhasil',
        'Data berhasil disinkronkan ke cloud',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      loadDashboardData();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal sync data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSyncing.value = false;
    }
  }

  String get lastSyncTimeText {
    final lastSync = SharedPrefsService.lastSyncTime;
    if (lastSync == null) return 'Belum pernah sync';
    
    final formatter = DateFormat('dd MMM yyyy, HH:mm');
    return formatter.format(lastSync);
  }
}
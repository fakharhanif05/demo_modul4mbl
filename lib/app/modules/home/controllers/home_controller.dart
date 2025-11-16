import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/services/hive_service.dart';
import '../../../data/services/supabase_service.dart';
import '../../../data/services/shared_prefs_service.dart';
import '../../../data/models/invoice_model.dart';

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
    
    // Auto sync on app start if logged in
    if (!isGuestMode.value && SupabaseService.isLoggedIn) {
      autoSyncFromCloud();
    }
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

  Future<void> autoSyncFromCloud() async {
    try {
      print('🔄 Auto syncing from cloud...');
      final cloudInvoices = await SupabaseService.getInvoices();
      
      // Save to local
      for (var invoice in cloudInvoices) {
        invoice.isSynced = true;
        await HiveService.saveInvoice(invoice);
      }
      
      // Reload dashboard
      loadDashboardData();
      print('✓ Auto sync completed: ${cloudInvoices.length} invoices');
    } catch (e) {
      print('⚠️ Auto sync failed: $e');
      // Silent fail, don't disturb user
    }
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

    if (!SupabaseService.isLoggedIn) {
      Get.snackbar(
        'Error',
        'Anda belum login',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isSyncing.value = true;
      
      print('=== SYNC DATA START ===');
      print('Guest Mode: ${isGuestMode.value}');
      print('Is Logged In: ${SupabaseService.isLoggedIn}');
      print('User ID: ${SupabaseService.currentUser?.id}');
      print('User Email: ${SupabaseService.currentUser?.email}');
      
      // 1. Upload unsynced invoices to cloud
      print('\n1️⃣ Uploading unsynced invoices...');
      final unsyncedInvoices = HiveService.getUnsyncedInvoices();
      print('Found ${unsyncedInvoices.length} unsynced invoices');
      
      if (unsyncedInvoices.isNotEmpty) {
        await SupabaseService.syncInvoices(unsyncedInvoices);
        
        // Mark as synced
        for (var invoice in unsyncedInvoices) {
          invoice.isSynced = true;
          await HiveService.saveInvoice(invoice);
        }
        print('✓ Uploaded ${unsyncedInvoices.length} invoices');
      }
      
      // 2. Download all invoices from cloud
      print('\n2️⃣ Downloading invoices from cloud...');
      final cloudInvoices = await SupabaseService.getInvoices();
      print('✓ Downloaded ${cloudInvoices.length} invoices');
      
      // 3. Save to local
      print('\n3️⃣ Saving to local storage...');
      for (var invoice in cloudInvoices) {
        invoice.isSynced = true;
        await HiveService.saveInvoice(invoice);
      }
      print('✓ Saved ${cloudInvoices.length} invoices to Hive');
      
      // 4. Update last sync time
      await SharedPrefsService.setLastSyncTime(DateTime.now());
      
      // 5. Reload dashboard
      loadDashboardData();
      
      print('\n=== SYNC DATA COMPLETE ===');
      print('Total synced: ${cloudInvoices.length} invoices\n');
      
      Get.snackbar(
        'Berhasil',
        'Data berhasil disinkronkan (${cloudInvoices.length} nota)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on PostgrestException catch (e) {
      print('\n❌ PostgrestException during sync:');
      print('Message: ${e.message}');
      print('Code: ${e.code}');
      print('Details: ${e.details}');
      
      Get.snackbar(
        'Error Sync',
        'Gagal sync: ${e.message}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      print('\n❌ Error during sync: $e');
      
      Get.snackbar(
        'Error',
        'Gagal sync data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
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
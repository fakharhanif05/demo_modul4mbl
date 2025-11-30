// ============ modules/settings/controllers/settings_controller.dart ============
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/shared_prefs_service.dart';
import '../../../data/services/hive_service.dart';

class SettingsController extends GetxController {
  final isDarkMode = false.obs;
  final isGuestMode = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = SharedPrefsService.isDarkMode;
    isGuestMode.value = SharedPrefsService.isGuestMode;
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    SharedPrefsService.setDarkMode(isDarkMode.value);
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    
    Get.snackbar(
      'Theme',
      'Theme changed to ${isDarkMode.value ? "Dark" : "Light"} mode',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> clearAllData() async {
    Get.dialog(
      AlertDialog(
        title: const Text('Hapus Semua Data'),
        content: const Text(
          'PERINGATAN: Ini akan menghapus semua data lokal termasuk nota dan cache. Data yang sudah tersync ke cloud tetap aman. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              
              try {
                await HiveService.clearAll();
                
                Get.snackbar(
                  'Berhasil',
                  'Semua data lokal berhasil dihapus',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Gagal menghapus data: ${e.toString()}',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
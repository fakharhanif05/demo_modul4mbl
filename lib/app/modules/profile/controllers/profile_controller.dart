import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/shared_prefs_service.dart';
import '../../../data/services/supabase_service.dart';
import '../../../routes/app_routes.dart';
import '../../../core/utils/navigation_utils.dart';

class ProfileController extends GetxController {
  final userEmail = ''.obs;
  final isGuestMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  void loadUserData() {
    isGuestMode.value = SharedPrefsService.isGuestMode;
    if (!isGuestMode.value) {
      userEmail.value = SupabaseService.currentUser?.email ?? 'Tidak diketahui';
    } else {
      userEmail.value = 'Guest Mode';
    }
  }

  Future<void> logout() async {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();

              if (!isGuestMode.value) {
                // Putuskan session Supabase agar token auth dibersihkan
                await SupabaseService.signOut();
              }

              await SharedPrefsService.setGuestMode(false);
              NavigationUtils.safeOffAllNamed(Routes.LOGIN);

              Get.snackbar(
                'Logout',
                'Berhasil logout',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

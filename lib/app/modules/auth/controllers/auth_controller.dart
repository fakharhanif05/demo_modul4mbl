// ============ controllers/auth_controller.dart ============
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/supabase_service.dart';
import '../../../data/services/shared_prefs_service.dart';
import '../../../routes/app_routes.dart';
import '../../../core/utils/navigation_utils.dart';

class AuthController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  final isLoading = false.obs;
  final isPasswordHidden = true.obs;
  final isLoginMode = true.obs;

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  void checkAuthStatus() {
    // Jika session Supabase masih aktif, langsung masuk ke beranda
    if (SupabaseService.isLoggedIn && !SharedPrefsService.isGuestMode) {
      debugPrint('[AuthController] checkAuthStatus -> navigating to ROOT');
      NavigationUtils.safeOffAllNamed(Routes.ROOT);
    }
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleMode() {
    isLoginMode.value = !isLoginMode.value;
    emailController.clear();
    passwordController.clear();
  }

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Email dan password tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      
      // Pakai Supabase Auth untuk verifikasi email & password
      final user = await SupabaseService.signIn(
        emailController.text.trim(),
        passwordController.text,
      );

      if (user != null) {
        await SharedPrefsService.setGuestMode(false);
        debugPrint('[AuthController] login successful -> navigating to ROOT for ${user.email}');
        NavigationUtils.safeOffAllNamed(Routes.ROOT);
        Get.snackbar(
          'Berhasil',
          'Login berhasil! Selamat datang ${user.email}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Login gagal: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Email dan password tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (passwordController.text.length < 6) {
      Get.snackbar(
        'Error',
        'Password minimal 6 karakter',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      
      // Registrasi akun baru via Supabase Auth
      final user = await SupabaseService.signUp(
        emailController.text.trim(),
        passwordController.text,
      );

      if (user != null) {
        Get.snackbar(
          'Berhasil',
          'Registrasi berhasil! Silakan login',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        toggleMode();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Registrasi gagal: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> continueAsGuest() async {
    await SharedPrefsService.setGuestMode(true);
    debugPrint('[AuthController] continueAsGuest -> navigating to ROOT');
    NavigationUtils.safeOffAllNamed(Routes.ROOT);
    Get.snackbar(
      'Guest Mode',
      'Anda masuk sebagai guest. Data tidak akan tersinkronisasi ke cloud',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
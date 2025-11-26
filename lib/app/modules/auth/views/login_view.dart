// ============ views/login_view.dart ============
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.08,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          
                          // Logo
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.local_laundry_service,
                              size: 50,
                              color: Color(0xFF667EEA),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          Obx(() => Text(
                            controller.isLoginMode.value ? 'Obral Laundry' : 'Daftar Akun',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )),
                          
                          const SizedBox(height: 10),
                          
                          Obx(() => Text(
                            controller.isLoginMode.value 
                                ? 'Masuk untuk mengelola laundry Anda' 
                                : 'Buat akun baru untuk memulai',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            textAlign: TextAlign.center,
                          )),
                          
                          const SizedBox(height: 40),
                          
                          // Form Card
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Email Field
                                TextField(
                                  controller: controller.emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: Icon(Icons.email),
                                  ),
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Password Field
                                Obx(() => TextField(
                                  controller: controller.passwordController,
                                  obscureText: controller.isPasswordHidden.value,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: const Icon(Icons.lock),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        controller.isPasswordHidden.value
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                      onPressed: controller.togglePasswordVisibility,
                                    ),
                                  ),
                                )),
                                
                                const SizedBox(height: 24),
                                
                                // Login/Register Button
                                Obx(() => SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: controller.isLoading.value
                                        ? null
                                        : () {
                                            if (controller.isLoginMode.value) {
                                              controller.login();
                                            } else {
                                              controller.register();
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF667EEA),
                                      foregroundColor: Colors.white,
                                    ),
                                    child: controller.isLoading.value
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            controller.isLoginMode.value ? 'Login' : 'Daftar',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                )),
                                
                                const SizedBox(height: 16),
                                
                                // Toggle Mode
                                Obx(() => TextButton(
                                  onPressed: controller.toggleMode,
                                  child: Text(
                                    controller.isLoginMode.value
                                        ? 'Belum punya akun? Daftar'
                                        : 'Sudah punya akun? Login',
                                    style: const TextStyle(
                                      color: Color(0xFF667EEA),
                                    ),
                                  ),
                                )),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Guest Mode Button
                          Obx(() => SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : controller.continueAsGuest,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white, width: 2),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text(
                                'Lanjut sebagai Guest',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )),
                          
                          const SizedBox(height: 16),
                          
                          Text(
                            'Mode Guest: Data hanya tersimpan lokal',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
// ============ modules/settings/views/settings_view.dart ============
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../../../data/services/supabase_service.dart';
import '../../../data/services/shared_prefs_service.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Account Info
                  if (!controller.isGuestMode.value) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFF667EEA).withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 32,
                                color: Color(0xFF667EEA),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Logged In',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Tampilkan email dari session Supabase aktif
                                  Text(
                                    SupabaseService.currentUser?.email ?? 'Unknown',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  if (controller.isGuestMode.value) ...[
                    Card(
                      color: Colors.orange.shade50,
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.info, color: Colors.orange),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Guest Mode',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Data hanya tersimpan lokal dan tidak tersinkronisasi',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Appearance Section
                  const Text(
                    'Tampilan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Obx(() => SwitchListTile(
                      title: const Text('Dark Mode'),
                      subtitle: const Text('Ubah tema aplikasi'),
                      value: controller.isDarkMode.value,
                      onChanged: (_) => controller.toggleTheme(),
                      secondary: Icon(
                        controller.isDarkMode.value ? Icons.dark_mode : Icons.light_mode,
                        color: const Color(0xFF667EEA),
                      ),
                    )),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Data Section
                  const Text(
                    'Data',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.sync, color: Color(0xFF667EEA)),
                          title: const Text('Terakhir Sync'),
                          subtitle: Text(SharedPrefsService.lastSyncTime != null
                              ? SharedPrefsService.lastSyncTime.toString()
                              : 'Belum pernah sync'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.delete_forever, color: Colors.red),
                          title: const Text('Hapus Semua Data Lokal'),
                          subtitle: const Text('Data cloud tetap aman'),
                          onTap: controller.clearAllData,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // About Section
                  const Text(
                    'Tentang',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.info, color: Color(0xFF667EEA)),
                          title: Text('Versi Aplikasi'),
                          subtitle: Text('1.0.0'),
                        ),
                        Divider(height: 1),
                        ListTile(
                          leading: Icon(Icons.description, color: Color(0xFF667EEA)),
                          title: Text('Lisensi'),
                          subtitle: Text('MIT License'),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: controller.logout,
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Credits
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Built with ❤️ using Flutter',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'GetX • Supabase • Hive',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
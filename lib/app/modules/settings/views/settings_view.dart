// ============ modules/settings/views/settings_view.dart ============
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
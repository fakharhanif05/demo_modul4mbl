import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../../../routes/app_routes.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF667EEA).withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: Color(0xFF667EEA),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Obral Laundry',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'admin@obrallaundy.com',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Menu Items
              _buildMenuTile(
                icon: Icons.person_outline,
                title: 'Data Profil',
                subtitle: 'Edit informasi profil Anda',
                onTap: () {
                  Get.snackbar('Info', 'Fitur edit profil segera hadir');
                },
              ),
              _buildMenuTile(
                icon: Icons.lock_outline,
                title: 'Ubah Password',
                subtitle: 'Ganti password akun Anda',
                onTap: () {
                  Get.snackbar('Info', 'Fitur ubah password segera hadir');
                },
              ),
              _buildMenuTile(
                icon: Icons.notifications_outlined,
                title: 'Notifikasi',
                subtitle: 'Kelola preferensi notifikasi',
                onTap: () {
                  Get.snackbar('Info', 'Fitur notifikasi segera hadir');
                },
              ),
              _buildMenuTile(
                icon: Icons.help_outline,
                title: 'Bantuan & Dukungan',
                subtitle: 'Hubungi tim support kami',
                onTap: () {
                  Get.snackbar('Info', 'Fitur bantuan segera hadir');
                },
              ),
              _buildMenuTile(
                icon: Icons.info_outline,
                title: 'Tentang Aplikasi',
                subtitle: 'Versi dan informasi aplikasi',
                onTap: () {
                  Get.snackbar('Info', 'Aplikasi Obral Laundry v1.0');
                },
              ),
              const SizedBox(height: 24),
              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.defaultDialog(
                      title: 'Logout',
                      middleText: 'Apakah Anda yakin ingin keluar?',
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Batal'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Get.offAllNamed(Routes.LOGIN);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Logout'),
                        ),
                      ],
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          icon,
          color: const Color(0xFF667EEA),
        ),
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

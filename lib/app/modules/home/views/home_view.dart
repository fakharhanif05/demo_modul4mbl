// ============ modules/home/views/home_view.dart ============
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/home_controller.dart';
import '../../../routes/app_routes.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Obral Laundry'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return RefreshIndicator(
            onRefresh: () async {
              controller.loadDashboardData();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statistics Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF667EEA).withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '📊 Statistik Hari Ini',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Transaksi',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.9),
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Obx(() => Text(
                                      controller.todayTransactions.value.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pendapatan',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.9),
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Obx(() => Text(
                                      currencyFormatter.format(controller.todayRevenue.value),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    const Text(
                      'Menu Utama',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Menu Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      // make cards slightly taller so long titles can wrap
                      childAspectRatio: 0.95,
                      children: [
                        _buildMenuCard(
                          icon: Icons.note_add,
                          title: 'Buat Nota',
                          color: const Color(0xFF667EEA),
                          onTap: () => Get.toNamed(Routes.INVOICE_CREATE),
                        ),
                        _buildMenuCard(
                          icon: Icons.local_shipping,
                          title: 'Tracking Antar Jemput',
                          color: const Color(0xFFFFB84D),
                          onTap: () => Get.toNamed(Routes.LOCATION),
                        ),
                        _buildMenuCard(
                          icon: Icons.settings,
                          title: 'Pengaturan',
                          color: const Color(0xFFFF6B6B),
                          onTap: () => Get.toNamed(Routes.SETTINGS),
                        ),
                        _buildMenuCard(
                          icon: Icons.list_alt,
                          title: 'Daftar Pesanan',
                          color: const Color(0xFF4ECDC4),
                          onTap: () => Get.toNamed(Routes.ORDERS),
                        ),
                        _buildMenuCard(
                          icon: Icons.bar_chart,
                          title: 'Laporan Keuangan',
                          color: const Color(0xFF51CF66),
                          onTap: () => Get.toNamed(Routes.REPORTS),
                        ),
                        _buildMenuCard(
                          icon: Icons.local_shipping,
                          title: 'Pengambilan',
                          color: const Color(0xFFFFB84D),
                          onTap: () => Get.toNamed(Routes.PICKUP),
                                              ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Sync Button
                    Obx(() => SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: controller.isSyncing.value 
                            ? null 
                            : controller.syncData,
                        icon: controller.isSyncing.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.sync),
                        label: Text(
                          controller.isSyncing.value 
                              ? 'Syncing...' 
                              : 'Sync Data',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667EEA),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    )),
                    
                    const SizedBox(height: 8),
                    
                    Obx(() => Center(
                      child: Text(
                        controller.isGuestMode.value
                            ? 'Guest Mode: Login untuk sync data'
                            : 'Terakhir sync: ${controller.lastSyncTimeText}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
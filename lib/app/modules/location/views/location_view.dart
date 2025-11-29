import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/invoice_model.dart';
import '../controllers/location_controller.dart';

class LocationView extends GetView<LocationController> {
  const LocationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracking Antar Jemput'),
        actions: [
          Obx(() {
            final isTracking = controller.isLiveTracking.value;
            return IconButton(
              icon: Icon(isTracking ? Icons.pause : Icons.play_arrow),
              tooltip: isTracking ? 'Hentikan live tracking' : 'Mulai live tracking',
              onPressed: () {
                if (isTracking) {
                  controller.stopLiveTracking();
                } else {
                  controller.startLiveTracking();
                }
              },
            );
          }),
          IconButton(
            icon: const Icon(Icons.local_shipping),
            tooltip: 'Refresh data antar jemput',
            onPressed: () {
              controller.loadCustomerLocations();
              controller.fetchGpsFix();
              controller.fetchNetworkFix();
            },
          ),
        ],
      ),
      body: Obx(() {
        return RefreshIndicator(
          onRefresh: () async {
            controller.loadCustomerLocations();
            await controller.startLiveTracking();
            await controller.fetchGpsFix();
            await controller.fetchNetworkFix();
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              _buildAntarJemputHeader(),
              const SizedBox(height: 16),
              _buildStatusFilter(),
              const SizedBox(height: 16),
              _buildMapCard(),
              const SizedBox(height: 16),
              _buildOrderListCard(),
              const SizedBox(height: 16),
              _buildGpsVsNetworkCard(),           
              if (controller.locationError.value.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildErrorCard(context),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildAntarJemputHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_shipping,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Layanan Antar Jemput',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Track lokasi customer untuk jemput & antar',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: controller.fetchGpsFix,
                  icon: const Icon(Icons.satellite, size: 18),
                  label: const Text('GPS Fix', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: controller.fetchNetworkFix,
                  icon: const Icon(Icons.cell_tower, size: 18),
                  label: const Text('Network Fix', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatChip(
                  icon: Icons.pending_actions,
                  label: 'Perlu Jemput',
                  value: controller.pendingPickupCount.toString(),
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatChip(
                  icon: Icons.local_shipping,
                  label: 'Sedang Diantar',
                  value: controller.inDeliveryCount.toString(),
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Obx(() => Row(
      children: [
        Expanded(
          child: _buildFilterChip(
            label: 'Perlu Jemput',
            status: 'pending',
            icon: Icons.pending_actions,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildFilterChip(
            label: 'Sedang Diantar',
            status: 'process',
            icon: Icons.local_shipping,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildFilterChip(
            label: 'Selesai',
            status: 'done',
            icon: Icons.check_circle,
            color: Colors.green,
          ),
        ),
      ],
    ));
  }

  Widget _buildFilterChip({
    required String label,
    required String status,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = controller.filterStatus.value == status;
    return InkWell(
      onTap: () => controller.setFilterStatus(status),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : color,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (isSelected)
              Text(
                '(${controller.customerInvoices.length})',
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderListCard() {
    return Obx(() {
      if (controller.customerInvoices.isEmpty) {
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 12),
                Text(
                  'Tidak ada order ${controller.filterStatusLabel.toLowerCase()}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Order dengan lokasi akan muncul di sini',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.list_alt, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Daftar Order ${controller.filterStatusLabel} (${controller.customerInvoices.length})',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...controller.customerInvoices.map((invoice) {
                final distance = controller.getDistanceToCustomer(invoice);
                final isSelected = controller.selectedInvoiceId.value == invoice.id;
                return _buildOrderItem(invoice, distance, isSelected);
              }),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildOrderItem(InvoiceModel invoice, double? distance, bool isSelected) {
    Color statusColor;
    IconData statusIcon;
    switch (invoice.status) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending_actions;
        break;
      case 'process':
        statusColor = Colors.blue;
        statusIcon = Icons.local_shipping;
        break;
      case 'done':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    return InkWell(
      onTap: () => controller.selectInvoice(isSelected ? null : invoice.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(statusIcon, color: statusColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          invoice.customerName,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? AppTheme.primaryColor : Colors.black87,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          invoice.status.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    invoice.customerAddress,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (distance != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.navigation, size: 14, color: AppTheme.secondaryColor),
                        const SizedBox(width: 4),
                        Text(
                          'Jarak: ${(distance / 1000).toStringAsFixed(2)} km',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppTheme.secondaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppTheme.primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildMapCard() {
    final position = controller.currentPosition.value;
    final center = controller.mapCenter.value;

    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: FlutterMap(
          mapController: controller.mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: controller.mapZoom.value,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.laundry.app',
            ),
            if (position != null) ...[
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: LatLng(position.latitude, position.longitude),
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    borderStrokeWidth: 1,
                    borderColor: AppTheme.primaryColor,
                    radius: position.accuracy,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  // Marker lokasi saat ini
                  Marker(
                    point: LatLng(position.latitude, position.longitude),
                    width: 60,
                    height: 60,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.my_location, color: Colors.white, size: 24),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Text(
                            'Anda',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Marker lokasi customer untuk antar jemput
                  ...controller.customerInvoices.map((invoice) {
                    if (invoice.customerLatitude == null || invoice.customerLongitude == null) {
                      return null;
                    }
                    final distance = controller.getDistanceToCustomer(invoice);
                    // Tentukan warna berdasarkan status
                    Color markerColor;
                    IconData markerIcon;
                    switch (invoice.status) {
                      case 'pending':
                        markerColor = Colors.orange;
                        markerIcon = Icons.pending_actions;
                        break;
                      case 'process':
                        markerColor = Colors.blue;
                        markerIcon = Icons.local_shipping;
                        break;
                      case 'done':
                        markerColor = Colors.green;
                        markerIcon = Icons.check_circle;
                        break;
                      default:
                        markerColor = Colors.grey;
                        markerIcon = Icons.local_laundry_service;
                    }
                    
                    return Marker(
                      point: LatLng(invoice.customerLatitude!, invoice.customerLongitude!),
                      width: 90,
                      height: 90,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: markerColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: markerColor.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(markerIcon, color: Colors.white, size: 24),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  invoice.customerName,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (distance != null)
                                  Text(
                                    '${(distance / 1000).toStringAsFixed(1)} km',
                                    style: GoogleFonts.poppins(
                                      fontSize: 9,
                                      color: markerColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).whereType<Marker>(),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Perlu perhatian',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.locationError.value,
              style: const TextStyle(color: Colors.redAccent),
              softWrap: true,
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: controller.openLocationSettings,
                    icon: const Icon(Icons.settings, size: 18),
                    label: const Text('Pengaturan', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: controller.openAppSettings,
                    icon: const Icon(Icons.app_settings_alt, size: 18),
                    label: const Text('Izin Aplikasi', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGpsVsNetworkCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple.shade50, Colors.pink.shade50],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Perbandingan GPS vs Network Location (Real-time)',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.purple.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap tombol GPS/Network di atas untuk membandingkan akurasi & kecepatan',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            // GPS Location Section - Dynamic
            Obx(() => _buildProviderCard(
              title: 'GPS Location',
              icon: Icons.satellite,
              backgroundColor: Colors.amber.shade50,
              borderColor: Colors.amber.shade300,
              iconBackgroundColor: Colors.amber.shade200,
              iconColor: Colors.amber,
              position: controller.gpsPosition.value,
              isLoading: controller.isGpsLoading.value,
              duration: controller.gpsFixDuration.value,
            )),
            const SizedBox(height: 12),
            // Network Location Section - Dynamic
            Obx(() => _buildProviderCard(
              title: 'Network Location',
              icon: Icons.cell_tower,
              backgroundColor: Colors.blue.shade50,
              borderColor: Colors.blue.shade300,
              iconBackgroundColor: Colors.blue.shade200,
              iconColor: Colors.blue,
              position: controller.networkPosition.value,
              isLoading: controller.isNetworkLoading.value,
              duration: controller.networkFixDuration.value,
            )),
            const SizedBox(height: 12),
            // Comparison Analysis Section
            Obx(() {
              final gps = controller.gpsPosition.value;
              final network = controller.networkPosition.value;
              final gpsLoading = controller.isGpsLoading.value;
              final networkLoading = controller.isNetworkLoading.value;
              
              if ((gps == null && network == null) && !gpsLoading && !networkLoading) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade300, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tap salah satu tombol untuk mulai perbandingan',
                          style: TextStyle(fontSize: 11, color: Colors.orange.shade700),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (gpsLoading || networkLoading) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade300, width: 1),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.blue.shade600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Sedang menganalisis...',
                          style: TextStyle(fontSize: 11, color: Colors.blue.shade700, fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (gps != null && network != null) {
                final distanceDiff = (gps.accuracy - network.accuracy).abs();
                final isBetter = gps.accuracy < network.accuracy;
                
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.teal.shade300, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.compare, color: Colors.teal, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '✓ Analisis Perbandingan Selesai',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.teal.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildComparisonAnalysis(
                        'Perbedaan Akurasi',
                        '${distanceDiff.toStringAsFixed(1)}m',
                        isBetter ? '🏆 GPS lebih akurat' : '🏆 Network lebih akurat',
                      ),
                      const SizedBox(height: 6),
                      _buildComparisonAnalysis(
                        'GPS Accuracy',
                        '${gps.accuracy.toStringAsFixed(1)}m',
                        'vs Network ${network.accuracy.toStringAsFixed(1)}m',
                      ),
                      const SizedBox(height: 6),
                      _buildComparisonAnalysis(
                        'Rekomendasi',
                        isBetter ? 'Gunakan GPS' : 'Gunakan Network',
                        'untuk hasil terbaik',
                      ),
                    ],
                  ),
                );
              }

              if (gps != null && network == null) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade300, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'GPS sudah tersedia, tap Network Fix untuk perbandingan lengkap',
                          style: TextStyle(fontSize: 11, color: Colors.amber.shade700),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (network != null && gps == null) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade300, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Network sudah tersedia, tap GPS Fix untuk perbandingan lengkap',
                          style: TextStyle(fontSize: 11, color: Colors.amber.shade700),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderCard({
    required String title,
    required IconData icon,
    required Color backgroundColor,
    required Color borderColor,
    required Color iconBackgroundColor,
    required Color iconColor,
    required Position? position,
    required bool isLoading,
    required Duration? duration,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: iconColor,
                  ),
                ),
              ),
              if (isLoading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(iconColor),
                  ),
                )
              else if (position != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'AKTIF',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (isLoading)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(iconColor),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sedang mencari lokasi...',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            )
          else
            _buildProviderInfo(
              provider: title,
              position: position,
              color: iconColor,
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildComparisonAnalysis(String label, String value, String info) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
          info,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontStyle: FontStyle.italic),
        ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.teal),
        ),
      ],
    );
  }

  Widget _buildProviderInfo({
    required String provider,
    required Position? position,
    required Color color,
  }) {
    if (position == null) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Status: Belum mendapatkan fix (Tekan tombol untuk ambil lokasi)',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
          softWrap: true,
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Lat: ${position.latitude.toStringAsFixed(6)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'AKTIF',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Lon: ${position.longitude.toStringAsFixed(6)}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
            ),
            maxLines: 2,
            softWrap: true,
          ),
          const SizedBox(height: 4),
          Text(
            'Akurasi: ${position.accuracy.toStringAsFixed(1)}m | Waktu: ${DateFormat('HH:mm:ss').format(position.timestamp)}',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            maxLines: 2,
            softWrap: true,
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonDetail(String label, String value, String icon) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                value,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
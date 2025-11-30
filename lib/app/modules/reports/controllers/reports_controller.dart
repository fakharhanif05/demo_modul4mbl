import 'package:get/get.dart';
import '../../../data/services/hive_service.dart';
import '../../../data/models/invoice_model.dart';
import 'package:intl/intl.dart' as intl;

class ReportsController extends GetxController with GetSingleTickerProviderStateMixin {
  var selectedPeriod = 'Hari Ini'.obs;
  var totalRevenue = 0.0.obs;
  var totalOrders = 0.obs;
  var averageOrderValue = 0.0.obs;
  var isLoading = false.obs;
  var revenueData = <Map<String, dynamic>>[].obs;
  var maxRevenueInChart = 1.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadReportData(); // Panggil di sini agar data langsung dimuat saat pertama kali dibuka.
  }


  void loadReportData() {
    isLoading.value = true;
    try {
      final now = DateTime.now();
      late DateTime from;
      late DateTime to;

      if (selectedPeriod.value == 'Hari Ini') {
        from = DateTime(now.year, now.month, now.day, 0, 0, 0);
        to = DateTime(now.year, now.month, now.day, 23, 59, 59);
      } else if (selectedPeriod.value == 'Minggu Ini') {
        // Minggu dimulai dari hari Senin (weekday 1), Minggu (weekday 7)
        final weekday = now.weekday;
        final startOfWeek = now.subtract(Duration(days: weekday - 1));
        from = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day, 0, 0, 0);
        to = from.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
      } else {
        // Bulan Ini
        from = DateTime(now.year, now.month, 1, 0, 0, 0);
        to = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      }

      // Mengambil semua nota dari penyimpanan lokal (Hive)
      final allInvoices = HiveService.getAllInvoices();

      // Filter nota berdasarkan periode yang dipilih
      final filteredInvoices = allInvoices.where((inv) {
        final createdAt = inv.createdAt;
        if (selectedPeriod.value == 'Hari Ini') {
          return createdAt.year == now.year &&
              createdAt.month == now.month &&
              createdAt.day == now.day;
        } else if (selectedPeriod.value == 'Minggu Ini') {
          return createdAt.isAfter(from.subtract(const Duration(microseconds: 1))) && createdAt.isBefore(to.add(const Duration(microseconds: 1)));
        } else { // Bulan Ini
          return createdAt.year == now.year && createdAt.month == now.month;
        }
      }).toList();

      final double total = filteredInvoices.fold(0.0, (sum, item) => sum + item.total);

      totalRevenue.value = total;
      totalOrders.value = filteredInvoices.length;
      averageOrderValue.value = filteredInvoices.isNotEmpty ? (total / filteredInvoices.length) : 0.0;

      // Build simple revenueData: group by day (label)
      final Map<String, double> grouped = {};
      final dayOrder = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
      final isThisMonth = selectedPeriod.value == 'Bulan Ini';
      final formatter = isThisMonth ? intl.DateFormat('d MMM', 'id_ID') : intl.DateFormat.E('id_ID');

      for (var inv in filteredInvoices) {
        final dayLabel = formatter.format(inv.createdAt.toLocal());
        grouped[dayLabel] = (grouped[dayLabel] ?? 0.0) + inv.total;
      }

      // Untuk periode mingguan, pastikan semua hari ada di chart dan urut
      if (selectedPeriod.value == 'Minggu Ini') {
        for (int i = 0; i < 7; i++) {
          final day = from.add(Duration(days: i));
          final dayLabel = intl.DateFormat.E('id_ID').format(day);
          grouped.putIfAbsent(dayLabel, () => 0.0);
        }
        // Urutkan map berdasarkan urutan hari
        final sortedEntries = grouped.entries.toList()
          ..sort((a, b) => dayOrder.indexOf(a.key).compareTo(dayOrder.indexOf(b.key)));
        
        revenueData.value = sortedEntries.map((e) => {'day': e.key, 'amount': e.value.toInt()}).toList();
      } else {
        // Untuk periode lain, urutkan berdasarkan kunci (tanggal/hari)
        revenueData.value = grouped.entries.map((e) => {'day': e.key, 'amount': e.value.toInt()}).toList();
      }

      // Calculate max revenue for chart normalization
      double maxAmount = 0;
      if (revenueData.isNotEmpty) {
        maxAmount = revenueData
            .map((d) => d['amount'] as num)
            .reduce((a, b) => a > b ? a : b)
            .toDouble();
      }
      maxRevenueInChart.value = maxAmount > 0 ? maxAmount : 1.0;
      
    } catch (e) {
      // Set to 0 on error
      totalRevenue.value = 0;
      totalOrders.value = 0;
      averageOrderValue.value = 0;
      revenueData.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  void changePeriod(String period) {
    selectedPeriod.value = period;
    loadReportData();
  }
}

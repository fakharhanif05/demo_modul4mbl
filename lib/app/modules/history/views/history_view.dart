// ============ modules/history/views/history_view.dart ============
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/history_controller.dart';
import '../../../routes/app_routes.dart';

class HistoryView extends GetView<HistoryController> {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormatter = DateFormat('dd MMM yyyy, HH:mm');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('History Nota'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              // Filter Chips
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.04,
                  vertical: 12,
                ),
                child: Obx(() => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Semua', 'all', controller.selectedFilter.value),
                      const SizedBox(width: 8),
                      _buildFilterChip('Pending', 'pending', controller.selectedFilter.value),
                      const SizedBox(width: 8),
                      _buildFilterChip('Proses', 'process', controller.selectedFilter.value),
                      const SizedBox(width: 8),
                      _buildFilterChip('Selesai', 'done', controller.selectedFilter.value),
                    ],
                  ),
                )),
              ),
              
              // Invoice List
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value && controller.invoices.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.filteredInvoices.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            controller.selectedFilter.value == 'all'
                                ? 'Belum ada nota'
                                : 'Tidak ada nota ${controller.selectedFilter.value}',
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      controller.loadInvoices();
                    },
                    child: ListView.builder(
                      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                      itemCount: controller.filteredInvoices.length,
                      itemBuilder: (context, index) {
                        final invoice = controller.filteredInvoices[index];
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () {
                              Get.toNamed(Routes.INVOICE_DETAIL, arguments: invoice)
                                  ?.then((_) => controller.loadInvoices());
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          invoice.invoiceNumber,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          invoice.customerName,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          dateFormatter.format(invoice.createdAt),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        currencyFormatter.format(invoice.total),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF667EEA),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(invoice.status),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          invoice.status.toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (!invoice.isSynced) ...[
                                        const SizedBox(height: 4),
                                        const Icon(
                                          Icons.cloud_off,
                                          size: 16,
                                          color: Colors.orange,
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, String selectedValue) {
    final isSelected = value == selectedValue;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => controller.setFilter(value),
      backgroundColor: Colors.grey[200],
      selectedColor: const Color(0xFF667EEA),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'done':
        return Colors.green;
      case 'process':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
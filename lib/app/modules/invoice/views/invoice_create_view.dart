// ============ modules/invoice/views/invoice_create_view.dart ============
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/invoice_controller.dart';
import '../../../data/models/service_model.dart';
import '../../../data/models/invoice_model.dart';
import '../../../core/widgets/location_address_input_widget.dart';

class InvoiceCreateView extends GetView<InvoiceController> {
  const InvoiceCreateView({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Nota Baru'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer Data Section
                  const Text(
                    'Data Customer',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller.customerNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Customer',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller.customerPhoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'No. Telepon',
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller.customerAddressController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Alamat',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Location Picker untuk Tracking Antar Jemput
                  Obx(() => LocationAddressInputWidget(
                    initialAddress: controller.customerLocationAddress.value,
                    initialLatitude: controller.customerLocationLat.value,
                    initialLongitude: controller.customerLocationLng.value,
                    onLocationChanged: (address, latitude, longitude) {
                      controller.updateCustomerLocation(latitude, longitude, address);
                    },
                    label: 'Lokasi Antar Jemput (GPS)',
                  )),
                  
                  const SizedBox(height: 24),
                  
                  // Status & Pickup Date
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() => DropdownButtonFormField<String>(
                          initialValue: controller.selectedStatus.value,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            prefixIcon: Icon(Icons.flag),
                          ),
                          items: ['pending', 'process', 'done'].map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(status.toUpperCase()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              controller.selectedStatus.value = value;
                            }
                          },
                        )),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(() => InkWell(
                          onTap: controller.selectPickupDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Tanggal Ambil',
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              controller.pickupDate.value != null
                                  ? DateFormat('dd MMM yyyy').format(controller.pickupDate.value!)
                                  : 'Pilih tanggal',
                              style: TextStyle(
                                color: controller.pickupDate.value != null 
                                    ? null 
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        )),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Services Section
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Layanan Dipilih',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 80),
                        child: ElevatedButton.icon(
                          onPressed: () => _showAddServiceDialog(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Tambah'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF667EEA),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Obx(() {
                    if (controller.selectedServices.isEmpty) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.inbox, size: 48, color: Colors.grey[400]),
                                const SizedBox(height: 8),
                                Text(
                                  'Belum ada layanan dipilih',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: List.generate(
                        controller.selectedServices.length,
                        (index) {
                          final item = controller.selectedServices[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.serviceName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${currencyFormatter.format(item.pricePerKg)} × ${item.quantity} kg',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          currencyFormatter.format(item.totalPrice),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF667EEA),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _showEditQuantityDialog(context, index, item),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => controller.removeService(index),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                  
                  const SizedBox(height: 24),
                  
                  // Summary Section
                  Card(
                    color: Colors.grey[100],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Obx(() => _buildSummaryRow(
                            'Subtotal:',
                            currencyFormatter.format(controller.subtotal.value),
                          )),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text('Diskon:', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: controller.discountController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: '0',
                                    prefixText: 'Rp ',
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Obx(() => _buildSummaryRow(
                            'TOTAL:',
                            currencyFormatter.format(controller.total.value),
                            isTotal: true,
                          )),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Save Button
                  Obx(() => SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: controller.isSaving.value 
                          ? null 
                          : controller.saveInvoice,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF667EEA),
                        foregroundColor: Colors.white,
                      ),
                      child: controller.isSaving.value
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Simpan Nota',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: FontWeight.bold,
            color: isTotal ? const Color(0xFF667EEA) : null,
          ),
        ),
      ],
    );
  }

  void _showAddServiceDialog(BuildContext context) {
    final quantityController = TextEditingController(text: '1');
    final selectedService = Rxn<ServiceModel>();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tambah Layanan',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Obx(() => DropdownButtonFormField<ServiceModel>(
                hint: const Text('Pilih Layanan'),
                initialValue: selectedService.value,
                decoration: const InputDecoration(
                  labelText: 'Layanan',
                  prefixIcon: Icon(Icons.local_laundry_service),
                ),
                items: controller.availableServices.map((service) {
                  return DropdownMenuItem(
                    value: service,
                    child: Text(service.title),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedService.value = value;
                },
              )),
              const SizedBox(height: 16),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah (kg)',
                  prefixIcon: Icon(Icons.scale),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (selectedService.value != null) {
                        final quantity = double.tryParse(quantityController.text) ?? 0;
                        controller.addService(selectedService.value!, quantity);
                        Get.back();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667EEA),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Tambah'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditQuantityDialog(BuildContext context, int index, InvoiceItem item) {
    final quantityController = TextEditingController(text: item.quantity.toString());

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit ${item.serviceName}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah (kg)',
                  prefixIcon: Icon(Icons.scale),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final quantity = double.tryParse(quantityController.text) ?? 0;
                      controller.updateServiceQuantity(index, quantity);
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667EEA),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Update'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
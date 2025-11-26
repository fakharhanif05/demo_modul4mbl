import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../controllers/services_controller.dart';
import '../../../data/models/service_model.dart';

class ServicesView extends GetView<ServicesController> {
  const ServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Layanan'),
        actions: [
          Obx(() => IconButton(
            icon: Icon(controller.useHttpProvider.value ? Icons.http : Icons.webhook),
            onPressed: controller.toggleProvider,
            tooltip: controller.useHttpProvider.value ? 'Using HTTP' : 'Using Dio',
          )),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadServices,
          ),
        ],
      ),
      body: _buildServicesTab(context, currencyFormatter),
    );
  }

  Widget _buildServicesTab(BuildContext context, NumberFormat currencyFormatter) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Obx(() {
          if (controller.isLoading.value && controller.services.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.services.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada layanan',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: controller.loadServices,
                    child: const Text('Muat Ulang'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.loadServices,
            child: ListView.builder(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
              itemCount: controller.services.length,
              itemBuilder: (context, index) {
                final service = controller.services[index];
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      _showServiceDetail(context, service, currencyFormatter);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: service.image,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  service.description,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${currencyFormatter.format(service.price)} / kg',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF667EEA),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        });
      },
    );
  }

  void _showServiceDetail(BuildContext context, ServiceModel service, NumberFormat formatter) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: CachedNetworkImage(
                  imageUrl: service.image,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      service.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF667EEA).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Harga per kg:',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            formatter.format(service.price),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF667EEA),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667EEA),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Tutup'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

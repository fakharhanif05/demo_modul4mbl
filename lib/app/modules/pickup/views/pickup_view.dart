import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pickup_controller.dart';

class PickupView extends GetView<PickupController> {
  const PickupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengambilan (Pickup)'),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.pickups.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.local_shipping, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text('Tidak ada jadwal pengambilan', style: TextStyle(fontSize: 16)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => controller.refreshPickups(),
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: controller.pickups.length,
            itemBuilder: (context, index) {
              final pickup = controller.pickups[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            pickup['id'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Color(pickup['color']).withValues(alpha: 0.1),
                              border: Border.all(color: Color(pickup['color'])),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              pickup['status'],
                              style: TextStyle(
                                color: Color(pickup['color']),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        pickup['customer'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.grey),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              pickup['address'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 16, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            pickup['phone'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${pickup['date']} ${pickup['time']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Berat: ${pickup['weight']}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          if (pickup['status'] != 'Selesai')
                            ElevatedButton.icon(
                              onPressed: () {
                                controller.completePickup(pickup['id']);
                              },
                              icon: const Icon(Icons.check, size: 16),
                              label: const Text('Selesai'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF51CF66),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

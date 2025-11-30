import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../home/controllers/home_controller.dart';
import '../reports/controllers/reports_controller.dart';
import '../orders/controllers/orders_controller.dart';
import '../pickup/controllers/pickup_controller.dart';

class RootController extends GetxController {
  var selectedIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('[RootController] onInit');
  }

  void changeTab(int index) {
    selectedIndex.value = index;
    debugPrint('[RootController] changeTab -> $index');

    // Pemicu refresh untuk halaman yang datanya mungkin berubah
    switch (index) {
      case 0: // Index untuk Home
        if (Get.isRegistered<HomeController>()) Get.find<HomeController>().loadDashboardData();
        break;
      case 1: // Index untuk History/Orders
        if (Get.isRegistered<OrdersController>()) Get.find<OrdersController>().refreshOrders();
        break;
      case 2: // Index untuk Services/Pickup (sesuaikan jika berbeda)
        // Jika menu Pickup ada di tab lain, sesuaikan index-nya
        if (Get.isRegistered<PickupController>()) Get.find<PickupController>().refreshPickups();
        break;
      case 3: // Index untuk Profile/Reports (sesuaikan jika berbeda)
        if (Get.isRegistered<ReportsController>()) Get.find<ReportsController>().loadReportData();
        break;
    }
  }
}

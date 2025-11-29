import 'package:get/get.dart';
import 'root_controller.dart';
import '../home/bindings/home_binding.dart';
import '../history/bindings/history_binding.dart';
import '../services/bindings/services_binding.dart';
import '../profile/bindings/profile_binding.dart';

class RootBinding extends Bindings {
  @override
  void dependencies() {
    // Root controller for managing bottom navigation
    Get.lazyPut<RootController>(() => RootController());

    // Initialize child module controllers so embedded pages can find them
    HomeBinding().dependencies();
    HistoryBinding().dependencies();
    ServicesBinding().dependencies();
    ProfileBinding().dependencies();
  }
}

// ============ modules/services/controllers/services_controller.dart ============
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../../../data/models/service_model.dart';
import '../../../data/providers/service_provider_http.dart';
import '../../../data/providers/service_provider_dio.dart';
import '../../../data/services/hive_service.dart';

class ServicesController extends GetxController {
  final services = <ServiceModel>[].obs;
  final isLoading = false.obs;
  final useHttpProvider = true.obs; // true = HTTP, false = Dio
  
  final serviceProviderHttp = ServiceProviderHttp();
  final serviceProviderDio = ServiceProviderDio();

  @override
  void onInit() {
    super.onInit();
    loadServices();
  }

  Future<void> loadServices() async {
    try {
      isLoading.value = true;
      
      // Try to load from cache first
      final cachedServices = HiveService.getServices();
      if (cachedServices.isNotEmpty) {
        services.value = cachedServices;
      }
      
      // Fetch from API
      final fetchedServices = useHttpProvider.value
          ? await serviceProviderHttp.getServices()
          : await serviceProviderDio.getServices();
      
      services.value = fetchedServices;
      
      // Save to cache
      await HiveService.saveServices(fetchedServices);
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat layanan: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      // Use cached data if available
      final cachedServices = HiveService.getServices();
      if (cachedServices.isNotEmpty) {
        services.value = cachedServices;
        Get.snackbar(
          'Offline',
          'Menampilkan data dari cache',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void toggleProvider() {
    useHttpProvider.value = !useHttpProvider.value;
    loadServices();
    
    Get.snackbar(
      'Provider Changed',
      'Menggunakan ${useHttpProvider.value ? "HTTP" : "Dio"} provider',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

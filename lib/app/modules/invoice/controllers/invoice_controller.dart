// ============ modules/invoice/controllers/invoice_controller.dart ============
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../../data/models/invoice_model.dart';
import '../../../data/models/service_model.dart';
import '../../../data/services/hive_service.dart';
import '../../../data/services/supabase_service.dart';
import '../../../data/services/shared_prefs_service.dart';

class InvoiceController extends GetxController {
  // Form Controllers
  final customerNameController = TextEditingController();
  final customerPhoneController = TextEditingController();
  final customerAddressController = TextEditingController();
  final discountController = TextEditingController(text: '0');

  // Services
  final availableServices = <ServiceModel>[].obs;
  final selectedServices = <InvoiceItem>[].obs;

  // Invoice Data
  final subtotal = 0.0.obs;
  final discount = 0.0.obs;
  final total = 0.0.obs;
  final selectedStatus = 'pending'.obs;
  final pickupDate = Rxn<DateTime>();

  // Location Data untuk Tracking Antar Jemput
  final customerLocationLat = Rxn<double>();
  final customerLocationLng = Rxn<double>();
  final customerLocationAddress = ''.obs;

  // UI State
  final isLoading = false.obs;
  final isSaving = false.obs;

  // For Edit Mode
  InvoiceModel? editingInvoice;

  @override
  void onInit() {
    super.onInit();
    loadServices();
    
    // Listen to discount changes
    discountController.addListener(() {
      final value = double.tryParse(discountController.text) ?? 0;
      discount.value = value;
      calculateTotal();
    });

    // Check if editing
    if (Get.arguments != null && Get.arguments is InvoiceModel) {
      editingInvoice = Get.arguments as InvoiceModel;
      loadInvoiceForEdit(editingInvoice!);
    }
  }

  void loadServices() {
    availableServices.value = HiveService.getServices();
  }

  void loadInvoiceForEdit(InvoiceModel invoice) {
    customerNameController.text = invoice.customerName;
    customerPhoneController.text = invoice.customerPhone;
    customerAddressController.text = invoice.customerAddress;
    discountController.text = invoice.discount.toString();
    selectedStatus.value = invoice.status;
    pickupDate.value = invoice.pickupDate;
    selectedServices.value = List.from(invoice.items);
    
    // Load location data jika ada
    if (invoice.customerLatitude != null && invoice.customerLongitude != null) {
      customerLocationLat.value = invoice.customerLatitude;
      customerLocationLng.value = invoice.customerLongitude;
    }
    
    calculateTotal();
  }

  void addService(ServiceModel service, double quantity) {
    if (quantity <= 0) {
      Get.snackbar('Error', 'Jumlah harus lebih dari 0');
      return;
    }

    final existingIndex = selectedServices.indexWhere(
      (item) => item.serviceId == service.id,
    );

    final totalPrice = service.price * quantity;

    if (existingIndex != -1) {
      selectedServices[existingIndex] = InvoiceItem(
        serviceId: service.id,
        serviceName: service.title,
        pricePerKg: service.price,
        quantity: quantity,
        totalPrice: totalPrice,
      );
    } else {
      selectedServices.add(InvoiceItem(
        serviceId: service.id,
        serviceName: service.title,
        pricePerKg: service.price,
        quantity: quantity,
        totalPrice: totalPrice,
      ));
    }

    calculateTotal();
  }

  void removeService(int index) {
    selectedServices.removeAt(index);
    calculateTotal();
  }

  void updateServiceQuantity(int index, double quantity) {
    if (quantity <= 0) {
      removeService(index);
      return;
    }

    final item = selectedServices[index];
    selectedServices[index] = InvoiceItem(
      serviceId: item.serviceId,
      serviceName: item.serviceName,
      pricePerKg: item.pricePerKg,
      quantity: quantity,
      totalPrice: item.pricePerKg * quantity,
    );

    calculateTotal();
  }

  void calculateTotal() {
    subtotal.value = selectedServices.fold(
      0.0,
      (sum, item) => sum + item.totalPrice,
    );
    total.value = subtotal.value - discount.value;
    if (total.value < 0) total.value = 0;
  }

  String generateInvoiceNumber() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyyMMdd');
    final dateStr = formatter.format(now);
    final random = DateTime.now().millisecondsSinceEpoch % 1000;
    return 'INV-$dateStr-${random.toString().padLeft(3, '0')}';
  }
  
  Future<void> saveInvoice() async {
    // Validation
    if (customerNameController.text.isEmpty) {
      Get.snackbar('Error', 'Nama customer tidak boleh kosong');
      return;
    }

    if (customerPhoneController.text.isEmpty) {
      Get.snackbar('Error', 'Nomor telepon tidak boleh kosong');
      return;
    }

    if (selectedServices.isEmpty) {
      Get.snackbar('Error', 'Pilih minimal 1 layanan');
      return;
    }

    try {
      isSaving.value = true;

      const uuid = Uuid();
      final isGuestMode = SharedPrefsService.isGuestMode;
      final isEditMode = editingInvoice != null;

      final invoice = InvoiceModel(
        id: editingInvoice?.id ?? uuid.v4(),
        invoiceNumber: editingInvoice?.invoiceNumber ?? generateInvoiceNumber(),
        customerName: customerNameController.text.trim(),
        customerPhone: customerPhoneController.text.trim(),
        customerAddress: customerAddressController.text.trim(),
        items: List.from(selectedServices),
        subtotal: subtotal.value,
        discount: discount.value,
        total: total.value,
        status: selectedStatus.value,
        createdAt: editingInvoice?.createdAt ?? DateTime.now(),
        pickupDate: pickupDate.value,
        // Location untuk tracking antar jemput
        customerLatitude: customerLocationLat.value,
        customerLongitude: customerLocationLng.value,
        // Simpan userId Supabase agar nota terhubung dengan akun di cloud
        userId: isGuestMode ? null : SupabaseService.currentUser?.id,
        isSynced: false,
      );

      // Save to local first
      await HiveService.saveInvoice(invoice);
      print('✓ Saved to Hive');

      // Jika bukan guest, cerminkan perubahan ke Supabase
      if (!isGuestMode && SupabaseService.isLoggedIn) {
        try {
          if (isEditMode) {
            print('🔄 Updating to cloud...');
            await SupabaseService.updateInvoice(invoice.id, invoice);
            print('✓ Updated to cloud');
          } else {
            print('🔄 Creating in cloud...');
            // Kirim nota baru ke tabel `invoices` Supabase
            await SupabaseService.createInvoice(invoice);
            print('✓ Created in cloud');
          }
          
          // Mark as synced
          invoice.isSynced = true;
          await HiveService.saveInvoice(invoice);
        } catch (e) {
          print('⚠️ Cloud sync failed: $e');
          // Continue anyway, data is saved locally
          Get.snackbar(
            'Warning',
            'Saved locally, but cloud sync failed. Will retry on manual sync.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }
      }

      Get.back();
      Get.snackbar(
        'Berhasil',
        isEditMode ? 'Nota berhasil diupdate' : 'Nota berhasil dibuat',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error saving invoice: $e');
      Get.snackbar(
        'Error',
        'Gagal menyimpan nota: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteInvoice(String id) async {
    try {
      final isGuestMode = SharedPrefsService.isGuestMode;
      
      // Delete from local
      await HiveService.deleteInvoice(id);
      print('✓ Deleted from Hive');

      // Hapus juga di Supabase supaya data antar device konsisten
      if (!isGuestMode && SupabaseService.isLoggedIn) {
        try {
          print('🔄 Deleting from cloud...');
          await SupabaseService.deleteInvoice(id);
          print('✓ Deleted from cloud');
        } catch (e) {
          print('⚠️ Cloud delete failed: $e');
          // Continue anyway
        }
      }

      Get.back();
      Get.snackbar(
        'Berhasil',
        'Nota berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error deleting invoice: $e');
      Get.snackbar(
        'Error',
        'Gagal menghapus nota: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void selectPickupDate() async {
    final date = await Get.dialog<DateTime>(
      DatePickerDialog(
        initialDate: pickupDate.value ?? DateTime.now().add(const Duration(days: 1)),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      ),
    );

    if (date != null) {
      pickupDate.value = date;
    }
  }

  // Location Methods untuk Tracking Antar Jemput
  void updateCustomerLocation(double latitude, double longitude, String address) {
    customerLocationLat.value = latitude;
    customerLocationLng.value = longitude;
    customerLocationAddress.value = address;
  }

  void resetCustomerLocation() {
    customerLocationLat.value = null;
    customerLocationLng.value = null;
    customerLocationAddress.value = '';
  }

  bool validateCustomerLocation() {
    return customerLocationLat.value != null && 
           customerLocationLng.value != null && 
           customerLocationAddress.value.isNotEmpty;
  }

  @override
  void onClose() {
    customerNameController.dispose();
    customerPhoneController.dispose();
    customerAddressController.dispose();
    discountController.dispose();
    super.onClose();
  }
}
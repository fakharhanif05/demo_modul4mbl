// ============ hive_service.dart ============
import 'package:hive_flutter/hive_flutter.dart';
import '../models/service_model.dart';
import '../models/invoice_model.dart';

class HiveService {
  static const String servicesBox = 'services';
  static const String invoicesBox = 'invoices';

  static Future<void> init() async {
    // Register Adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ServiceModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(InvoiceModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(InvoiceItemAdapter());
    }

    // Open Boxes
    await Hive.openBox<ServiceModel>(servicesBox);
    await Hive.openBox<InvoiceModel>(invoicesBox);
  }

  // Services
  static Box<ServiceModel> get servicesBoxInstance => 
      Hive.box<ServiceModel>(servicesBox);

  static Future<void> saveServices(List<ServiceModel> services) async {
    final box = servicesBoxInstance;
    await box.clear();
    for (var service in services) {
      await box.put(service.id, service);
    }
  }

  static List<ServiceModel> getServices() {
    return servicesBoxInstance.values.toList();
  }

  // Invoices
  static Box<InvoiceModel> get invoicesBoxInstance => 
      Hive.box<InvoiceModel>(invoicesBox);

  static Future<void> saveInvoice(InvoiceModel invoice) async {
    final box = invoicesBoxInstance;
    await box.put(invoice.id, invoice);
  }

  static Future<void> deleteInvoice(String id) async {
    final box = invoicesBoxInstance;
    await box.delete(id);
  }

  static InvoiceModel? getInvoice(String id) {
    return invoicesBoxInstance.get(id);
  }

  static List<InvoiceModel> getAllInvoices() {
    return invoicesBoxInstance.values.toList();
  }

  static List<InvoiceModel> getUnsyncedInvoices() {
    return invoicesBoxInstance.values.where((inv) => !inv.isSynced).toList();
  }

  static Future<void> clearAll() async {
    await servicesBoxInstance.clear();
    await invoicesBoxInstance.clear();
  }
}
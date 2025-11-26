import 'package:latlong2/latlong.dart';
import '../models/invoice_model.dart';
import '../models/location_model.dart';

/// Utility class untuk integrasi lokasi dan invoice
class LocationInvoiceIntegration {
  /// Update invoice dengan lokasi
  static InvoiceModel updateInvoiceLocation(
    InvoiceModel invoice,
    LatLng location,
    String? address,
  ) {
    return InvoiceModel(
      id: invoice.id,
      invoiceNumber: invoice.invoiceNumber,
      customerName: invoice.customerName,
      customerPhone: invoice.customerPhone,
      customerAddress: address ?? invoice.customerAddress,
      items: invoice.items,
      subtotal: invoice.subtotal,
      discount: invoice.discount,
      total: invoice.total,
      status: invoice.status,
      createdAt: invoice.createdAt,
      pickupDate: invoice.pickupDate,
      completedDate: invoice.completedDate,
      userId: invoice.userId,
      isSynced: invoice.isSynced,
      customerLatitude: location.latitude,
      customerLongitude: location.longitude,
    );
  }

  /// Extract lokasi dari invoice
  static LocationData? extractLocationFromInvoice(InvoiceModel invoice) {
    if (invoice.customerLatitude == null || invoice.customerLongitude == null) {
      return null;
    }

    return LocationData(
      latitude: invoice.customerLatitude!,
      longitude: invoice.customerLongitude!,
      address: invoice.customerAddress,
    );
  }

  /// Check apakah invoice memiliki lokasi yang valid
  static bool hasValidLocation(InvoiceModel invoice) {
    return invoice.customerLatitude != null &&
        invoice.customerLongitude != null &&
        invoice.customerLatitude! != 0.0 &&
        invoice.customerLongitude! != 0.0;
  }

  /// Format lokasi untuk display
  static String formatLocationDisplay(LocationData location) {
    return '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';
  }

  /// Format lokasi dengan alamat
  static String formatLocationWithAddress(LocationData location) {
    if (location.address != null && location.address!.isNotEmpty) {
      return '${location.address}\n(${formatLocationDisplay(location)})';
    }
    return formatLocationDisplay(location);
  }

  /// Hitung jarak antara dua lokasi (dalam kilometer)
  static double calculateDistance(LatLng from, LatLng to) {
    const Distance distance = Distance();
    // distance.distance() mengembalikan nilai dalam meter
    // convert ke kilometer dengan membagi 1000
    return distance(from, to) / 1000;
  }

  /// Hitung jarak antara invoice locations
  static double calculateInvoiceDistance(LocationData from, LocationData to) {
    return calculateDistance(from.toLatLng(), to.toLatLng());
  }
}

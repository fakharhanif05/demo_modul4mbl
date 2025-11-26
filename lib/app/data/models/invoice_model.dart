import 'package:hive/hive.dart';

part 'invoice_model.g.dart';

@HiveType(typeId: 1)
class InvoiceModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String invoiceNumber;

  @HiveField(2)
  String customerName;

  @HiveField(3)
  String customerPhone;

  @HiveField(4)
  String customerAddress;

  @HiveField(5)
  List<InvoiceItem> items;

  @HiveField(6)
  double subtotal;

  @HiveField(7)
  double discount;

  @HiveField(8)
  double total;

  @HiveField(9)
  String status; // pending, process, done

  @HiveField(10)
  DateTime createdAt;

  @HiveField(11)
  DateTime? pickupDate;

  @HiveField(12)
  DateTime? completedDate;

  @HiveField(13)
  String? userId;

  @HiveField(14)
  bool isSynced;

  @HiveField(15)
  double? customerLatitude;

  @HiveField(16)
  double? customerLongitude;

  InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.status,
    required this.createdAt,
    this.pickupDate,
    this.completedDate,
    this.userId,
    this.isSynced = false,
    this.customerLatitude,
    this.customerLongitude,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'].toString(),
      invoiceNumber: json['invoice_number'] ?? '',
      customerName: json['customer_name'] ?? '',
      customerPhone: json['customer_phone'] ?? '',
      customerAddress: json['customer_address'] ?? '',
      items: (json['items'] as List?)
              ?.map((item) => InvoiceItem.fromJson(item))
              .toList() ??
          [],
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
      pickupDate: json['pickup_date'] != null ? DateTime.parse(json['pickup_date']) : null,
      completedDate: json['completed_date'] != null ? DateTime.parse(json['completed_date']) : null,
      userId: json['user_id'],
      isSynced: json['is_synced'] ?? false,
      customerLatitude: json['customer_latitude']?.toDouble(),
      customerLongitude: json['customer_longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_address': customerAddress,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'total': total,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'pickup_date': pickupDate?.toIso8601String(),
      'completed_date': completedDate?.toIso8601String(),
      'user_id': userId,
      'is_synced': isSynced,
      'customer_latitude': customerLatitude,
      'customer_longitude': customerLongitude,
    };
  }

  /// Konversi objek ke payload sesuai kolom tabel `invoices` Supabase.
  Map<String, dynamic> toSupabase() {
    return {
      'invoice_number': invoiceNumber,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_address': customerAddress,
      'subtotal': subtotal,
      'discount': discount,
      'total': total,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'pickup_date': pickupDate?.toIso8601String(),
      'completed_date': completedDate?.toIso8601String(),
      'user_id': userId,
      'customer_latitude': customerLatitude,
      'customer_longitude': customerLongitude,
    };
  }
}

@HiveType(typeId: 2)
class InvoiceItem extends HiveObject {
  @HiveField(0)
  String serviceId;

  @HiveField(1)
  String serviceName;

  @HiveField(2)
  int pricePerKg;

  @HiveField(3)
  double quantity; // in kg

  @HiveField(4)
  double totalPrice;

  InvoiceItem({
    required this.serviceId,
    required this.serviceName,
    required this.pricePerKg,
    required this.quantity,
    required this.totalPrice,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      serviceId: json['service_id'].toString(),
      serviceName: json['service_name'] ?? '',
      pricePerKg: json['price_per_kg'] ?? 0,
      quantity: (json['quantity'] ?? 0).toDouble(),
      totalPrice: (json['total_price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service_id': serviceId,
      'service_name': serviceName,
      'price_per_kg': pricePerKg,
      'quantity': quantity,
      'total_price': totalPrice,
    };
  }
}
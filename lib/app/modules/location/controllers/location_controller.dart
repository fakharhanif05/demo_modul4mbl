import 'dart:async';

import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../../data/models/invoice_model.dart';
import '../../../data/services/hive_service.dart';

enum LocationProviderType { gps, network }

class LocationController extends GetxController {
  LocationController();

  final currentPosition = Rxn<Position>();
  final gpsPosition = Rxn<Position>();
  final networkPosition = Rxn<Position>();
  final gpsFixDuration = Rxn<Duration>();
  final networkFixDuration = Rxn<Duration>();
  final lastLiveUpdate = Rxn<DateTime>();

  final isGpsLoading = false.obs;
  final isNetworkLoading = false.obs;
  final isLiveTracking = true.obs;
  final isServiceEnabled = false.obs;
  final isPermissionGranted = false.obs;
  final locationError = ''.obs;

  final mapZoom = 16.0.obs;
  final mapCenter = Rx<LatLng>(_defaultCenter);
  final mapController = MapController();

  // Invoice locations untuk antar jemput
  final allInvoices = <InvoiceModel>[].obs;
  final customerInvoices = <InvoiceModel>[].obs;
  final selectedInvoiceId = Rxn<String>();
  final filterStatus = 'pending'.obs; // pending = perlu jemput, process = sedang diantar

  StreamSubscription<Position>? _liveSubscription;

  static const LatLng _defaultCenter = LatLng(-6.175392, 106.827153);

  @override
  void onInit() {
    super.onInit();
    _initLocationFlow();
    loadCustomerLocations();
  }

  void loadCustomerLocations() {
    allInvoices.value = HiveService.getAllInvoices();
    _applyFilter();
  }

  void _applyFilter() {
    // Filter berdasarkan status untuk layanan antar jemput
    // pending = perlu jemput, process = sedang diantar
    customerInvoices.value = allInvoices
        .where((inv) {
          final hasLocation = inv.customerLatitude != null && inv.customerLongitude != null;
          final matchesStatus = inv.status == filterStatus.value;
          return hasLocation && matchesStatus;
        })
        .toList();
  }

  void setFilterStatus(String status) {
    filterStatus.value = status;
    _applyFilter();
  }

  String get filterStatusLabel {
    switch (filterStatus.value) {
      case 'pending':
        return 'Perlu Jemput';
      case 'process':
        return 'Sedang Diantar';
      case 'done':
        return 'Selesai';
      default:
        return 'Semua';
    }
  }

  int get pendingPickupCount {
    return allInvoices
        .where((inv) => inv.status == 'pending' && 
                       inv.customerLatitude != null && 
                       inv.customerLongitude != null)
        .length;
  }

  int get inDeliveryCount {
    return allInvoices
        .where((inv) => inv.status == 'process' && 
                       inv.customerLatitude != null && 
                       inv.customerLongitude != null)
        .length;
  }

  void selectInvoice(String? invoiceId) {
    selectedInvoiceId.value = invoiceId;
    if (invoiceId != null) {
      final invoice = customerInvoices.firstWhereOrNull((inv) => inv.id == invoiceId);
      if (invoice != null && invoice.customerLatitude != null && invoice.customerLongitude != null) {
        final latLng = LatLng(invoice.customerLatitude!, invoice.customerLongitude!);
        mapCenter.value = latLng;
        mapZoom.value = 15.0;
        Future.microtask(() {
          try {
            mapController.move(latLng, mapZoom.value);
          } catch (_) {}
        });
      }
    }
  }

  Future<Position?> getCurrentLocationForInvoice() async {
    if (!await _ensurePermission()) return null;
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      locationError.value = 'Gagal mengambil lokasi: $e';
      return null;
    }
  }

  double? getDistanceToCustomer(InvoiceModel invoice) {
    final current = currentPosition.value;
    if (current == null || invoice.customerLatitude == null || invoice.customerLongitude == null) {
      return null;
    }
    return Geolocator.distanceBetween(
      current.latitude,
      current.longitude,
      invoice.customerLatitude!,
      invoice.customerLongitude!,
    );
  }

  Future<void> _initLocationFlow() async {
    final hasPermission = await _ensurePermission();
    if (hasPermission) {
      await startLiveTracking();
      await fetchNetworkFix();
      await fetchGpsFix();
    }
  }

  Future<bool> _ensurePermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    isServiceEnabled.value = serviceEnabled;
    if (!serviceEnabled) {
      locationError.value = 'Layanan lokasi belum aktif.';
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      locationError.value =
          'Izin lokasi ditolak permanen. Buka pengaturan untuk mengubahnya.';
      isPermissionGranted.value = false;
      return false;
    }

    final granted = permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
    isPermissionGranted.value = granted;

    if (!granted) {
      locationError.value = 'Izin lokasi belum diberikan.';
    } else {
      locationError.value = '';
    }
    return granted;
  }

  Future<void> startLiveTracking() async {
    if (!await _ensurePermission()) return;

    await _liveSubscription?.cancel();
    isLiveTracking.value = true;
    _liveSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      ),
    ).listen(
      (position) {
        currentPosition.value = position;
        lastLiveUpdate.value = DateTime.now();
        _updateMap(position);
      },
      onError: (error) {
        locationError.value = error.toString();
      },
    );
  }

  Future<void> stopLiveTracking() async {
    await _liveSubscription?.cancel();
    isLiveTracking.value = false;
  }

  Future<void> fetchGpsFix() async {
    await _fetchFix(
      provider: LocationProviderType.gps,
      accuracy: LocationAccuracy.bestForNavigation,
    );
  }

  Future<void> fetchNetworkFix() async {
    await _fetchFix(
      provider: LocationProviderType.network,
      accuracy: LocationAccuracy.low,
    );
  }

  Future<void> _fetchFix({
    required LocationProviderType provider,
    required LocationAccuracy accuracy,
  }) async {
    if (!await _ensurePermission()) return;

    final stopwatch = Stopwatch()..start();
    _setLoading(provider, true);

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
        timeLimit: const Duration(seconds: 20),
      );
      stopwatch.stop();

      if (provider == LocationProviderType.gps) {
        gpsPosition.value = position;
        gpsFixDuration.value = stopwatch.elapsed;
      } else {
        networkPosition.value = position;
        networkFixDuration.value = stopwatch.elapsed;
      }
      locationError.value = '';
      _updateMap(position);
    } on TimeoutException {
      locationError.value =
          'Tidak mendapat lokasi $provider dalam waktu 20 detik.';
    } catch (e) {
      locationError.value = 'Gagal mendapatkan lokasi $provider: $e';
    } finally {
      stopwatch.stop();
      _setLoading(provider, false);
    }
  }

  void _setLoading(LocationProviderType provider, bool isLoading) {
    if (provider == LocationProviderType.gps) {
      isGpsLoading.value = isLoading;
    } else {
      isNetworkLoading.value = isLoading;
    }
  }

  void _updateMap(Position position) {
    final latLng = LatLng(position.latitude, position.longitude);
    mapCenter.value = latLng;
    Future.microtask(() {
      try {
        mapController.move(latLng, mapZoom.value);
      } catch (_) {
        // Map belum siap; abaikan agar tidak crash.
      }
    });
  }

  double? get providerOffsetMeters {
    final gps = gpsPosition.value;
    final network = networkPosition.value;
    if (gps == null || network == null) return null;

    return Geolocator.distanceBetween(
      gps.latitude,
      gps.longitude,
      network.latitude,
      network.longitude,
    );
  }

  double get currentSpeedKmh {
    final speed = currentPosition.value?.speed ?? 0;
    if (speed <= 0) return 0;
    return speed * 3.6;
  }

  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  @override
  void onClose() {
    _liveSubscription?.cancel();
    super.onClose();
  }
}


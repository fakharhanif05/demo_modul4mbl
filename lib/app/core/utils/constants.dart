// ============ core/utils/constants.dart ============
class AppConstants {
  AppConstants._();

  // API URLs
  static const String mockApiBaseUrl = 'https://68fc985496f6ff19b9f5a39b.mockapi.io/api/v1';
  static const String servicesEndpoint = '/service';

  // App Info
  static const String appName = 'Laundry App';
  static const String appVersion = '1.0.0';
  static const String appLicense = 'MIT License';

  // Status
  static const String statusPending = 'pending';
  static const String statusProcess = 'process';
  static const String statusDone = 'done';

  // Hive Box Names
  static const String servicesBox = 'services';
  static const String invoicesBox = 'invoices';

  // SharedPreferences Keys
  static const String keyDarkMode = 'isDarkMode';
  static const String keyGuestMode = 'isGuestMode';
  static const String keyLastSync = 'lastSyncTime';

  // Error Messages
  static const String errorNoInternet = 'Tidak ada koneksi internet';
  static const String errorUnknown = 'Terjadi kesalahan';
  static const String errorTimeout = 'Request timeout';
  static const String errorServerError = 'Server error';

  // Success Messages
  static const String successSave = 'Data berhasil disimpan';
  static const String successUpdate = 'Data berhasil diupdate';
  static const String successDelete = 'Data berhasil dihapus';
  static const String successSync = 'Data berhasil disinkronkan';
}
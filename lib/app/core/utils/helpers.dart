// ============ core/utils/helpers.dart ============
import 'package:intl/intl.dart';

class Helpers {
  Helpers._();

  // Currency Formatter
  static final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  // Date Formatters
  static final dateFormatter = DateFormat('dd MMMM yyyy');
  static final dateTimeFormatter = DateFormat('dd MMM yyyy, HH:mm');
  static final timeFormatter = DateFormat('HH:mm');
  static final shortDateFormatter = DateFormat('dd/MM/yyyy');

  // Format Currency
  static String formatCurrency(double amount) {
    return currencyFormatter.format(amount);
  }

  // Format Date
  static String formatDate(DateTime date) {
    return dateFormatter.format(date);
  }

  // Format DateTime
  static String formatDateTime(DateTime dateTime) {
    return dateTimeFormatter.format(dateTime);
  }

  // Get Status Color
  static String getStatusColor(String status) {
    switch (status) {
      case 'done':
        return '#28A745'; // Green
      case 'process':
        return '#FFC107'; // Orange
      case 'pending':
      default:
        return '#6C757D'; // Grey
    }
  }

  // Get Status Text
  static String getStatusText(String status) {
    switch (status) {
      case 'done':
        return 'Selesai';
      case 'process':
        return 'Proses';
      case 'pending':
      default:
        return 'Pending';
    }
  }

  // Validate Email
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // Validate Phone
  static bool isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^(\+62|62|0)[0-9]{9,12}$');
    return phoneRegex.hasMatch(phone.replaceAll(RegExp(r'[\s-]'), ''));
  }

  // Format Phone Number
  static String formatPhone(String phone) {
    // Remove all non-digit characters
    String cleaned = phone.replaceAll(RegExp(r'\D'), '');
    
    // Convert to format 0812-3456-7890
    if (cleaned.startsWith('62')) {
      cleaned = '0${cleaned.substring(2)}';
    } else if (cleaned.startsWith('0')) {
      // Already in correct format
    } else {
      cleaned = '0$cleaned';
    }
    
    if (cleaned.length >= 11) {
      return '${cleaned.substring(0, 4)}-${cleaned.substring(4, 8)}-${cleaned.substring(8)}';
    }
    
    return cleaned;
  }

  // Get Greeting based on time
  static String getGreeting() {
    final hour = DateTime.now().hour;
    
    if (hour < 12) {
      return 'Selamat Pagi';
    } else if (hour < 15) {
      return 'Selamat Siang';
    } else if (hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }

  // Calculate Days Since
  static String getDaysSince(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} menit yang lalu';
      }
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} minggu yang lalu';
    } else {
      return formatDate(date);
    }
  }

  // Truncate String
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Generate Invoice Number
  static String generateInvoiceNumber() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyyMMdd');
    final dateStr = formatter.format(now);
    final random = now.millisecondsSinceEpoch % 1000;
    return 'INV-$dateStr-${random.toString().padLeft(3, '0')}';
  }

  // Check if online
  static Future<bool> checkConnectivity() async {
    try {
      // You can use connectivity_plus package for better checking
      // For now, just return true
      return true;
    } catch (e) {
      return false;
    }
  }
}
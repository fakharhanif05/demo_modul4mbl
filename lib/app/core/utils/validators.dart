// ============ core/utils/validators.dart ============
class Validators {
  Validators._();

  // Email Validator
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    
    return null;
  }

  // Password Validator
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    
    return null;
  }

  // Phone Validator
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }
    
    final phoneRegex = RegExp(r'^(\+62|62|0)[0-9]{9,12}$');
    final cleaned = value.replaceAll(RegExp(r'[\s-]'), '');
    
    if (!phoneRegex.hasMatch(cleaned)) {
      return 'Format nomor telepon tidak valid';
    }
    
    return null;
  }

  // Required Field Validator
  static String? required(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }

  // Number Validator
  static String? number(String? value) {
    if (value == null || value.isEmpty) {
      return 'Angka tidak boleh kosong';
    }
    
    if (double.tryParse(value) == null) {
      return 'Harus berupa angka';
    }
    
    return null;
  }

  // Positive Number Validator
  static String? positiveNumber(String? value) {
    final numberError = number(value);
    if (numberError != null) return numberError;
    
    if (double.parse(value!) <= 0) {
      return 'Angka harus lebih dari 0';
    }
    
    return null;
  }

  // Min Length Validator
  static String? minLength(String? value, int min) {
    if (value == null || value.isEmpty) {
      return 'Field tidak boleh kosong';
    }
    
    if (value.length < min) {
      return 'Minimal $min karakter';
    }
    
    return null;
  }

  // Max Length Validator
  static String? maxLength(String? value, int max) {
    if (value == null || value.isEmpty) {
      return null; // Allow empty
    }
    
    if (value.length > max) {
      return 'Maksimal $max karakter';
    }
    
    return null;
  }
}

import '../constants/app_constants.dart';

class ValidationUtils {
  // General validation
  static bool isNotEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  static bool isValidLength(String? value, int minLength, [int? maxLength]) {
    if (value == null) return false;
    final length = value.trim().length;
    return length >= minLength && (maxLength == null || length <= maxLength);
  }

  // Name validation
  static String? validateName(String? value, {String fieldName = 'الاسم'}) {
    if (!isNotEmpty(value)) {
      return '$fieldName مطلوب';
    }

    if (!isValidLength(value, 2, AppConstants.maxNameLength)) {
      return '$fieldName يجب أن يكون بين 2 و ${AppConstants.maxNameLength} حرف';
    }

    // Check for valid characters (Arabic, English, numbers, spaces, and some special characters)
    final nameRegex = RegExp(r'^[\u0600-\u06FFa-zA-Z0-9\s\.\-\_]+$');
    if (!nameRegex.hasMatch(value!.trim())) {
      return '$fieldName يحتوي على أحرف غير صالحة';
    }

    return null;
  }

  static String? validateCustomerName(String? value) {
    return validateName(value, fieldName: 'اسم العميل');
  }

  static String? validateProductName(String? value) {
    return validateName(value, fieldName: 'اسم المنتج');
  }

  static String? validateBusinessName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Business name is optional
    }
    return validateName(value, fieldName: 'اسم الشركة');
  }

  static String? validateOwnerName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Owner name is optional
    }
    return validateName(value, fieldName: 'اسم المالك');
  }

  // Phone number validation
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Phone is optional
    }

    final cleanPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if (cleanPhone.length < 9 ||
        cleanPhone.length > AppConstants.maxPhoneLength) {
      return 'رقم الهاتف يجب أن يكون بين 9 و ${AppConstants.maxPhoneLength} رقم';
    }

    // Saudi phone number patterns
    final phoneRegex = RegExp(r'^((\+966)|966|05|5)([0-9]{8})$');
    if (!phoneRegex.hasMatch(cleanPhone)) {
      return 'رقم الهاتف غير صحيح';
    }

    return null;
  }

  // Currency validation
  static String? validatePrice(String? value, {String fieldName = 'السعر'}) {
    if (!isNotEmpty(value)) {
      return '$fieldName مطلوب';
    }

    final price = double.tryParse(value!.trim());
    if (price == null) {
      return '$fieldName يجب أن يكون رقم صحيح';
    }

    if (price < 0) {
      return '$fieldName لا يمكن أن يكون سالب';
    }

    if (price == 0) {
      return '$fieldName لا يمكن أن يكون صفر';
    }

    if (price > 999999999) {
      return '$fieldName كبير جداً';
    }

    return null;
  }

  static String? validateOriginalPrice(String? value) {
    return validatePrice(value, fieldName: 'السعر الأصلي');
  }

  static String? validateFinalPrice(String? value) {
    return validatePrice(value, fieldName: 'السعر النهائي');
  }

  static String? validatePaymentAmount(String? value) {
    return validatePrice(value, fieldName: 'مبلغ الدفعة');
  }

  // Price comparison validation
  static String? validateFinalPriceVsOriginal(
    String? finalPriceStr,
    String? originalPriceStr,
  ) {
    final finalPrice = double.tryParse(finalPriceStr ?? '');
    final originalPrice = double.tryParse(originalPriceStr ?? '');

    if (finalPrice == null || originalPrice == null) {
      return null; // Individual validation will catch this
    }

    if (finalPrice < originalPrice) {
      return 'السعر النهائي لا يمكن أن يكون أقل من السعر الأصلي';
    }

    return null;
  }

  // Payment interval validation
  static String? validatePaymentInterval(String? value) {
    if (!isNotEmpty(value)) {
      return 'فترة الدفع مطلوبة';
    }

    final interval = int.tryParse(value!.trim());
    if (interval == null) {
      return 'فترة الدفع يجب أن تكون رقم صحيح';
    }

    if (interval < 1) {
      return 'فترة الدفع يجب أن تكون يوم واحد على الأقل';
    }

    if (interval > 365) {
      return 'فترة الدفع لا يمكن أن تكون أكثر من 365 يوم';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (!isNotEmpty(value)) {
      return 'كلمة المرور مطلوبة';
    }

    if (!isValidLength(value, AppConstants.minPasswordLength)) {
      return 'كلمة المرور يجب أن تكون ${AppConstants.minPasswordLength} أحرف على الأقل';
    }

    return null;
  }

  static String? validatePasswordConfirmation(
    String? password,
    String? confirmation,
  ) {
    if (password != confirmation) {
      return 'كلمة المرور غير متطابقة';
    }
    return null;
  }

  // Notes validation
  static String? validateNotes(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Notes are optional
    }

    if (value.trim().length > AppConstants.maxNotesLength) {
      return 'الملاحظات لا يمكن أن تكون أكثر من ${AppConstants.maxNotesLength} حرف';
    }

    return null;
  }

  // Date validation
  static String? validateDate(DateTime? date, {String fieldName = 'التاريخ'}) {
    if (date == null) {
      return '$fieldName مطلوب';
    }

    final now = DateTime.now();
    final minDate = DateTime(1900);
    final maxDate = DateTime(now.year + 10);

    if (date.isBefore(minDate) || date.isAfter(maxDate)) {
      return '$fieldName غير صالح';
    }

    return null;
  }

  static String? validateSaleDate(DateTime? date) {
    if (date == null) {
      return 'تاريخ البيع مطلوب';
    }

    final now = DateTime.now();
    if (date.isAfter(now)) {
      return 'تاريخ البيع لا يمكن أن يكون في المستقبل';
    }

    return validateDate(date, fieldName: 'تاريخ البيع');
  }

  static String? validatePaymentDate(DateTime? date) {
    if (date == null) {
      return 'تاريخ الدفعة مطلوب';
    }

    final now = DateTime.now();
    if (date.isAfter(now)) {
      return 'تاريخ الدفعة لا يمكن أن يكون في المستقبل';
    }

    return validateDate(date, fieldName: 'تاريخ الدفعة');
  }

  // Email validation (if needed)
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Email is optional
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'البريد الإلكتروني غير صحيح';
    }

    return null;
  }

  // Search query validation
  static String? validateSearchQuery(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'أدخل نص البحث';
    }

    if (value.trim().length < 2) {
      return 'نص البحث يجب أن يكون حرفين على الأقل';
    }

    if (value.trim().length > 100) {
      return 'نص البحث طويل جداً';
    }

    return null;
  }

  // Form validation helpers
  static bool isFormValid(List<String?> validationResults) {
    return validationResults.every((result) => result == null);
  }

  static String? getFirstError(List<String?> validationResults) {
    return validationResults.firstWhere(
      (result) => result != null,
      orElse: () => null,
    );
  }

  // Payment validation against product
  static String? validatePaymentAgainstProduct({
    required double paymentAmount,
    required double productPrice,
    required double totalPaid,
  }) {
    if (paymentAmount <= 0) {
      return 'مبلغ الدفعة يجب أن يكون أكبر من صفر';
    }

    final remainingAmount = productPrice - totalPaid;
    if (paymentAmount > remainingAmount) {
      return 'مبلغ الدفعة أكبر من المبلغ المتبقي';
    }

    return null;
  }

  // Sanitization helpers
  static String sanitizeName(String name) {
    return name.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static String sanitizePhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  }

  static String sanitizeNotes(String notes) {
    return notes.trim();
  }

  // Custom validation
  static String? customValidation(
    String? value,
    bool Function(String) validator,
    String errorMessage,
  ) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return validator(value.trim()) ? null : errorMessage;
  }
}

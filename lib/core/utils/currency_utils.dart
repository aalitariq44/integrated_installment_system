import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class CurrencyUtils {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'ar',
    symbol: AppConstants.currencySymbol,
    decimalDigits: 2,
  );

  static final NumberFormat _numberFormat = NumberFormat('#,##0.00', 'ar');

  // Format currency for display
  static String formatCurrency(double? amount) {
    if (amount == null) return '0.00 ${AppConstants.currencySymbol}';
    return '${_numberFormat.format(amount)} ${AppConstants.currencySymbol}';
  }

  static String formatCurrencyCompact(double? amount) {
    if (amount == null) return '0 ${AppConstants.currencySymbol}';
    
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}م ${AppConstants.currencySymbol}';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}ك ${AppConstants.currencySymbol}';
    } else {
      return '${amount.toStringAsFixed(0)} ${AppConstants.currencySymbol}';
    }
  }

  // Format number without currency symbol
  static String formatNumber(double? number) {
    if (number == null) return '0.00';
    return _numberFormat.format(number);
  }

  static String formatNumberCompact(double? number) {
    if (number == null) return '0';
    
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}م';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}ك';
    } else {
      return number.toStringAsFixed(0);
    }
  }

  // Parse currency from string
  static double? parseCurrency(String? text) {
    if (text == null || text.isEmpty) return null;
    
    // Remove currency symbol and non-numeric characters except decimal point
    final cleanText = text
        .replaceAll(AppConstants.currencySymbol, '')
        .replaceAll(',', '')
        .replaceAll(' ', '')
        .trim();
    
    return double.tryParse(cleanText);
  }

  // Validation
  static bool isValidCurrency(String? text) {
    final parsed = parseCurrency(text);
    return parsed != null && parsed >= 0;
  }

  static bool isValidAmount(double? amount) {
    return amount != null && amount >= 0;
  }

  // Currency calculations
  static double calculateProfit(double originalPrice, double finalPrice) {
    return finalPrice - originalPrice;
  }

  static double calculateProfitPercentage(double originalPrice, double finalPrice) {
    if (originalPrice <= 0) return 0;
    return ((finalPrice - originalPrice) / originalPrice) * 100;
  }

  static double calculateRemainingAmount(double totalAmount, double paidAmount) {
    return totalAmount - paidAmount;
  }

  static double calculatePaymentProgress(double totalAmount, double paidAmount) {
    if (totalAmount <= 0) return 0;
    return (paidAmount / totalAmount) * 100;
  }

  // Installment calculations
  static double calculateInstallmentAmount(double totalAmount, int numberOfInstallments) {
    if (numberOfInstallments <= 0) return totalAmount;
    return totalAmount / numberOfInstallments;
  }

  static int calculateNumberOfInstallments(
    double totalAmount,
    double installmentAmount,
  ) {
    if (installmentAmount <= 0) return 0;
    return (totalAmount / installmentAmount).ceil();
  }

  static List<double> generateInstallmentSchedule(
    double totalAmount,
    int numberOfInstallments,
  ) {
    if (numberOfInstallments <= 0) return [totalAmount];
    
    final installmentAmount = totalAmount / numberOfInstallments;
    final schedule = <double>[];
    
    for (int i = 0; i < numberOfInstallments - 1; i++) {
      schedule.add(installmentAmount);
    }
    
    // Last installment might be different due to rounding
    final remainingAmount = totalAmount - (installmentAmount * (numberOfInstallments - 1));
    schedule.add(remainingAmount);
    
    return schedule;
  }

  // Statistical calculations
  static double calculateAverage(List<double> amounts) {
    if (amounts.isEmpty) return 0;
    final sum = amounts.reduce((a, b) => a + b);
    return sum / amounts.length;
  }

  static double calculateSum(List<double> amounts) {
    if (amounts.isEmpty) return 0;
    return amounts.reduce((a, b) => a + b);
  }

  static double findMaximum(List<double> amounts) {
    if (amounts.isEmpty) return 0;
    return amounts.reduce((a, b) => a > b ? a : b);
  }

  static double findMinimum(List<double> amounts) {
    if (amounts.isEmpty) return 0;
    return amounts.reduce((a, b) => a < b ? a : b);
  }

  // Rounding utilities
  static double roundToTwoDecimals(double value) {
    return double.parse(value.toStringAsFixed(2));
  }

  static double roundToCurrency(double value) {
    return roundToTwoDecimals(value);
  }

  // Currency comparison
  static bool isEqual(double amount1, double amount2, {double tolerance = 0.01}) {
    return (amount1 - amount2).abs() < tolerance;
  }

  static bool isGreaterThan(double amount1, double amount2) {
    return amount1 > amount2;
  }

  static bool isLessThan(double amount1, double amount2) {
    return amount1 < amount2;
  }

  // Format for different contexts
  static String formatForDisplay(double? amount, {bool showSymbol = true}) {
    if (amount == null) return showSymbol ? '0.00 ${AppConstants.currencySymbol}' : '0.00';
    
    if (showSymbol) {
      return formatCurrency(amount);
    } else {
      return formatNumber(amount);
    }
  }

  static String formatForInput(double? amount) {
    if (amount == null || amount == 0) return '';
    return amount.toStringAsFixed(2);
  }

  static String formatForReceipt(double amount) {
    return formatCurrency(amount);
  }

  // Discount calculations
  static double calculateDiscountAmount(double originalAmount, double discountPercentage) {
    return originalAmount * (discountPercentage / 100);
  }

  static double applyDiscount(double originalAmount, double discountPercentage) {
    return originalAmount - calculateDiscountAmount(originalAmount, discountPercentage);
  }

  static double calculateDiscountPercentage(double originalAmount, double discountedAmount) {
    if (originalAmount <= 0) return 0;
    return ((originalAmount - discountedAmount) / originalAmount) * 100;
  }

  // Tax calculations
  static double calculateTax(double amount, double taxPercentage) {
    return amount * (taxPercentage / 100);
  }

  static double addTax(double amount, double taxPercentage) {
    return amount + calculateTax(amount, taxPercentage);
  }

  static double removeTax(double amountWithTax, double taxPercentage) {
    return amountWithTax / (1 + (taxPercentage / 100));
  }

  // Exchange rate utilities (if needed in future)
  static double convertCurrency(double amount, double exchangeRate) {
    return amount * exchangeRate;
  }

  // Format for charts and statistics
  static String formatForChart(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }
}

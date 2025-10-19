import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

/// Helper utilities for the application
class Helpers {
  // ========== Date & Time Formatting ==========
  
  /// Format DateTime to readable string
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
  }
  
  /// Format DateTime to time only
  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm:ss').format(dateTime);
  }
  
  /// Format DateTime to date only
  static String formatDate(DateTime dateTime) {
    return DateFormat('dd MMM yyyy').format(dateTime);
  }
  
  /// Get relative time (e.g., "2 hours ago")
  static String getRelativeTime(DateTime dateTime) {
    final Duration diff = DateTime.now().difference(dateTime);
    
    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}s ago';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return formatDate(dateTime);
    }
  }
  
  // ========== Number Formatting ==========
  
  /// Format number with decimal places
  static String formatNumber(double number, {int decimals = 2}) {
    return number.toStringAsFixed(decimals);
  }
  
  /// Format as percentage
  static String formatPercentage(double value, {int decimals = 1}) {
    return '${(value * 100).toStringAsFixed(decimals)}%';
  }
  
  /// Format distance (meters)
  static String formatDistance(double meters) {
    if (meters < 1) {
      return '${(meters * 100).toStringAsFixed(0)} cm';
    } else {
      return '${meters.toStringAsFixed(2)} m';
    }
  }
  
  /// Format temperature
  static String formatTemperature(double celsius) {
    return '${celsius.toStringAsFixed(1)}°C';
  }
  
  /// Format humidity
  static String formatHumidity(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }
  
  // ========== Validation ==========
  
  /// Validate email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  /// Validate password (minimum 8 characters, at least one letter and one number)
  static bool isValidPassword(String password) {
    return password.length >= 8 &&
        RegExp(r'[a-zA-Z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password);
  }
  
  /// Validate IP address
  static bool isValidIpAddress(String ip) {
    return RegExp(
      r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
    ).hasMatch(ip);
  }
  
  /// Validate MAC address
  static bool isValidMacAddress(String mac) {
    return RegExp(r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$').hasMatch(mac);
  }
  
  // ========== Distance Calculations ==========
  
  /// Calculate distance between two 2D points
  static double calculateDistance(
    double x1,
    double y1,
    double x2,
    double y2,
  ) {
    return math.sqrt(math.pow(x2 - x1, 2) + math.pow(y2 - y1, 2));
  }
  
  /// Calculate distance from RSSI (simplified)
  static double calculateDistanceFromRssi(double rssi, {double txPower = -59}) {
    // Simplified path loss formula
    // d = 10 ^ ((txPower - rssi) / (10 * n))
    // where n is the path loss exponent (typically 2-4)
    const double pathLossExponent = 2.5;
    return math.pow(10, (txPower - rssi) / (10 * pathLossExponent)).toDouble();
  }
  
  /// Trilateration for UWB positioning (3 anchors)
  static Map<String, double>? trilaterate(
    double x1, double y1, double r1,
    double x2, double y2, double r2,
    double x3, double y3, double r3,
  ) {
    try {
      // Simplified trilateration algorithm
      double A = 2 * x2 - 2 * x1;
      double B = 2 * y2 - 2 * y1;
      double C = r1 * r1 - r2 * r2 - x1 * x1 + x2 * x2 - y1 * y1 + y2 * y2;
      double D = 2 * x3 - 2 * x2;
      double E = 2 * y3 - 2 * y2;
      double F = r2 * r2 - r3 * r3 - x2 * x2 + x3 * x3 - y2 * y2 + y3 * y3;
      
      double x = (C * E - F * B) / (E * A - B * D);
      double y = (C * D - A * F) / (B * D - A * E);
      
      return {'x': x, 'y': y};
    } catch (e) {
      return null;
    }
  }
  
  // ========== Color Utilities ==========
  
  /// Get status color based on value
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'online':
      case 'open':
      case 'authorized':
        return const Color(0xFF10B981); // Success
      case 'inactive':
      case 'offline':
      case 'closed':
        return const Color(0xFF6B7280); // Gray
      case 'warning':
      case 'unauthorized':
        return const Color(0xFFF59E0B); // Warning
      case 'error':
      case 'failed':
        return const Color(0xFFEF4444); // Error
      default:
        return const Color(0xFF3B82F6); // Info
    }
  }
  
  /// Get temperature color based on value
  static Color getTemperatureColor(double celsius) {
    if (celsius < 15) {
      return const Color(0xFF3B82F6); // Blue
    } else if (celsius < 20) {
      return const Color(0xFF00FFC6); // Green
    } else if (celsius < 25) {
      return const Color(0xFF10B981); // Success
    } else if (celsius < 30) {
      return const Color(0xFFF59E0B); // Warning
    } else {
      return const Color(0xFFEF4444); // Error
    }
  }
  
  /// Get signal strength color based on RSSI
  static Color getSignalColor(double rssi) {
    if (rssi > -50) {
      return const Color(0xFF10B981); // Excellent
    } else if (rssi > -60) {
      return const Color(0xFF00FFC6); // Good
    } else if (rssi > -70) {
      return const Color(0xFFF59E0B); // Fair
    } else {
      return const Color(0xFFEF4444); // Poor
    }
  }
  
  // ========== String Utilities ==========
  
  /// Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  
  /// Generate random color
  static Color getRandomColor() {
    return Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  }
  
  /// Convert hex string to Color
  static Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }
  
  /// Convert Color to hex string
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }
  
  // ========== Dialog Helpers ==========
  
  /// Show success snackbar
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  /// Show error snackbar
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }
  
  /// Show warning snackbar
  static void showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFF59E0B),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  /// Show info snackbar
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF3B82F6),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  /// Show confirmation dialog
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }
  
  // ========== Loading Indicator ==========
  
  /// Show loading dialog
  static void showLoading(BuildContext context, {String message = 'Loading...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Text(message),
          ],
        ),
      ),
    );
  }
  
  /// Hide loading dialog
  static void hideLoading(BuildContext context) {
    Navigator.of(context).pop();
  }
  
  // ========== Encryption Utilities ==========
  
  /// Generate UUID v4
  static String generateUuid() {
    final random = math.Random();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    
    // Set version (4) and variant bits
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    
    return bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join()
        .replaceAllMapped(
          RegExp(r'(.{8})(.{4})(.{4})(.{4})(.{12})'),
          (m) => '${m[1]}-${m[2]}-${m[3]}-${m[4]}-${m[5]}',
        );
  }
  
  /// Generate random key (for testing)
  static String generateRandomKey({int length = 32}) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(length, (_) => chars[math.Random().nextInt(chars.length)]).join();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'constants.dart';
import 'enum/snackbar_status.dart';
import 'typography.dart';

class Helper {
  /// Format integer to Rupiah e.g. 125000 -> "Rp 125.000"
  static String formatRupiah(num amount) {
    final s = amount.round().toString();
    final buffer = StringBuffer();
    final len = s.length;
    for (var i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(s[i]);
    }
    return 'Rp ${buffer.toString()}';
  }

  /// Short format e.g. 237000 -> "Rp 237 rb", 15420000 -> "Rp 15,4 jt"
  static String formatRupiahShort(num amount) {
    if (amount >= 1000000) {
      final jt = amount / 1000000;
      final formatted = jt.toStringAsFixed(jt.truncateToDouble() == jt ? 0 : 1);
      return 'Rp ${formatted.replaceAll('.', ',')} jt';
    } else if (amount >= 1000) {
      final rb = (amount / 1000).round();
      return 'Rp $rb rb';
    }
    return formatRupiah(amount);
  }

  /// Mask PAN e.g. "4821" -> "•••• 4821" or full card PAN
  static String maskPan(String? last4) {
    if (last4 == null || last4.isEmpty) return '•••• ••••';
    return '•••• $last4';
  }

  /// Format DateTime e.g. "09 Nov 2026, 09:41"
  static String formatDateTime(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final day = dt.day.toString().padLeft(2, '0');
    final month = months[dt.month - 1];
    final year = dt.year.toString();
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$day $month $year, $hour:$min';
  }

  /// Format Time only e.g. "09:41"
  static String formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$hour:$min';
  }

  /// Format Date heading e.g. "Hari ini, 9 Nov"
  static String formatDateHeader(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final now = DateTime.now();
    final isToday =
        now.year == dt.year && now.month == dt.month && now.day == dt.day;
    final day = dt.day.toString();
    final month = months[dt.month - 1];
    if (isToday) {
      return 'Hari ini, $day $month';
    }
    return '$day $month ${dt.year}';
  }

  static void setSnackBar({
    required SnackBarType type,
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    Get
      ..closeCurrentSnackbar()
      ..snackbar(
        '',
        '',
        duration: duration,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: type.color,
        borderRadius: AppConstants.radiusTag,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        messageText: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(type.icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppTypography.body.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            InkWell(
              onTap: Get.closeCurrentSnackbar,
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ],
        ),
        titleText: const SizedBox.shrink(),
        barBlur: 0,
        overlayBlur: 0,
      );
  }

  /// Toast notification
  static void showToast(String message, {bool isError = false}) {
    setSnackBar(
      type: isError ? SnackBarType.error : SnackBarType.success,
      message: message,
    );
  }

  /// Copy to clipboard with toast
  static Future<void> copyToClipboard(String text, {String? successMessage}) async {
    await Clipboard.setData(ClipboardData(text: text));
    showToast(successMessage ?? 'Disalin ke papan klip');
  }
}

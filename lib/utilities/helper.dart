import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'enum/snackbar_status.dart';
import 'typography.dart';

class Helper {
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
        borderRadius: 8,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12, top: 8),
        messageText: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(type.icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppTypography.body.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            InkWell(
              onTap: Get.closeCurrentSnackbar,
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ],
        ),
        titleText: const SizedBox.shrink(),
        barBlur: 0,
        overlayBlur: 0,
      );
  }
}

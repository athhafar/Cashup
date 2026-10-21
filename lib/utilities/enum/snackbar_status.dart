import 'package:flutter/material.dart';

import '../colors.dart';

enum SnackBarType {
  success(AppColors.success, Icons.check_circle_outline),
  error(AppColors.error, Icons.error_outline),
  warning(AppColors.warning, Icons.warning_amber_rounded),
  info(AppColors.primary, Icons.info_outline);

  const SnackBarType(this.color, this.icon);

  final Color color;
  final IconData icon;
}

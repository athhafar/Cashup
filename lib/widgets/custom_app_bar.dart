import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utilities/colors.dart';
import '../utilities/typography.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final Color backgroundColor;
  final Color? foregroundColor;
  final bool centerTitle;
  final Widget? customText;
  final double? elevation;
  final IconData leadingIcon;
  final VoidCallback? onLeadingPressed;
  final Widget? bottom;
  final bool withoutLeading;
  final double? customHeight;
  final bool withActionPadding;

  const CustomAppBar({
    super.key,
    this.title,
    this.actions,
    this.backgroundColor = AppColors.primary,
    this.foregroundColor,
    this.centerTitle = false,
    this.customText,
    this.elevation = .33,
    this.leadingIcon = Icons.arrow_back_ios_new,
    this.onLeadingPressed,
    this.bottom,
    this.withoutLeading = false,
    this.customHeight,
    this.withActionPadding = true,
  });

  @override
  Widget build(BuildContext context) {
    final bottomWidget = bottom;
    return AppBar(
      title:
          customText ??
          Text(
            title ?? '',
            style: AppTypography.h1.copyWith(
              fontSize: 20,
              color: Colors.white,
              height: 28 / 20,
            ),
          ),
      backgroundColor: backgroundColor,
      surfaceTintColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      actions: actions,
      actionsPadding: withActionPadding
          ? const EdgeInsets.only(right: 12)
          : null,
      centerTitle: centerTitle,
      leadingWidth: withoutLeading ? 16 : 56,
      titleSpacing: 0,
      leading: withoutLeading
          ? const SizedBox.shrink()
          : IconButton(
              icon: Icon(leadingIcon, color: Colors.white, size: 22),
              onPressed: onLeadingPressed ?? Get.back,
              tooltip: 'Kembali',
              style: IconButton.styleFrom(
                elevation: 0,
                padding: EdgeInsets.zero,
              ),
            ),
      bottom: bottomWidget != null
          ? PreferredSize(
              preferredSize: Size(double.infinity, customHeight ?? 33),
              child: bottomWidget,
            )
          : null,
    );
  }

  @override
  Size get preferredSize => bottom == null
      ? const Size.fromHeight(kToolbarHeight)
      : Size.fromHeight(kToolbarHeight + (customHeight ?? 33));
}

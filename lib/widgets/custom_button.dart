import 'package:flutter/material.dart';
import '../utilities/colors.dart';
import '../utilities/constants.dart';
import '../utilities/typography.dart';

enum ButtonVariant { primary, secondary, danger, outline }

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonVariant variant;
  final Widget? icon;
  final double height;
  final bool enableShine;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.height = AppConstants.buttonHeight,
    this.enableShine = false,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shineController;

  @override
  void initState() {
    super.initState();
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide? border;

    switch (widget.variant) {
      case ButtonVariant.primary:
        bg = AppColors.accent;
        fg = Colors.white;
        border = null;
        break;
      case ButtonVariant.secondary:
        bg = AppColors.surface;
        fg = AppColors.ink;
        border = const BorderSide(color: AppColors.line, width: 1);
        break;
      case ButtonVariant.danger:
        bg = AppColors.dangerBg;
        fg = AppColors.danger;
        border = null;
        break;
      case ButtonVariant.outline:
        bg = Colors.transparent;
        fg = Colors.white;
        border = const BorderSide(color: Colors.white70, width: 1.2);
        break;
    }

    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: Material(
        color: isEnabled ? bg : (widget.variant == ButtonVariant.outline ? Colors.transparent : AppColors.disabled.withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radius),
          side: border ?? BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isEnabled ? widget.onPressed : null,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Shine animation if enabled
              if (widget.enableShine && isEnabled && widget.variant == ButtonVariant.primary)
                AnimatedBuilder(
                  animation: _shineController,
                  builder: (context, child) {
                    final progress = _shineController.value;
                    return Positioned(
                      left: -100 + (progress * 450),
                      top: 0,
                      bottom: 0,
                      width: 60,
                      child: Transform.rotate(
                        angle: 0.35,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.0),
                                Colors.white.withValues(alpha: 0.22),
                                Colors.white.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              Center(
                child: widget.isLoading
                    ? SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: fg,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null) ...[
                            widget.icon!,
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.text,
                            style: AppTypography.button.copyWith(
                              color: isEnabled ? fg : Colors.black38,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

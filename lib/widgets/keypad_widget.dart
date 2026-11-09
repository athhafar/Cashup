import 'package:flutter/material.dart';
import '../utilities/colors.dart';

class KeypadWidget extends StatelessWidget {
  final ValueChanged<String> onKeyPress;
  final VoidCallback onDeletePress;

  const KeypadWidget({
    super.key,
    required this.onKeyPress,
    required this.onDeletePress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _KeypadButton(label: '1', onTap: () => onKeyPress('1')),
            _KeypadButton(label: '2', onTap: () => onKeyPress('2')),
            _KeypadButton(label: '3', onTap: () => onKeyPress('3')),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _KeypadButton(label: '4', onTap: () => onKeyPress('4')),
            _KeypadButton(label: '5', onTap: () => onKeyPress('5')),
            _KeypadButton(label: '6', onTap: () => onKeyPress('6')),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _KeypadButton(label: '7', onTap: () => onKeyPress('7')),
            _KeypadButton(label: '8', onTap: () => onKeyPress('8')),
            _KeypadButton(label: '9', onTap: () => onKeyPress('9')),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _KeypadButton(label: '000', onTap: () => onKeyPress('000')),
            _KeypadButton(label: '0', onTap: () => onKeyPress('0')),
            _KeypadButton(
              icon: Icons.backspace_outlined,
              onTap: onDeletePress,
            ),
          ],
        ),
      ],
    );
  }
}

class _KeypadButton extends StatefulWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  const _KeypadButton({
    this.label,
    this.icon,
    required this.onTap,
  });

  @override
  State<_KeypadButton> createState() => _KeypadButtonState();
}

class _KeypadButtonState extends State<_KeypadButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) {
          setState(() => _isPressed = true);
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
        },
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeInOut,
          child: Container(
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _isPressed ? AppColors.line.withValues(alpha: 0.5) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: widget.icon != null
                ? Icon(
                    widget.icon,
                    size: 26,
                    color: AppColors.ink,
                  )
                : Text(
                    widget.label!,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

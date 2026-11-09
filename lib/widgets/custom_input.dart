import 'package:flutter/material.dart';
import '../utilities/colors.dart';
import '../utilities/constants.dart';
import '../utilities/typography.dart';

class CustomInput extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final String? errorText;

  const CustomInput({
    super.key,
    required this.label,
    this.hint = '',
    this.controller,
    this.isPassword = false,
    this.keyboardType,
    this.validator,
    this.errorText,
  });

  @override
  State<CustomInput> createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {
  late bool _obscure = widget.isPassword;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTypography.caption),
        const SizedBox(height: 8),
        SizedBox(
          height: AppConstants.fieldHeight,
          child: TextFormField(
            controller: widget.controller,
            obscureText: _obscure,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            style: AppTypography.bodyMedium,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTypography.hint,
              filled: true,
              fillColor: AppColors.ground,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radius),
                borderSide: const BorderSide(color: AppColors.line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radius),
                borderSide: const BorderSide(color: AppColors.line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radius),
                borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
              ),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppColors.muted,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    )
                  : null,
            ),
          ),
        ),
        if (widget.errorText != null && widget.errorText!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            widget.errorText!,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.danger,
            ),
          ),
        ],
      ],
    );
  }
}

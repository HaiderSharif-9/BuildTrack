import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscure;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final IconData? prefixIcon;
  final IconData? icon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final VoidCallback? onSuffixIconTap;
  final bool? enabled;

  const AppTextField({
    required this.label,
    this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscure = false,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.prefixIcon,
    this.icon,
    this.suffixIcon,
    this.onSuffixTap,
    this.onSuffixIconTap,
    this.enabled,
    super.key,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final leadingIcon = widget.icon ?? widget.prefixIcon;
    final trailingTap = widget.onSuffixIconTap ?? widget.onSuffixTap;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTypography.labelLight.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: _obscured,
          validator: widget.validator,
          onChanged: widget.onChanged,
          enabled: widget.enabled,
          maxLines: _obscured ? 1 : widget.maxLines,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: leadingIcon != null ? Icon(leadingIcon) : null,
            suffixIcon: widget.suffixIcon != null
                ? GestureDetector(
                    onTap: trailingTap ?? (widget.obscure ? _toggleObscure : null),
                    child: Icon(widget.suffixIcon),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
            ),
          ),
        ),
      ],
    );
  }

  void _toggleObscure() {
    setState(() => _obscured = !_obscured);
  }
}

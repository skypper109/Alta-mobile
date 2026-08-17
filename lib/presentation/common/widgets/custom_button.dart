import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';

enum CustomButtonVariant { primary, accent, secondary, outline, ghost }

class CustomButton extends StatefulWidget {
  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = CustomButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height = 52.0,
  });

  final String label;
  final VoidCallback? onPressed;
  final CustomButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double height;

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> with SingleTickerProviderStateMixin {
  late final AnimationController _scaleCtrl;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  Color get _bgColor => switch (widget.variant) {
    CustomButtonVariant.primary   => AppColors.primary,
    CustomButtonVariant.accent    => AppColors.accent,
    CustomButtonVariant.secondary => AppColors.surfaceAlt,
    CustomButtonVariant.outline   => AppColors.surface,
    CustomButtonVariant.ghost     => Colors.transparent,
  };

  Color get _fgColor => switch (widget.variant) {
    CustomButtonVariant.primary   => Colors.white,
    CustomButtonVariant.accent    => Colors.white,
    CustomButtonVariant.secondary => AppColors.textPrimary,
    CustomButtonVariant.outline   => AppColors.textPrimary,
    CustomButtonVariant.ghost     => AppColors.secondary,
  };

  BorderSide get _border => switch (widget.variant) {
    CustomButtonVariant.outline   => const BorderSide(color: AppColors.border, width: 1),
    CustomButtonVariant.secondary => const BorderSide(color: AppColors.border, width: 1),
    _ => BorderSide.none,
  };

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.isLoading;

    return ScaleTransition(
      scale: _scaleCtrl,
      child: SizedBox(
        width: widget.isFullWidth ? double.infinity : null,
        height: widget.height,
        child: Material(
          color: enabled ? _bgColor : AppColors.surfaceAlt.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: _border,
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: enabled
                ? () {
                    HapticFeedback.lightImpact();
                    _scaleCtrl.reverse().then((_) => _scaleCtrl.forward());
                    widget.onPressed!();
                  }
                : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.isLoading)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: _fgColor,
                      ),
                    )
                  else ...[
                    if (widget.icon != null) ...[
                      Icon(widget.icon, size: 20, color: _fgColor),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        widget.label,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _fgColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Retro-compat alias
typedef DetButton = CustomButton;
typedef DetButtonVariant = CustomButtonVariant;

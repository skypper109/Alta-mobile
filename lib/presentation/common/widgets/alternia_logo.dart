import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';

class AlterniaLogo extends StatelessWidget {
  const AlterniaLogo({
    super.key,
    this.size = 32,
    this.showText = true,
    this.fontSize,
    this.iaColor,
  });

  final double size;
  final bool showText;
  final double? fontSize;
  final Color? iaColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final effectiveIaColor = iaColor ?? AppColors.secondary;

    final textStyle = GoogleFonts.plusJakartaSans(
      fontSize: fontSize ?? (size * 0.55),
      fontWeight: FontWeight.w800,
      color: primaryTextColor,
      letterSpacing: -0.5,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (iaColor ?? AppColors.primary).withValues(alpha: 0.25),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size / 2),
            child: Image.asset(
              'assets/images/alternia_logo.png',
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: size,
                height: size,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: effectiveIaColor,
                    size: size * 0.55,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (showText) ...[
          SizedBox(width: size * 0.28),
          RichText(
            text: TextSpan(
              style: textStyle,
              children: [
                TextSpan(
                  text: 'Altern',
                  style: textStyle.copyWith(color: primaryTextColor),
                ),
                TextSpan(
                  text: 'iA',
                  style: textStyle.copyWith(
                    color: effectiveIaColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

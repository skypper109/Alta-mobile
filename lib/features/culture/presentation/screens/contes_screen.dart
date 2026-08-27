import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/culture_theme.dart';
import '../views/culture_contes_view.dart';
import '../widgets/region_filter_pill.dart';

/// Écran autonome des Contes & Traditions Orales du Mali
class ContesScreen extends StatelessWidget {
  const ContesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final bgColor = isDark ? CultureTheme.darkBackground : CultureTheme.lightBackground;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      if (context.canPop()) context.pop();
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark ? CultureTheme.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: 20,
                        color: titleColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contes & Récits',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: titleColor,
                            letterSpacing: -0.4,
                          ),
                        ),
                        Text(
                          'Traditions orales & sagesse du Mali',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const RegionFilterPill(compact: true),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                color: isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder,
                height: 20,
              ),
            ),

            const Expanded(
              child: CultureContesView(),
            ),
          ],
        ),
      ),
    );
  }
}

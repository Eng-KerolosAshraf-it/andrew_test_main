import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:engineering_platform/core/constants/colors.dart';
import 'package:engineering_platform/core/state/language_state.dart';
import 'package:engineering_platform/core/state/theme_state.dart';
import 'package:engineering_platform/core/utils/responsive.dart';
import 'package:engineering_platform/core/constants/translations.dart';
import 'package:engineering_platform/presentation/web/technician/widgets/technician_widgets.dart';

class ExecutionPage extends StatelessWidget {
  const ExecutionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: technicianLanguageNotifier,
      builder: (context, lang, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: technicianThemeNotifier,
          builder: (context, themeMode, _) {
            final bool isMobile = Responsive.isMobile(context);
            final isDark = themeMode == ThemeMode.dark;

            return Scaffold(
              backgroundColor: isDark
                  ? const Color(0xFF0F172A)
                  : AppColors.background,
              drawer: isMobile ? const TechnicianSidebar() : null,
              body: Row(
                children: [
                  if (!isMobile) const TechnicianSidebar(),
                  Expanded(
                    child: Column(
                      children: [
                        TechnicianHeader(isMobile: isMobile, showSearch: false),
                        const Expanded(child: ExecutionContent()),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class ExecutionContent extends StatelessWidget {
  const ExecutionContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: technicianLanguageNotifier,
      builder: (context, lang, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: technicianThemeNotifier,
          builder: (context, themeMode, _) {
            final bool isMobile = Responsive.isMobile(context);
            final isDark = themeMode == ThemeMode.dark;
            final Color textColor = isDark
                ? Colors.white
                : AppColors.textPrimary;
            final Color subTextColor = isDark
                ? Colors.white60
                : AppColors.textSecondary;

            return SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 24 : 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppTranslations.get('execution_proof', lang),
                    style: TextStyle(
                      fontSize: isMobile ? 28 : 32,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppTranslations.get('execution_desc', lang),
                    style: TextStyle(
                      fontSize: 16,
                      color: subTextColor,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Drag and Drop Area
                  Container(
                    width: double.infinity,
                    height: isMobile ? 300 : 350,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: isDark
                          ? null
                          : const [
                              BoxShadow(
                                color: AppColors.shadowColor,
                                blurRadius: 15,
                                offset: Offset(0, 5),
                              ),
                            ],
                      border: isDark ? Border.all(color: Colors.white10) : null,
                    ),
                    child: CustomPaint(
                      painter: DashedRectPainter(
                        color: isDark
                            ? Colors.orange.withValues(alpha: 0.5)
                            : AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: 20,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.orange.withValues(alpha: 0.1)
                                  : AppColors.accentLight,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.cloud_upload_outlined,
                              color: isDark ? Colors.orange : AppColors.primary,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            AppTranslations.get('drag_drop_files', lang),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppTranslations.get('support_formats', lang),
                            style: TextStyle(fontSize: 14, color: subTextColor),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark
                                  ? Colors.orange
                                  : AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 18,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              AppTranslations.get('browse_files', lang),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Note Area label
                  Text(
                    AppTranslations.get('completion_note', lang),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.white10 : AppColors.greyBorder,
                      ),
                    ),
                    child: TextField(
                      maxLines: 5,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: AppTranslations.get(
                          'completion_note_hint',
                          lang,
                        ),
                        hintStyle: TextStyle(
                          color: isDark
                              ? Colors.white38
                              : AppColors.textSecondary,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(20),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Mark as Complete Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? Colors.orange
                            : AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        AppTranslations.get('mark_complete', lang),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double borderRadius;

  DashedRectPainter({
    required this.color,
    this.strokeWidth = 2,
    this.dashWidth = 8,
    this.dashSpace = 6,
    this.borderRadius = 12,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final Path path = Path()..addRRect(rRect);

    final Path dashedPath = Path();
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        dashedPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

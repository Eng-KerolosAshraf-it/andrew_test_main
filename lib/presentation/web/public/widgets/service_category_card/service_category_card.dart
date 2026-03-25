import 'package:flutter/material.dart';
import 'package:engineering_platform/core/constants/colors.dart';
import 'package:engineering_platform/core/state/language_state.dart';
import 'package:engineering_platform/core/utils/responsive.dart';

class ServiceCategoryCard extends StatefulWidget {
  final String imagePath;
  final String title;
  final String description;
  final VoidCallback onTap;

  const ServiceCategoryCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  State<ServiceCategoryCard> createState() => _ServiceCategoryCardState();
}

class _ServiceCategoryCardState extends State<ServiceCategoryCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: clientLanguageNotifier,
      builder: (context, lang, child) {
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            transform: Matrix4.diagonal3Values(
              isHovered ? 1.02 : 1.0,
              isHovered ? 1.02 : 1.0,
              1.0,
            ),
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(24),
              child: Column(
                crossAxisAlignment: lang == 'ar'
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    height: Responsive.isMobile(context) ? 200 : 230,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: isHovered
                          ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.25), blurRadius: 30, offset: const Offset(0, 15))]
                          : [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))],
                      image: DecorationImage(image: AssetImage(widget.imagePath), fit: BoxFit.cover),
                    ),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: isHovered ? 1.0 : 0.0,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [AppColors.accent.withValues(alpha: 0.7), Colors.transparent],
                          ),
                        ),
                        alignment: Alignment.bottomRight,
                        padding: const EdgeInsets.all(24),
                        child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 32),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(widget.title,
                    textAlign: lang == 'ar' ? TextAlign.right : TextAlign.left,
                    style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold,
                      color: isHovered ? AppColors.accent
                          : (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.textPrimary),
                    )),
                  const SizedBox(height: 2),
                  Text(widget.description,
                    textAlign: lang == 'ar' ? TextAlign.right : TextAlign.left,
                    style: TextStyle(
                      fontSize: 14, height: 1.4,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppColors.textSecondary,
                    )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

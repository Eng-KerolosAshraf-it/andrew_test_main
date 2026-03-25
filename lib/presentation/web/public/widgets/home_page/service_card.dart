import 'package:flutter/material.dart';
import 'package:engineering_platform/core/constants/colors.dart';
import 'package:engineering_platform/core/state/language_state.dart';

class ServiceCard extends StatefulWidget {
  final String title;
  final String desc;
  final String imagePath;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.title,
    required this.desc,
    required this.imagePath,
    required this.onTap,
  });

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
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
            transform: Matrix4.translationValues(0, isHovered ? -10.0 : 0.0, 0.0),
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(20),
              child: Column(
                crossAxisAlignment: lang == 'ar' ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 1.1,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white12 : AppColors.greyLight,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isHovered
                            ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10))]
                            : [],
                        image: DecorationImage(image: AssetImage(widget.imagePath), fit: BoxFit.cover),
                      ),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: isHovered ? 1.0 : 0.0,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter, end: Alignment.topCenter,
                              colors: [AppColors.accent.withValues(alpha: 0.6), Colors.transparent],
                            ),
                          ),
                          alignment: Alignment.bottomRight,
                          padding: const EdgeInsets.all(16),
                          child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 30),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(widget.title,
                    textAlign: lang == 'ar' ? TextAlign.right : TextAlign.left,
                    style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold,
                      color: isHovered ? AppColors.accent
                          : (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.textPrimary),
                    )),
                  const SizedBox(height: 8),
                  Text(widget.desc,
                    textAlign: lang == 'ar' ? TextAlign.right : TextAlign.left,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15, height: 1.4,
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

import 'package:flutter/material.dart';
import 'package:engineering_platform/core/constants/colors.dart';
import 'package:engineering_platform/core/constants/translations.dart';
import 'package:engineering_platform/core/state/language_state.dart';
import 'package:engineering_platform/core/utils/responsive.dart';

class SelectionCard extends StatefulWidget {
  final String title;
  final String serviceId;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectionCard({
    super.key,
    required this.title,
    required this.serviceId,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<SelectionCard> createState() => _SelectionCardState();
}

class _SelectionCardState extends State<SelectionCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        transform: Matrix4.translationValues(0, isHovered ? -15.0 : 0.0, 0.0),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            height: Responsive.isMobile(context) ? 120 : 150,
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? AppColors.accent.withValues(alpha: 0.05)
                  : (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.white),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: (isHovered || widget.isSelected)
                    ? AppColors.accent.withValues(alpha: 0.3)
                    : Colors.transparent,
                width: 2,
              ),
              boxShadow: (isHovered || widget.isSelected)
                  ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.15), blurRadius: 40, offset: const Offset(0, 20))]
                  : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Stack(
              children: [
                if (isHovered)
                  Positioned(
                    top: -50, right: -50,
                    child: Container(
                      width: 150, height: 150,
                      decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.05), shape: BoxShape.circle),
                    ),
                  ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (isHovered || widget.isSelected) ? AppColors.accent : AppColors.greyLight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_getIconForService(widget.serviceId), size: 20,
                          color: (isHovered || widget.isSelected) ? Colors.white : AppColors.accent),
                      ),
                      const SizedBox(height: 8),
                      Text(widget.title, textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppColors.textSecondary)),
                      const SizedBox(height: 16),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: isHovered ? 1.0 : 0.0,
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(AppTranslations.get('select_btn', clientLanguageNotifier.value),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent)),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 18, color: AppColors.accent),
                        ]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForService(String id) {
    switch (id) {
      case 'struct':      return Icons.architecture_rounded;
      case 'construction': return Icons.foundation_rounded;
      case 'supervision':  return Icons.assignment_turned_in_rounded;
      default:             return Icons.engineering_rounded;
    }
  }
}

import 'package:flutter/material.dart';

import '../core/app_theme.dart';

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({
    super.key,
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: selected ? AppColors.selected : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(icon, color: selected ? AppColors.primary : AppColors.muted),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      softWrap: true,
                      style: const TextStyle(color: AppColors.muted, height: 1.35),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Padding(
                  padding: EdgeInsets.only(left: 8, top: 2),
                  child: Icon(Icons.check_circle, color: AppColors.primary),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

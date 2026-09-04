import 'package:flutter/material.dart';

import '../core/app_theme.dart';

class StepPanel extends StatelessWidget {
  const StepPanel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.action,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(subtitle, style: const TextStyle(color: AppColors.muted)),
                ],
              ),
            ),
            if (action != null) action!,
          ],
        ),
        const SizedBox(height: 18),
        child,
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/onboarding_step.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.step,
    required this.child,
    required this.canBack,
    required this.onBack,
  });

  final OnboardingStep step;
  final Widget child;
  final bool canBack;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  AppHeader(step: step, canBack: canBack, onBack: onBack),
                  const SizedBox(height: 18),
                  Expanded(child: SingleChildScrollView(child: child)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.step,
    required this.canBack,
    required this.onBack,
  });

  final OnboardingStep step;
  final bool canBack;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final progress = step.index / (OnboardingStep.values.length - 1);
    return Column(
      children: [
        Row(
          children: [
            IconButton(onPressed: canBack ? onBack : null, icon: const Icon(Icons.arrow_back)),
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.verified_user_outlined, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PartnerDesk', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  Text('Vendor registration and activation', style: TextStyle(color: AppColors.muted)),
                ],
              ),
            ),
            Text(step.label, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            backgroundColor: AppColors.track,
          ),
        ),
      ],
    );
  }
}

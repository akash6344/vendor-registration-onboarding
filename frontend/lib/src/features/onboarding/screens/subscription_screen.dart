import 'package:flutter/material.dart';

import '../../../models/catalog.dart';
import '../../../models/vendor_state.dart';
import '../../../widgets/choice_card.dart';
import '../../../widgets/responsive_grid.dart';
import '../../../widgets/step_panel.dart';
import '../../../widgets/validation.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({
    super.key,
    required this.data,
    required this.vendor,
    required this.onNext,
  });

  final AppData data;
  final VendorState vendor;
  final ValueChanged<VendorState> onNext;

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String? selectedPlanId;

  @override
  void initState() {
    super.initState();
    selectedPlanId = widget.vendor.selectedPlanId;
  }

  @override
  Widget build(BuildContext context) {
    return StepPanel(
      title: 'Choose a subscription',
      subtitle: 'Select a plan, then continue. Plans are backend-driven and editable without app changes.',
      action: FilledButton.icon(
        onPressed: _continue,
        icon: const Icon(Icons.arrow_forward),
        label: const Text('Continue'),
      ),
      child: ResponsiveGrid(
        children: widget.data.plans.map((plan) {
          return ChoiceCard(
            selected: selectedPlanId == plan.id,
            icon: Icons.workspace_premium_outlined,
            title: plan.name,
            subtitle: 'Rs ${plan.price} / ${plan.durationDays} days\n${plan.features.join(' · ')}',
            onTap: () => setState(() => selectedPlanId = plan.id),
          );
        }).toList(),
      ),
    );
  }

  void _continue() {
    final planId = selectedPlanId;
    if (planId == null) {
      showValidationMessage(context, 'Please select a subscription plan to continue.');
      return;
    }
    widget.onNext(widget.vendor.copyWith(selectedPlanId: planId));
  }
}

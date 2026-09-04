import 'package:flutter/material.dart';

import '../../../models/vendor_state.dart';
import '../../../widgets/choice_card.dart';
import '../../../widgets/responsive_grid.dart';
import '../../../widgets/step_panel.dart';
import '../../../widgets/validation.dart';

class VendorTypeScreen extends StatefulWidget {
  const VendorTypeScreen({super.key, required this.vendor, required this.onNext});

  final VendorState vendor;
  final ValueChanged<VendorState> onNext;

  @override
  State<VendorTypeScreen> createState() => _VendorTypeScreenState();
}

class _VendorTypeScreenState extends State<VendorTypeScreen> {
  String? selectedType;

  @override
  void initState() {
    super.initState();
    selectedType = widget.vendor.vendorType;
  }

  @override
  Widget build(BuildContext context) {
    return StepPanel(
      title: 'Select vendor type',
      subtitle: 'Individual vendors can select one subcategory. Businesses can select multiple.',
      action: FilledButton.icon(
        onPressed: _continue,
        icon: const Icon(Icons.arrow_forward),
        label: const Text('Continue'),
      ),
      child: ResponsiveGrid(
        children: [
          ChoiceCard(
            selected: selectedType == 'INDIVIDUAL',
            icon: Icons.person_outline,
            title: 'Individual',
            subtitle: 'Best for a solo service partner.',
            onTap: () => setState(() => selectedType = 'INDIVIDUAL'),
          ),
          ChoiceCard(
            selected: selectedType == 'BUSINESS',
            icon: Icons.storefront_outlined,
            title: 'Business',
            subtitle: 'Best for teams or registered service businesses.',
            onTap: () => setState(() => selectedType = 'BUSINESS'),
          ),
        ],
      ),
    );
  }

  void _continue() {
    final type = selectedType;
    if (type == null) {
      showValidationMessage(context, 'Please select a vendor type to continue.');
      return;
    }
    widget.onNext(
      widget.vendor.copyWith(
        vendorType: type,
        subcategoryIds: [],
        serviceIds: [],
        serviceDetails: {},
      ),
    );
  }
}

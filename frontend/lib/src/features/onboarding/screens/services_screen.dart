import 'package:flutter/material.dart';

import '../../../models/catalog.dart';
import '../../../models/vendor_state.dart';
import '../../../widgets/choice_card.dart';
import '../../../widgets/responsive_grid.dart';
import '../../../widgets/step_panel.dart';
import '../../../widgets/validation.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({
    super.key,
    required this.data,
    required this.vendor,
    required this.onNext,
  });

  final AppData data;
  final VendorState vendor;
  final ValueChanged<VendorState> onNext;

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  late Set<String> selected;

  @override
  void initState() {
    super.initState();
    selected = widget.vendor.serviceIds.toSet();
  }

  @override
  Widget build(BuildContext context) {
    final services = widget.data.servicesFor(widget.vendor.subcategoryIds);
    return StepPanel(
      title: 'Select services',
      subtitle: 'Choose at least one service. You will set prices and media on the next screen.',
      action: FilledButton.icon(
        onPressed: _continue,
        icon: const Icon(Icons.arrow_forward),
        label: const Text('Continue'),
      ),
      child: ResponsiveGrid(
        children: services.map((service) {
          final isSelected = selected.contains(service.id);
          return ChoiceCard(
            selected: isSelected,
            icon: Icons.design_services_outlined,
            title: service.name,
            subtitle: service.subcategoryName,
            onTap: () => setState(() => isSelected ? selected.remove(service.id) : selected.add(service.id)),
          );
        }).toList(),
      ),
    );
  }

  void _continue() {
    if (selected.isEmpty) {
      showValidationMessage(context, 'Please select at least one service.');
      return;
    }
    widget.onNext(widget.vendor.copyWith(serviceIds: selected.toList()));
  }
}

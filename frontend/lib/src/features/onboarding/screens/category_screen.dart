import 'package:flutter/material.dart';

import '../../../models/catalog.dart';
import '../../../models/vendor_state.dart';
import '../../../widgets/choice_card.dart';
import '../../../widgets/responsive_grid.dart';
import '../../../widgets/step_panel.dart';
import '../../../widgets/validation.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({
    super.key,
    required this.data,
    required this.vendor,
    required this.onNext,
  });

  final AppData data;
  final VendorState vendor;
  final ValueChanged<VendorState> onNext;

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String? selectedId;

  @override
  void initState() {
    super.initState();
    selectedId = widget.vendor.mainCategoryId;
  }

  @override
  Widget build(BuildContext context) {
    return StepPanel(
      title: 'Choose a main category',
      subtitle: 'Select one category, then continue. Categories come from backend seed data.',
      action: FilledButton.icon(
        onPressed: _continue,
        icon: const Icon(Icons.arrow_forward),
        label: const Text('Continue'),
      ),
      child: ResponsiveGrid(
        children: widget.data.categories.map((category) {
          final selected = selectedId == category.id;
          return ChoiceCard(
            selected: selected,
            icon: Icons.home_repair_service_outlined,
            title: category.name,
            subtitle: category.description,
            onTap: () => setState(() => selectedId = category.id),
          );
        }).toList(),
      ),
    );
  }

  void _continue() {
    final id = selectedId;
    if (id == null) {
      showValidationMessage(context, 'Please select a main category to continue.');
      return;
    }
    widget.onNext(
      widget.vendor.copyWith(
        mainCategoryId: id,
        subcategoryIds: [],
        serviceIds: [],
        serviceDetails: {},
      ),
    );
  }
}

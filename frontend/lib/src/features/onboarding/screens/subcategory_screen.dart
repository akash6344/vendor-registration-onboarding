import 'package:flutter/material.dart';

import '../../../models/catalog.dart';
import '../../../models/vendor_state.dart';
import '../../../widgets/choice_card.dart';
import '../../../widgets/responsive_grid.dart';
import '../../../widgets/step_panel.dart';
import '../../../widgets/validation.dart';

class SubcategoryScreen extends StatefulWidget {
  const SubcategoryScreen({
    super.key,
    required this.data,
    required this.vendor,
    required this.onNext,
  });

  final AppData data;
  final VendorState vendor;
  final ValueChanged<VendorState> onNext;

  @override
  State<SubcategoryScreen> createState() => _SubcategoryScreenState();
}

class _SubcategoryScreenState extends State<SubcategoryScreen> {
  late Set<String> selected;

  @override
  void initState() {
    super.initState();
    selected = widget.vendor.subcategoryIds.toSet();
  }

  @override
  Widget build(BuildContext context) {
    final subcategories = widget.data.category(widget.vendor.mainCategoryId)?.subcategories ?? [];
    final isBusiness = widget.vendor.vendorType == 'BUSINESS';

    return StepPanel(
      title: 'Select subcategories',
      subtitle: isBusiness ? 'Select one or more subcategories your business supports.' : 'Select the one subcategory you personally provide.',
      action: FilledButton.icon(
        onPressed: _continue,
        icon: const Icon(Icons.arrow_forward),
        label: const Text('Continue'),
      ),
      child: ResponsiveGrid(
        children: subcategories.map((subcategory) {
          final isSelected = selected.contains(subcategory.id);
          return ChoiceCard(
            selected: isSelected,
            icon: Icons.category_outlined,
            title: subcategory.name,
            subtitle: '${subcategory.services.length} services',
            onTap: () {
              setState(() {
                if (isBusiness) {
                  isSelected ? selected.remove(subcategory.id) : selected.add(subcategory.id);
                } else {
                  selected = {subcategory.id};
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }

  void _continue() {
    final isBusiness = widget.vendor.vendorType == 'BUSINESS';
    if (selected.isEmpty) {
      showValidationMessage(
        context,
        isBusiness
            ? 'Please select at least one subcategory.'
            : 'Please select one subcategory.',
      );
      return;
    }
    widget.onNext(
      widget.vendor.copyWith(
        subcategoryIds: selected.toList(),
        serviceIds: [],
        serviceDetails: {},
      ),
    );
  }
}

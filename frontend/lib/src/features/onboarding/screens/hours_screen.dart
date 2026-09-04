import 'package:flutter/material.dart';

import '../../../models/vendor_state.dart';
import '../../../widgets/section_card.dart';
import '../../../widgets/step_panel.dart';

class HoursScreen extends StatefulWidget {
  const HoursScreen({super.key, required this.vendor, required this.onNext});

  final VendorState vendor;
  final ValueChanged<VendorState> onNext;

  @override
  State<HoursScreen> createState() => _HoursScreenState();
}

class _HoursScreenState extends State<HoursScreen> {
  late final TextEditingController startController;
  late final TextEditingController endController;
  late bool available;

  @override
  void initState() {
    super.initState();
    startController = TextEditingController(text: widget.vendor.workingHours['startTime'] ?? '09:00');
    endController = TextEditingController(text: widget.vendor.workingHours['endTime'] ?? '18:00');
    available = widget.vendor.workingHours['available'] != false;
  }

  @override
  Widget build(BuildContext context) {
    return StepPanel(
      title: 'Working hours',
      subtitle: 'Set operating hours and business availability.',
      action: FilledButton.icon(
        onPressed: _continue,
        icon: const Icon(Icons.arrow_forward),
        label: const Text('Continue'),
      ),
      child: SectionCard(
        title: 'Availability',
        children: [
          Wrap(
            spacing: 14,
            runSpacing: 14,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 180,
                child: TextField(
                  controller: startController,
                  decoration: const InputDecoration(labelText: 'Start time'),
                ),
              ),
              SizedBox(
                width: 180,
                child: TextField(
                  controller: endController,
                  decoration: const InputDecoration(labelText: 'End time'),
                ),
              ),
              FilterChip(
                label: Text(available ? 'Available' : 'Unavailable'),
                selected: available,
                onSelected: (value) => setState(() => available = value),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _continue() {
    widget.onNext(
      widget.vendor.copyWith(
        workingHours: {
          'startTime': startController.text.trim(),
          'endTime': endController.text.trim(),
          'available': available,
        },
      ),
    );
  }
}

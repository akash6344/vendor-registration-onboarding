import 'package:flutter/material.dart';

import '../../../core/app_theme.dart';
import '../../../models/catalog.dart';
import '../../../models/vendor_state.dart';
import '../../../widgets/section_card.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    required this.data,
    required this.vendor,
    required this.onPay,
  });

  final AppData data;
  final VendorState vendor;
  final Future<void> Function() onPay;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool busy = false;

  @override
  Widget build(BuildContext context) {
    final plan = widget.data.plans.firstWhere((item) => item.id == widget.vendor.selectedPlanId);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: SectionCard(
          title: 'Payment summary',
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(plan.name, style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text(plan.description),
              trailing: Text('Rs ${plan.price}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            ),
            const Divider(),
            const Text(
              'Mock payment activates the vendor and locks onboarding screens after success.',
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: busy ? null : _pay,
              icon: const Icon(Icons.lock_outline),
              label: Text(busy ? 'Processing' : 'Pay Rs ${plan.price}'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pay() async {
    setState(() => busy = true);
    await widget.onPay();
  }
}

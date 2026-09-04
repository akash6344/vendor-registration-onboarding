import 'dart:async';

import 'package:flutter/material.dart';

import '../../../models/catalog.dart';
import '../../../models/dashboard.dart';
import '../../../models/vendor_state.dart';
import '../../../widgets/metric_card.dart';
import '../../../widgets/responsive_grid.dart';
import '../../../widgets/step_panel.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.vendor,
    required this.dashboard,
    required this.data,
    required this.onLoad,
  });

  final VendorState vendor;
  final Dashboard? dashboard;
  final AppData data;
  final Future<void> Function() onLoad;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.dashboard == null) unawaited(widget.onLoad());
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = widget.dashboard;
    return StepPanel(
      title: 'Vendor dashboard',
      subtitle: 'Account is active. Onboarding, verification, subscription, and payment routes are locked.',
      child: dashboard == null
          ? const Center(child: CircularProgressIndicator())
          : FieldGrid(
              children: [
                MetricCard(label: 'Account status', value: dashboard.accountStatus, icon: Icons.verified_outlined),
                MetricCard(label: 'Subscription', value: dashboard.planName ?? 'Active', icon: Icons.workspace_premium_outlined),
                MetricCard(label: 'Services', value: '${dashboard.serviceCount}', icon: Icons.design_services_outlined),
                MetricCard(label: 'Availability', value: dashboard.availability ? 'Available' : 'Unavailable', icon: Icons.schedule_outlined),
                MetricCard(label: 'Verification', value: dashboard.verificationStatus, icon: Icons.fact_check_outlined),
                MetricCard(label: 'Valid until', value: dashboard.validUntil?.split('T').first ?? '-', icon: Icons.event_outlined),
              ],
            ),
    );
  }
}

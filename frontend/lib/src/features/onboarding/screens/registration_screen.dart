import 'package:flutter/material.dart';

import '../../../data/api_client.dart';
import '../../../models/address_suggestion.dart';
import '../../../models/vendor_state.dart';
import '../../../widgets/responsive_grid.dart';
import '../../../widgets/section_card.dart';
import '../../../widgets/step_panel.dart';
import '../../../widgets/validation.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({
    super.key,
    required this.api,
    required this.vendor,
    required this.onNext,
  });

  final ApiClient api;
  final VendorState vendor;
  final ValueChanged<VendorState> onNext;

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  late final fields = {
    'firstName': TextEditingController(text: widget.vendor.personalInfo['firstName']),
    'lastName': TextEditingController(text: widget.vendor.personalInfo['lastName']),
    'email': TextEditingController(text: widget.vendor.personalInfo['email']),
    'mobile': TextEditingController(text: widget.vendor.personalInfo['mobile']),
    'alternateMobile': TextEditingController(text: widget.vendor.personalInfo['alternateMobile']),
    'fatherName': TextEditingController(text: widget.vendor.address['fatherName']),
    'fullAddress': TextEditingController(text: widget.vendor.address['fullAddress']),
    'street': TextEditingController(text: widget.vendor.address['street']),
    'district': TextEditingController(text: widget.vendor.address['district']),
    'city': TextEditingController(text: widget.vendor.address['city']),
    'state': TextEditingController(text: widget.vendor.address['state']),
    'pincode': TextEditingController(text: widget.vendor.address['pincode']),
    'radiusKm': TextEditingController(text: widget.vendor.address['radiusKm'] ?? '10'),
    'search': TextEditingController(),
  };

  List<AddressSuggestion> suggestions = [];

  @override
  Widget build(BuildContext context) {
    return StepPanel(
      title: 'Partner registration',
      subtitle: 'Capture personal details and the service area in one pass.',
      action: FilledButton.icon(
        onPressed: _continue,
        icon: const Icon(Icons.arrow_forward),
        label: const Text('Continue'),
      ),
      child: Column(
        children: [
          SectionCard(
            title: 'Personal information',
            children: [
              FieldGrid(
                children: [
                  _input('firstName', 'First name'),
                  _input('lastName', 'Last name'),
                  _input('email', 'Email address'),
                  _input('mobile', 'Mobile number'),
                  _input('alternateMobile', 'Alternative mobile number'),
                ],
              ),
            ],
          ),
          SectionCard(
            title: 'Business and service area',
            children: [
              TextField(
                controller: fields['search'],
                decoration: const InputDecoration(labelText: 'Search address'),
                onChanged: _searchAddress,
              ),
              if (suggestions.isNotEmpty)
                ...suggestions.map(
                  (item) => ListTile(
                    title: Text(item.label),
                    leading: const Icon(Icons.place_outlined),
                    onTap: () => _selectAddress(item),
                  ),
                ),
              const SizedBox(height: 12),
              FieldGrid(
                children: [
                  _input('fatherName', "Father's name"),
                  _input('fullAddress', 'Full address'),
                  _input('street', 'Street name'),
                  _input('district', 'District name'),
                  _input('city', 'City'),
                  _input('state', 'State'),
                  _input('pincode', 'Pincode'),
                  _input('radiusKm', 'Service radius (km)'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _input(String key, String label) {
    return TextField(
      controller: fields[key],
      decoration: InputDecoration(labelText: label),
      onChanged: (_) => setState(() {}),
    );
  }

  bool get _valid {
    return ['firstName', 'lastName', 'email', 'mobile', 'fatherName', 'fullAddress', 'city', 'state', 'pincode', 'radiusKm']
        .every((key) => fields[key]!.text.trim().isNotEmpty);
  }

  Future<void> _searchAddress(String value) async {
    if (value.trim().length < 3) {
      setState(() => suggestions = []);
      return;
    }
    suggestions = await widget.api.searchAddresses(value);
    if (mounted) setState(() {});
  }

  void _selectAddress(AddressSuggestion item) {
    fields['fullAddress']!.text = item.fullAddress;
    fields['city']!.text = item.city;
    fields['state']!.text = item.state;
    fields['pincode']!.text = item.pincode;
    fields['search']!.text = item.label;
    setState(() => suggestions = []);
  }

  void _continue() {
    if (!_valid) {
      showValidationMessage(context, 'Please fill all required registration fields.');
      return;
    }
    widget.onNext(
      widget.vendor.copyWith(
        personalInfo: {
          for (final key in ['firstName', 'lastName', 'email', 'mobile', 'alternateMobile'])
            key: fields[key]!.text.trim(),
        },
        address: {
          for (final key in ['fatherName', 'fullAddress', 'street', 'district', 'city', 'state', 'pincode', 'radiusKm'])
            key: fields[key]!.text.trim(),
        },
      ),
    );
  }
}

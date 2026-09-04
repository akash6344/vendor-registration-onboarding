import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../data/api_client.dart';
import '../../../models/vendor_state.dart';
import '../../../widgets/responsive_grid.dart';
import '../../../widgets/section_card.dart';
import '../../../widgets/step_panel.dart';
import '../../../widgets/upload_row.dart';
import '../../../widgets/validation.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({
    super.key,
    required this.vendor,
    required this.api,
    required this.token,
    required this.onChange,
    required this.onSubmit,
  });

  final VendorState vendor;
  final ApiClient api;
  final String token;
  final ValueChanged<VendorState> onChange;
  final Future<void> Function(VendorState vendor) onSubmit;

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  late Map<String, String> info;
  late Map<String, List<String>> docs;
  late Map<String, TextEditingController> controllers;
  bool busy = false;
  bool attempted = false;

  @override
  void initState() {
    super.initState();
    info = Map<String, String>.from(widget.vendor.businessInfo);
    docs = Map<String, List<String>>.from(widget.vendor.documents);
    controllers = {
      for (final key in _businessKeys) key: TextEditingController(text: info[key] ?? ''),
    };
  }

  @override
  Widget build(BuildContext context) {
    return StepPanel(
      title: 'Business verification',
      subtitle: 'Mandatory Aadhaar details and front/back documents are required for submission.',
      action: FilledButton.icon(
        onPressed: busy ? null : _submit,
        icon: const Icon(Icons.fact_check_outlined),
        label: Text(busy ? 'Submitting...' : 'Submit details'),
      ),
      child: Column(
        children: [
          SectionCard(
            title: 'Business information',
            children: [
              FieldGrid(
                children: _businessKeys
                    .map(
                      (key) => TextField(
                        controller: controllers[key],
                        decoration: InputDecoration(
                          labelText: _businessLabel(key),
                          errorText: attempted && key == 'aadhaar' && (info['aadhaar']?.isEmpty ?? true)
                              ? 'Aadhaar number is required'
                              : null,
                        ),
                        onChanged: (value) => _setInfo(key, value),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          SectionCard(
            title: 'Documents',
            children: [
              _upload('Aadhaar card front', 'aadhaarFront', required: true, type: FileType.image),
              _upload('Aadhaar card back', 'aadhaarBack', required: true, type: FileType.image),
              _upload('PAN card front', 'panFront', type: FileType.image),
              _upload('PAN card back', 'panBack', type: FileType.image),
              _upload('Current bill', 'currentBill', type: FileType.any),
              _upload('Face verification video', 'faceVideo', type: FileType.video),
              _upload('Address proof', 'addressProof', type: FileType.any),
            ],
          ),
        ],
      ),
    );
  }

  bool get _mandatoryDataPresent {
    return (docs['aadhaarFront']?.isNotEmpty ?? false) &&
        (docs['aadhaarBack']?.isNotEmpty ?? false) &&
        (info['aadhaar']?.isNotEmpty ?? false);
  }

  UploadRow _upload(String title, String key, {bool required = false, FileType type = FileType.any}) {
    return UploadRow(
      title: title,
      files: docs[key] ?? [],
      max: 1,
      required: required,
      fileType: type,
      api: widget.api,
      token: widget.token,
      onChanged: (files) => _setDoc(key, files),
    );
  }

  String _businessLabel(String key) {
    return {
      'pan': 'PAN card number',
      'aadhaar': 'Aadhaar number',
      'msme': 'MSME number',
      'usc': 'USC number',
      'currentBill': 'Current bill number',
      'otherProof': 'Other government proof',
    }[key]!;
  }

  void _setInfo(String key, String value) => setState(() => info[key] = value.trim());
  void _setDoc(String key, List<String> files) => setState(() => docs[key] = files);

  Future<void> _submit() async {
    setState(() => attempted = true);
    if (!_mandatoryDataPresent) {
      showValidationMessage(
        context,
        'Please enter Aadhaar number and upload Aadhaar front and back images.',
      );
      return;
    }
    final next = widget.vendor.copyWith(
      businessInfo: info,
      documents: docs,
      verificationStatus: 'UNDER_REVIEW',
    );
    widget.onChange(next);
    setState(() => busy = true);
    try {
      await widget.onSubmit(next);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}

const _businessKeys = ['pan', 'aadhaar', 'msme', 'usc', 'currentBill', 'otherProof'];

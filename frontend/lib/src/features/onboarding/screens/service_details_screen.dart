import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../data/api_client.dart';
import '../../../models/catalog.dart';
import '../../../models/service_detail.dart';
import '../../../models/vendor_state.dart';
import '../../../widgets/upload_row.dart';
import '../../../widgets/step_panel.dart';
import '../../../widgets/validation.dart';

class ServiceDetailsScreen extends StatefulWidget {
  const ServiceDetailsScreen({
    super.key,
    required this.data,
    required this.vendor,
    required this.api,
    required this.token,
    required this.onNext,
  });

  final AppData data;
  final VendorState vendor;
  final ApiClient api;
  final String token;
  final ValueChanged<VendorState> onNext;

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  final prices = <String, TextEditingController>{};
  late Map<String, ServiceDetail> details;
  bool attempted = false;

  @override
  void initState() {
    super.initState();
    details = Map<String, ServiceDetail>.from(widget.vendor.serviceDetails);
  }

  @override
  Widget build(BuildContext context) {
    final services = widget.data.servicesByIds(widget.vendor.serviceIds);
    for (final service in services) {
      details[service.id] ??= ServiceDetail.empty();
      prices[service.id] ??= TextEditingController(
        text: details[service.id]!.price == 0 ? '' : details[service.id]!.price.toStringAsFixed(0),
      );
    }

    return StepPanel(
      title: 'Add service details',
      subtitle: 'Each service needs pricing. Uploaded media is stored on the server disk.',
      action: FilledButton.icon(
        onPressed: _continue,
        icon: const Icon(Icons.arrow_forward),
        label: const Text('Continue'),
      ),
      child: Column(
        children: services
            .map(
              (service) => _ServiceEditor(
                service: service,
                detail: details[service.id]!,
                priceController: prices[service.id]!,
                api: widget.api,
                token: widget.token,
                showPriceError: attempted && details[service.id]!.price <= 0,
                onChanged: (detail) => setState(() => details[service.id] = detail),
              ),
            )
            .toList(),
      ),
    );
  }

  bool get _valid => details.values.every((detail) => detail.price > 0);

  void _continue() {
    setState(() => attempted = true);
    if (!_valid) {
      showValidationMessage(context, 'Please enter a valid price for every selected service.');
      return;
    }
    widget.onNext(widget.vendor.copyWith(serviceDetails: details));
  }
}

class _ServiceEditor extends StatelessWidget {
  const _ServiceEditor({
    required this.service,
    required this.detail,
    required this.priceController,
    required this.api,
    required this.token,
    required this.showPriceError,
    required this.onChanged,
  });

  final ServiceItem service;
  final ServiceDetail detail;
  final TextEditingController priceController;
  final ApiClient api;
  final String token;
  final bool showPriceError;
  final ValueChanged<ServiceDetail> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(service.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              Wrap(
                runSpacing: 12,
                spacing: 12,
                children: [
                  SizedBox(
                    width: 220,
                    child: TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Price / amount',
                        errorText: showPriceError ? 'Price is required' : null,
                      ),
                      onChanged: (value) => onChanged(detail.copyWith(price: double.tryParse(value) ?? 0)),
                    ),
                  ),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'FIXED', label: Text('Fixed')),
                      ButtonSegment(value: 'NEGOTIABLE', label: Text('Negotiable')),
                    ],
                    selected: {detail.pricingType},
                    onSelectionChanged: (value) => onChanged(detail.copyWith(pricingType: value.first)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              UploadRow(
                title: 'Images',
                files: detail.images,
                max: 2,
                fileType: FileType.image,
                api: api,
                token: token,
                onChanged: (files) => onChanged(detail.copyWith(images: files)),
              ),
              UploadRow(
                title: 'Video',
                files: detail.videos,
                max: 1,
                fileType: FileType.video,
                api: api,
                token: token,
                onChanged: (files) => onChanged(detail.copyWith(videos: files)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

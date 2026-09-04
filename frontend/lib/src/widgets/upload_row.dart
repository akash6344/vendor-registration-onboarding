import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../data/api_client.dart';
import 'validation.dart';

class UploadRow extends StatefulWidget {
  const UploadRow({
    super.key,
    required this.title,
    required this.files,
    required this.max,
    required this.onChanged,
    required this.api,
    required this.token,
    this.fileType = FileType.any,
    this.required = false,
  });

  final String title;
  final List<String> files;
  final int max;
  final ValueChanged<List<String>> onChanged;
  final ApiClient api;
  final String token;
  final FileType fileType;
  final bool required;

  @override
  State<UploadRow> createState() => _UploadRowState();
}

class _UploadRowState extends State<UploadRow> {
  bool uploading = false;

  @override
  Widget build(BuildContext context) {
    final missing = widget.required && widget.files.isEmpty;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: widget.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                    children: [
                      if (widget.required)
                        const TextSpan(text: ' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: [
                    ...widget.files.map(
                      (file) => InputChip(
                        label: Text(_shortName(file), overflow: TextOverflow.ellipsis),
                        avatar: const Icon(Icons.sd_storage_outlined, size: 18),
                        onDeleted: uploading
                            ? null
                            : () => widget.onChanged(widget.files.where((item) => item != file).toList()),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: uploading || widget.files.length >= widget.max ? null : _upload,
                      icon: uploading
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.upload_file),
                      label: Text(uploading ? 'Uploading...' : 'Upload'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (missing)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text('Required upload', style: TextStyle(color: Colors.red, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Future<void> _upload() async {
    setState(() => uploading = true);
    try {
      final uploaded = await widget.api.pickAndUpload(widget.token, type: widget.fileType);
      if (uploaded == null) return;
      widget.onChanged([...widget.files, uploaded.storedPath]);
    } catch (error) {
      if (mounted) {
        showValidationMessage(context, error.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => uploading = false);
    }
  }

  String _shortName(String path) {
    final parts = path.split('/');
    return parts.isEmpty ? path : parts.last;
  }
}

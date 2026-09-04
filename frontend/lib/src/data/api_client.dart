import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

import '../models/address_suggestion.dart';
import '../models/catalog.dart';
import '../models/dashboard.dart';
import '../models/vendor_state.dart';

class ApiClient {
  ApiClient(this.baseUrl);

  final String baseUrl;

  Future<AppData> loadAppData() async {
    final categories = await _get('/categories');
    final plans = await _get('/subscription-plans');
    return AppData(
      categories: (categories['categories'] as List).map((item) => Category.fromJson(item)).toList(),
      plans: (plans['plans'] as List).map((item) => Plan.fromJson(item)).toList(),
    );
  }

  Future<String> sendOtp(String contact) async {
    final json = await _post('/auth/send-otp', {'contact': contact});
    return json['devOtp'];
  }

  Future<AuthResult> verifyOtp(String contact, String otp) async {
    final json = await _post('/auth/verify-otp', {'contact': contact, 'otp': otp});
    return AuthResult(json['token'], VendorState.fromJson(json['vendor']));
  }

  Future<List<AddressSuggestion>> searchAddresses(String query) async {
    final json = await _get('/addresses/search?q=${Uri.encodeQueryComponent(query)}');
    return (json['addresses'] as List).map((item) => AddressSuggestion.fromJson(item)).toList();
  }

  Future<VendorState> saveOnboarding(String token, VendorState vendor) async {
    final json = await _put('/vendors/me/onboarding', vendor.toJson(), token: token);
    return VendorState.fromJson(json['vendor']);
  }

  Future<VendorState> submitVerification(String token) async {
    final json = await _post('/vendors/me/verification/submit', {}, token: token);
    return VendorState.fromJson(json['vendor']);
  }

  Future<PaymentResult> mockPayment(String token, String planId) async {
    final json = await _post('/vendors/me/payments/mock', {'planId': planId}, token: token);
    return PaymentResult(
      VendorState.fromJson(json['vendor']),
      Dashboard.fromJson(json['dashboard']),
    );
  }

  Future<Dashboard> dashboard(String token) async {
    final json = await _get('/vendors/me/dashboard', token: token);
    return Dashboard.fromJson(json['dashboard']);
  }

  Future<UploadedFile> uploadFile(String token, {required String fileName, required List<int> bytes, String? mimeType}) async {
    final json = await _post(
      '/vendors/me/uploads',
      {
        'fileName': fileName,
        'mimeType': mimeType,
        'dataBase64': base64Encode(bytes),
      },
      token: token,
    );
    return UploadedFile.fromJson(json);
  }

  Future<UploadedFile?> pickAndUpload(String token, {FileType type = FileType.any}) async {
    final result = await FilePicker.platform.pickFiles(
      type: type,
      withData: true,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return null;
    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      throw Exception('Could not read the selected file');
    }
    return uploadFile(
      token,
      fileName: file.name,
      bytes: bytes,
      mimeType: file.extension == null ? null : _mimeForExtension(file.extension!),
    );
  }

  Future<Map<String, dynamic>> _get(String path, {String? token}) async {
    final response = await http.get(Uri.parse('$baseUrl$path'), headers: _headers(token));
    return _decode(response);
  }

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body, {String? token}) async {
    final response = await http.post(Uri.parse('$baseUrl$path'), headers: _headers(token), body: jsonEncode(body));
    return _decode(response);
  }

  Future<Map<String, dynamic>> _put(String path, Map<String, dynamic> body, {String? token}) async {
    final response = await http.put(Uri.parse('$baseUrl$path'), headers: _headers(token), body: jsonEncode(body));
    return _decode(response);
  }

  Map<String, String> _headers(String? token) {
    return {
      'content-type': 'application/json',
      if (token != null) 'authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _decode(http.Response response) {
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400) throw Exception(json['error'] ?? 'Request failed');
    return json;
  }

  String _mimeForExtension(String extension) {
    return switch (extension.toLowerCase()) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      'pdf' => 'application/pdf',
      'mp4' => 'video/mp4',
      'mov' => 'video/quicktime',
      _ => 'application/octet-stream',
    };
  }
}

class UploadedFile {
  UploadedFile({
    required this.fileName,
    required this.storedPath,
    required this.url,
    required this.size,
  });

  final String fileName;
  final String storedPath;
  final String url;
  final int size;

  factory UploadedFile.fromJson(Map<String, dynamic> json) {
    return UploadedFile(
      fileName: json['fileName'] as String,
      storedPath: json['storedPath'] as String,
      url: json['url'] as String,
      size: json['size'] as int? ?? 0,
    );
  }

  String get label {
    if (kIsWeb) return fileName;
    return fileName;
  }
}

class AuthResult {
  AuthResult(this.token, this.vendor);

  final String token;
  final VendorState vendor;
}

class PaymentResult {
  PaymentResult(this.vendor, this.dashboard);

  final VendorState vendor;
  final Dashboard dashboard;
}

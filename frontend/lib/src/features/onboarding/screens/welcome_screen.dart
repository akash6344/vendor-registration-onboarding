import 'package:flutter/material.dart';

import '../../../core/app_theme.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({
    super.key,
    required this.onSendOtp,
    required this.onVerify,
  });

  final Future<String> Function(String contact) onSendOtp;
  final Future<void> Function(String contact, String otp) onVerify;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final contact = TextEditingController();
  final otp = TextEditingController();
  String? devOtp;
  bool sent = false;
  bool busy = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Start vendor onboarding', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                const Text(
                  'Use your mobile number or email address to receive a one-time password.',
                  style: TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: contact,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Mobile number or email'),
                ),
                if (sent) ...[
                  const SizedBox(height: 14),
                  TextField(
                    controller: otp,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'OTP',
                      helperText: devOtp == null ? null : 'Development OTP: $devOtp',
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: busy ? null : _submit,
                  icon: Icon(sent ? Icons.login : Icons.sms_outlined),
                  label: Text(sent ? 'Verify OTP' : 'Send OTP'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (contact.text.trim().isEmpty) return _snack('Enter a mobile number or email');
    setState(() => busy = true);
    try {
      if (!sent) {
        devOtp = await widget.onSendOtp(contact.text.trim());
        setState(() => sent = true);
      } else {
        await widget.onVerify(contact.text.trim(), otp.text.trim());
      }
    } catch (error) {
      _snack(error.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

import 'dart:async';

import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/onboarding_step.dart';
import '../data/api_client.dart';
import '../features/onboarding/screens/category_screen.dart';
import '../features/onboarding/screens/dashboard_screen.dart';
import '../features/onboarding/screens/hours_screen.dart';
import '../features/onboarding/screens/payment_screen.dart';
import '../features/onboarding/screens/registration_screen.dart';
import '../features/onboarding/screens/service_details_screen.dart';
import '../features/onboarding/screens/services_screen.dart';
import '../features/onboarding/screens/subcategory_screen.dart';
import '../features/onboarding/screens/subscription_screen.dart';
import '../features/onboarding/screens/vendor_type_screen.dart';
import '../features/onboarding/screens/verification_screen.dart';
import '../features/onboarding/screens/welcome_screen.dart';
import '../models/catalog.dart';
import '../models/dashboard.dart';
import '../models/vendor_state.dart';
import '../widgets/app_shell.dart';
import '../widgets/error_state.dart';

const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:4000');

class VendorOnboardingApp extends StatefulWidget {
  const VendorOnboardingApp({super.key});

  @override
  State<VendorOnboardingApp> createState() => _VendorOnboardingAppState();
}

class _VendorOnboardingAppState extends State<VendorOnboardingApp> {
  final ApiClient api = ApiClient(apiBaseUrl);

  AppData? data;
  Dashboard? dashboard;
  VendorState vendor = VendorState.empty();
  OnboardingStep step = OnboardingStep.welcome;
  String? token;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vendor Onboarding',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: loading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : AppShell(
              step: step,
              canBack: step.index > 0 && !vendor.isActive,
              onBack: _goBack,
              child: _screenForStep(),
            ),
    );
  }

  Future<void> _loadData() async {
    try {
      final next = await api.loadAppData();
      setState(() => data = next);
    } finally {
      setState(() => loading = false);
    }
  }

  Widget _screenForStep() {
    final appData = data;
    if (appData == null) return ErrorState(onRetry: _loadData);

    if (vendor.isActive) {
      return DashboardScreen(vendor: vendor, dashboard: dashboard, data: appData, onLoad: _loadDashboard);
    }

    return switch (step) {
      OnboardingStep.welcome => WelcomeScreen(onSendOtp: api.sendOtp, onVerify: _verifyOtp),
      OnboardingStep.category => CategoryScreen(data: appData, vendor: vendor, onNext: (next) => _updateVendor(next, nextStep: OnboardingStep.vendorType)),
      OnboardingStep.vendorType => VendorTypeScreen(vendor: vendor, onNext: (next) => _updateVendor(next, nextStep: OnboardingStep.subcategories)),
      OnboardingStep.subcategories => SubcategoryScreen(data: appData, vendor: vendor, onNext: (next) => _updateVendor(next, nextStep: OnboardingStep.services)),
      OnboardingStep.services => ServicesScreen(data: appData, vendor: vendor, onNext: (next) => _updateVendor(next, nextStep: OnboardingStep.serviceDetails)),
      OnboardingStep.serviceDetails => ServiceDetailsScreen(
            data: appData,
            vendor: vendor,
            api: api,
            token: token ?? '',
            onNext: (next) => _updateVendor(next, nextStep: OnboardingStep.registration),
          ),
      OnboardingStep.registration => RegistrationScreen(api: api, vendor: vendor, onNext: (next) => _updateVendor(next, nextStep: OnboardingStep.hours)),
      OnboardingStep.hours => HoursScreen(vendor: vendor, onNext: (next) => _updateVendor(next, nextStep: OnboardingStep.verification)),
      OnboardingStep.verification => VerificationScreen(
            vendor: vendor,
            api: api,
            token: token ?? '',
            onChange: _updateVendor,
            onSubmit: _submitVerification,
          ),
      OnboardingStep.subscription => SubscriptionScreen(data: appData, vendor: vendor, onNext: (next) => _updateVendor(next, nextStep: OnboardingStep.payment)),
      OnboardingStep.payment => PaymentScreen(data: appData, vendor: vendor, onPay: _pay),
      OnboardingStep.dashboard => DashboardScreen(vendor: vendor, dashboard: dashboard, data: appData, onLoad: _loadDashboard),
    };
  }

  void _updateVendor(VendorState next, {OnboardingStep? nextStep}) {
    setState(() {
      vendor = next;
      if (nextStep != null) step = nextStep;
    });
    final currentToken = token;
    if (currentToken != null && step != OnboardingStep.welcome && step != OnboardingStep.dashboard) {
      final persisted = vendor.copyWith(currentStep: step.name.toUpperCase());
      unawaited(api.saveOnboarding(currentToken, persisted));
    }
  }

  Future<void> _verifyOtp(String contact, String otp) async {
    final result = await api.verifyOtp(contact, otp);
    setState(() {
      token = result.token;
      vendor = result.vendor;
      step = vendor.isActive ? OnboardingStep.dashboard : OnboardingStep.category;
    });
    if (vendor.isActive) await _loadDashboard();
  }

  Future<void> _submitVerification(VendorState verifiedVendor) async {
    final currentToken = token;
    if (currentToken == null) return;
    await api.saveOnboarding(currentToken, verifiedVendor);
    final next = await api.submitVerification(currentToken);
    _updateVendor(next, nextStep: OnboardingStep.subscription);
  }

  Future<void> _pay() async {
    final currentToken = token;
    final planId = vendor.selectedPlanId;
    if (currentToken == null || planId == null) return;
    final result = await api.mockPayment(currentToken, planId);
    setState(() {
      vendor = result.vendor;
      dashboard = result.dashboard;
      step = OnboardingStep.dashboard;
    });
  }

  Future<void> _loadDashboard() async {
    final currentToken = token;
    if (currentToken == null) return;
    final next = await api.dashboard(currentToken);
    setState(() => dashboard = next);
  }

  void _goBack() {
    if (vendor.isActive || step.index == 0) return;
    setState(() => step = OnboardingStep.values[step.index - 1]);
  }
}

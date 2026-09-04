enum OnboardingStep {
  welcome('Welcome'),
  category('Category'),
  vendorType('Vendor Type'),
  subcategories('Subcategories'),
  services('Services'),
  serviceDetails('Service Details'),
  registration('Registration'),
  hours('Hours'),
  verification('Verification'),
  subscription('Subscription'),
  payment('Payment'),
  dashboard('Dashboard');

  const OnboardingStep(this.label);

  final String label;
}

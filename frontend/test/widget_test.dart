import 'package:flutter_test/flutter_test.dart';
import 'package:vendor_onboarding/src/app/vendor_onboarding_app.dart';

void main() {
  testWidgets('renders onboarding shell', (tester) async {
    await tester.pumpWidget(const VendorOnboardingApp());
    await tester.pump();

    expect(find.text('PartnerDesk'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/screens/booking/manual_booking_screen.dart';

void main() {
  testWidgets('ManualBookingScreen displays key form fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: ManualBookingScreen(tripId: 'test-trip-id')),
    );

    // Wait for async operations to complete
    await tester.pumpAndSettle();

    // Verify key widgets are present
    expect(find.text('Add Manual Booking'), findsOneWidget);
    expect(find.text('Booking Type'), findsOneWidget);
    expect(find.text('Title'), findsOneWidget);
    expect(find.byType(Form), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
  });
}

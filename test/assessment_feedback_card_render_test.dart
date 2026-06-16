import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/bookings/booking_dto.dart';
import 'package:portfolio_mobile_app/features/profile/presentation/widgets/assessment_feedback_card.dart';

void main() {
  testWidgets('AssessmentFeedbackCard paints its content', (tester) async {
    final booking = BookingDto(
      bookingId: '1',
      creationDate: DateTime(2026, 6, 7),
      schedulingDate: DateTime(2026, 6, 9, 9),
      state: 'COMPLETED',
      duration: 60,
      memberRut: '',
      memberName: 'Alex Torres Vega',
      memberPhone: '',
      locationId: 1,
      locationName: 'Downtown Gym',
      trainerName: 'Jordan Pike',
      serviceName: 'Assessment Session',
      disciplineName: 'Yoga',
      notes: 'Great progress on mobility.',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: Brightness.dark),
        home: Scaffold(
          body: AssessmentFeedbackCard(booking: booking, initiallyExpanded: true),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Jordan Pike'), findsOneWidget);
    expect(find.textContaining('Assessment Session'), findsOneWidget);
    expect(find.text('Great progress on mobility.'), findsOneWidget);
  });
}

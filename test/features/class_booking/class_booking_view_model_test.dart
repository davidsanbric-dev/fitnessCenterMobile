import 'dart:async';

import 'package:fitnesscenter_mobile/app/core/exceptions/api_exception.dart';
import 'package:fitnesscenter_mobile/features/class_booking/presentation/viewmodels/class_booking_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fakes.dart';

void main() {
  late FakeClassBookingRepository repository;
  late FakeAgendaRefreshPort agenda;
  late ClassBookingViewModel viewModel;

  setUp(() {
    repository = FakeClassBookingRepository();
    agenda = FakeAgendaRefreshPort();
    viewModel = ClassBookingViewModel(
      repository: repository,
      agendaRefreshPort: agenda,
    );
  });

  group('bookStandard', () {
    test('books the slot and then refreshes the agenda', () async {
      final slot = buildSlot();

      await viewModel.bookStandard(slot: slot);

      expect(repository.standardBookings, [slot]);
      expect(agenda.refreshCount, 1);
      expect(viewModel.standardBookingError, isNull);
    });

    test('notifies listeners around the in-flight window', () async {
      var notifications = 0;
      viewModel.addListener(() => notifications++);

      await viewModel.bookStandard(slot: buildSlot());

      // One notify when the booking starts, one when it settles, so a
      // ListenableBuilder can show and then clear a spinner.
      expect(notifications, 2);
    });

    test('ignores a second call while one is already in flight', () async {
      final gate = Completer<void>();
      repository.gate = gate;

      final first = viewModel.bookStandard(slot: buildSlot());
      final second = viewModel.bookStandard(slot: buildSlot());

      gate.complete();
      await Future.wait([first, second]);

      // The re-entrancy guard means the repository saw exactly one booking,
      // which is what stops a double tap creating two reservations.
      expect(repository.standardBookings, hasLength(1));
      expect(agenda.refreshCount, 1);
    });

    test('surfaces the API message and rethrows on ApiException', () async {
      repository.bookStandardError = const ApiException('Cupo completo');

      await expectLater(
        viewModel.bookStandard(slot: buildSlot()),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'Cupo completo',
          ),
        ),
      );

      expect(viewModel.standardBookingError, 'Cupo completo');
      // The agenda must not be refreshed when the booking itself failed.
      expect(agenda.refreshCount, 0);
    });

    test(
      'wraps a non-API error in ApiException with the fallback message',
      () async {
        repository.bookStandardError = StateError('socket closed');

        await expectLater(
          viewModel.bookStandard(slot: buildSlot()),
          throwsA(isA<ApiException>()),
        );

        expect(viewModel.standardBookingError, isNotNull);
        expect(
          viewModel.standardBookingError,
          contains('Could not book the session'),
        );
      },
    );

    test('clears a previous error when a later booking succeeds', () async {
      repository.bookStandardError = const ApiException('Cupo completo');
      await expectLater(
        viewModel.bookStandard(slot: buildSlot()),
        throwsA(isA<ApiException>()),
      );
      expect(viewModel.standardBookingError, isNotNull);

      repository.bookStandardError = null;
      await viewModel.bookStandard(slot: buildSlot());

      expect(viewModel.standardBookingError, isNull);
    });

    test('reports a failing agenda refresh as a booking error', () async {
      agenda.refreshError = const ApiException('Agenda no disponible');

      await expectLater(
        viewModel.bookStandard(slot: buildSlot()),
        throwsA(isA<ApiException>()),
      );

      // The reservation itself went through even though the refresh did not.
      expect(repository.standardBookings, hasLength(1));
      expect(viewModel.standardBookingError, 'Agenda no disponible');
    });

    test('releases the in-flight guard after a failure', () async {
      repository.bookStandardError = const ApiException('Cupo completo');
      await expectLater(
        viewModel.bookStandard(slot: buildSlot()),
        throwsA(isA<ApiException>()),
      );

      repository.bookStandardError = null;
      await viewModel.bookStandard(slot: buildSlot());

      // A failed attempt must not wedge the view-model permanently.
      expect(repository.standardBookings, hasLength(2));
    });
  });

  group('bookByClassType', () {
    test('keeps its error state separate from the standard flow', () async {
      repository.bookByClassTypeError = const ApiException('Clase llena');

      await expectLater(
        viewModel.bookByClassType(slot: buildCapabilitySlot()),
        throwsA(isA<ApiException>()),
      );

      expect(viewModel.classTypeBookingError, 'Clase llena');
      expect(viewModel.standardBookingError, isNull);
    });

    test('does not block a standard booking already in flight', () async {
      final gate = Completer<void>();
      repository.gate = gate;

      final standard = viewModel.bookStandard(slot: buildSlot());
      final byType = viewModel.bookByClassType(slot: buildCapabilitySlot());

      gate.complete();
      await Future.wait([standard, byType]);

      // Separate guards, so the two booking kinds do not starve each other.
      expect(repository.standardBookings, hasLength(1));
      expect(repository.classTypeBookings, hasLength(1));
    });
  });
}

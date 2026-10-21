import 'package:fitnesscenter_mobile/app/core/exceptions/api_exception.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/booking/booking_state_dto.dart';
import 'package:fitnesscenter_mobile/features/bookings/presentation/viewmodels/bookings_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fakes.dart';

void main() {
  late FakeBookingsRepository repository;
  late BookingsViewModel viewModel;

  setUp(() {
    repository = FakeBookingsRepository();
    viewModel = BookingsViewModel(repository: repository);
  });

  group('loadBookings', () {
    test('populates the list and marks the view-model as loaded', () async {
      repository.setBookings([buildBooking(bookingId: 'bk-1')]);

      await viewModel.loadBookings();

      expect(viewModel.bookings, hasLength(1));
      expect(viewModel.hasLoaded, isTrue);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.error, isNull);
    });

    test('clears the list and exposes the message on failure', () async {
      repository.setBookings([buildBooking()]);
      await viewModel.loadBookings();
      expect(viewModel.bookings, hasLength(1));

      repository.fetchBookingsError = const ApiException('Sin conexion');
      await viewModel.loadBookings();

      // Stale rows must not survive a failed reload, otherwise the member sees
      // bookings that may no longer exist.
      expect(viewModel.bookings, isEmpty);
      expect(viewModel.error, 'Sin conexion');
      expect(viewModel.isLoading, isFalse);
    });

    test('ignores a concurrent load while one is in flight', () async {
      repository.setBookings([buildBooking()]);

      await Future.wait([viewModel.loadBookings(), viewModel.loadBookings()]);

      expect(repository.fetchBookingsCallCount, 1);
    });
  });

  group('cancelReservation', () {
    test('cancels a reserved booking and reports success', () async {
      repository.setBookings([buildBooking(state: 'RESERVADA')]);
      await viewModel.loadBookings();

      final result = await viewModel.cancelReservation(
        buildRow(bookingStatus: 'RESERVADA'),
      );

      expect(repository.statusUpdates, [(bookingId: 'bk-1', state: '2')]);
      expect(result.outcome, BookingActionOutcome.updated);
      expect(result.action, BookingAction.cancel);
    });

    test('cancels a confirmed booking too', () async {
      await viewModel.cancelReservation(buildRow(bookingStatus: 'CONFIRMADA'));

      expect(repository.statusUpdates, hasLength(1));
    });

    test('refuses to cancel an already-canceled booking', () async {
      final result = await viewModel.cancelReservation(
        buildRow(bookingStatus: 'ANULADA'),
      );

      // The guard has to hold before any network call is made.
      expect(repository.statusUpdates, isEmpty);
      expect(result.outcome, BookingActionOutcome.unavailable);
      expect(result.action, BookingAction.cancel);
    });

    test('refuses to act on a row with no status', () async {
      final result = await viewModel.cancelReservation(<String, dynamic>{
        'bookingId': 'bk-1',
      });

      expect(repository.statusUpdates, isEmpty);
      expect(result.outcome, BookingActionOutcome.unavailable);
    });

    test('accepts a lowercase status from the table row', () async {
      // Rows are built for display, so casing is not guaranteed.
      final result = await viewModel.cancelReservation(
        buildRow(bookingStatus: 'reservada'),
      );

      expect(repository.statusUpdates, hasLength(1));
      expect(result.outcome, BookingActionOutcome.updated);
    });

    test('reports the API message when the update is rejected', () async {
      repository.updateBookingStatusError = const ApiException(
        'Fuera del plazo de anulacion',
      );

      final result = await viewModel.cancelReservation(
        buildRow(bookingStatus: 'RESERVADA'),
      );

      expect(result.outcome, BookingActionOutcome.apiFailure);
      // The server-authored message is passed through untranslated.
      expect(result.detail, 'Fuera del plazo de anulacion');
    });

    test(
      'falls back to a local status change when the refresh fails',
      () async {
        repository.setBookings([
          buildBooking(bookingId: 'bk-1', state: 'RESERVADA'),
        ]);
        await viewModel.loadBookings();

        // The cancel succeeds but the follow-up refresh does not.
        repository.fetchBookingsError = const ApiException('Sin conexion');
        final result = await viewModel.cancelReservation(
          buildRow(bookingStatus: 'RESERVADA'),
        );

        // The member still sees the booking as canceled rather than a stale
        // "reserved" row, and the action is still reported as successful.
        expect(viewModel.bookings.single.state, 'ANULADA');
        expect(result.outcome, BookingActionOutcome.updated);
      },
    );
  });

  group('confirmReservation', () {
    test('confirms a reserved booking with the confirm action code', () async {
      final result = await viewModel.confirmReservation(
        buildRow(bookingStatus: 'RESERVADA'),
      );

      expect(repository.statusUpdates, [(bookingId: 'bk-1', state: '1')]);
      expect(result.outcome, BookingActionOutcome.updated);
      expect(result.action, BookingAction.confirm);
    });

    test('re-confirms a canceled booking', () async {
      await viewModel.confirmReservation(buildRow(bookingStatus: 'ANULADA'));

      expect(repository.statusUpdates, hasLength(1));
    });

    test('refuses to confirm an already-confirmed booking', () async {
      final result = await viewModel.confirmReservation(
        buildRow(bookingStatus: 'CONFIRMADA'),
      );

      expect(repository.statusUpdates, isEmpty);
      expect(result.outcome, BookingActionOutcome.unavailable);
    });
  });

  group('buildStateOptions', () {
    test('hides operational statuses members may not set', () async {
      repository.setBookings([buildBooking()]);
      await viewModel.loadBookings();
      await viewModel.ensureBookingStatesLoaded();

      final codes = viewModel
          .buildStateOptions()
          .map((option) => option.id.toLowerCase())
          .toList();

      // "Completed" is an admin outcome, never a member-driven transition.
      expect(codes, isNot(contains('completed')));
      expect(codes, isNot(contains('completada')));
    });

    test('keeps the member-selectable statuses', () async {
      repository = FakeBookingsRepository(
        states: const [
          BookingStateDto(code: 'RESERVADA', label: 'Reservada'),
          BookingStateDto(code: 'CONFIRMADA', label: 'Confirmada'),
          BookingStateDto(code: 'COMPLETADA', label: 'Completada'),
        ],
      );
      viewModel = BookingsViewModel(repository: repository);
      await viewModel.ensureBookingStatesLoaded();

      final codes = viewModel
          .buildStateOptions()
          .map((option) => option.id)
          .toList();

      expect(codes, containsAll(<String>['RESERVADA', 'CONFIRMADA']));
      expect(codes, isNot(contains('COMPLETADA')));
    });

    test('falls back to statuses derived from the loaded bookings', () async {
      // The catalog endpoint is non-fatal: if it fails the picker still works.
      repository.setBookings([
        buildBooking(bookingId: 'bk-1', state: 'RESERVADA'),
        buildBooking(bookingId: 'bk-2', state: 'CONFIRMADA'),
      ]);
      repository.fetchBookingStatesError = const ApiException('500');
      await viewModel.loadBookings();
      await viewModel.ensureBookingStatesLoaded();

      final codes = viewModel
          .buildStateOptions()
          .map((option) => option.id)
          .toList();

      expect(codes, containsAll(<String>['RESERVADA', 'CONFIRMADA']));
    });
  });

  group('pagination', () {
    test('slices the current page and tracks the total', () async {
      repository.setBookings(
        List.generate(8, (i) => buildBooking(bookingId: 'bk-$i')),
      );
      await viewModel.loadBookings();

      expect(viewModel.bookingsTotalItems, 8);
      expect(viewModel.bookingsPageRows, hasLength(6));

      viewModel.setBookingsPageNumber(2);
      expect(viewModel.bookingsPageRows, hasLength(2));
      expect(viewModel.bookingsPageRows.first.bookingId, 'bk-6');
    });
  });
}

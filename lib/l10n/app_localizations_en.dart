// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get commonBack => 'Back';

  @override
  String get commonClose => 'Close';

  @override
  String get commonClear => 'Clear';

  @override
  String get commonMenu => 'Menu';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonRowActions => 'Row actions';

  @override
  String get commonNoRecords => 'No records available.';

  @override
  String get commonNotSpecified => 'Not specified';

  @override
  String get commonViewProfile => 'View profile';

  @override
  String get authAccessAccount => 'Access your account';

  @override
  String get authEmail => 'Email';

  @override
  String get authEmailHint => 'Enter your email';

  @override
  String get authPassword => 'Password';

  @override
  String get authPasswordHint => 'Enter your password';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authResendVerification => 'Resend verification email';

  @override
  String get authIHaveVerified => 'I have verified';

  @override
  String get authWelcomeTitle => 'Welcome!';

  @override
  String get authWelcomeSubtitle => 'Enter your email to continue';

  @override
  String get bookingsTitle => 'My Bookings';

  @override
  String get bookingsBookSession => 'Book a Session';

  @override
  String get bookingsEmpty => 'You have no bookings yet.';

  @override
  String get bookingsColumnTime => 'Time';

  @override
  String get bookingsColumnClassTrainer => 'Class / Trainer';

  @override
  String get bookingsColumnActions => 'Actions';

  @override
  String get bookingsTrainerPending => 'Trainer pending assignment';

  @override
  String get bookingsViewDetails => 'View details';

  @override
  String get bookingsConfirmBooking => 'CONFIRM BOOKING';

  @override
  String get bookingsCancelBooking => 'CANCEL BOOKING';

  @override
  String get bookingsUpdateStatus => 'Update Status';

  @override
  String get bookingActionUnavailableTitle => 'Action unavailable';

  @override
  String get bookingCancelUnavailable =>
      'Only reserved or confirmed bookings can be canceled.';

  @override
  String get bookingConfirmUnavailable =>
      'Only reserved or canceled bookings can be confirmed.';

  @override
  String get bookingStatusUpdatedTitle => 'Status updated';

  @override
  String get bookingChangedToCanceled => 'Booking changed to canceled.';

  @override
  String get bookingChangedToConfirmed => 'Booking changed to confirmed.';

  @override
  String get bookingUpdateFailedTitle => 'Could not update booking';

  @override
  String get bookingUnexpectedErrorTitle => 'Unexpected error';

  @override
  String bookingUnexpectedErrorDetail(String error) {
    return 'Could not update booking status: $error';
  }

  @override
  String get bookingCouldNotBookSession => 'Could not book the session';

  @override
  String get bookingCouldNotBookClassSlot => 'Could not book this class slot';

  @override
  String get bookingsLoadFailed => 'Could not load your bookings';

  @override
  String get navHome => 'Home';

  @override
  String get navBookings => 'Bookings';

  @override
  String get navDirectory => 'Directory';

  @override
  String get navProfile => 'Profile';

  @override
  String get navSlots => 'Slots';

  @override
  String get brandSlogan => 'now even closer to you';

  @override
  String homeGreeting(String name) {
    return 'Hi, $name!';
  }

  @override
  String get homeGreetingNoName => 'Hi!';

  @override
  String get homeExploreDisciplines => 'Explore\nDisciplines';

  @override
  String get homeUpcomingBookings => 'Upcoming Bookings';

  @override
  String get homeHistory => 'History';

  @override
  String get homeViewHistory => 'View history';

  @override
  String get homeViewBookings => 'View bookings';

  @override
  String get homeNoUpcoming =>
      'You have no upcoming bookings at FitnessCenter.';

  @override
  String get homeUpcomingLoadFailed =>
      'We could not load your upcoming bookings.';

  @override
  String get commonClass => 'Class';

  @override
  String get paginationPrevious => 'Previous page';

  @override
  String get paginationNext => 'Next page';

  @override
  String get paginationZeroResults => '0 results';

  @override
  String paginationPage(int page) {
    return 'Page $page';
  }

  @override
  String paginationPageOf(int page, int total) {
    return 'Page $page of $total';
  }

  @override
  String paginationShowing(int start, int end, int total) {
    return 'Showing $start-$end of $total';
  }
}

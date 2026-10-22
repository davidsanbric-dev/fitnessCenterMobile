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

  @override
  String get commonAction => 'Action';

  @override
  String get dirAllDisciplines => 'All disciplines';

  @override
  String get slotAvailability => 'Availability';

  @override
  String get slotAvailableTimes => 'Available Time Slots';

  @override
  String get bookingDetailsTitle => 'Booking Details';

  @override
  String get bookingOptionsTitle => 'Booking Options';

  @override
  String get filterByClassType => 'By Class Type';

  @override
  String get filterByDiscipline => 'By Discipline';

  @override
  String get filterByDisciplineTrainer => 'By Discipline/Trainer';

  @override
  String get filterByPlan => 'By Membership Plan';

  @override
  String get filterByTrainer => 'By Trainer';

  @override
  String get filterChange => 'Change filters';

  @override
  String get classOption => 'Class option';

  @override
  String get classOptions => 'Class Options';

  @override
  String get classType => 'Class type';

  @override
  String get classTypes => 'Class Types';

  @override
  String get dirTrainerProfileFailed => 'Could not open the trainer profile.';

  @override
  String get dirSelectDisciplineFailed => 'Could not select the discipline.';

  @override
  String get dirSelectTrainerFailed => 'Could not select the trainer.';

  @override
  String get commonCreatedAt => 'Created At';

  @override
  String get commonDiscipline => 'Discipline';

  @override
  String get commonDisciplines => 'Disciplines';

  @override
  String get commonDuration => 'Duration';

  @override
  String get dirTitle => 'Fitness Directory';

  @override
  String get commonGeneralInfo => 'General Information';

  @override
  String get commonGroup => 'Group';

  @override
  String get commonSchedule => 'Schedule';

  @override
  String get filterHowToSearch => 'How do you want to search?';

  @override
  String get commonMember => 'Member';

  @override
  String get commonPlan => 'Membership plan';

  @override
  String get commonPlans => 'Membership Plans';

  @override
  String get emptyNoAvailClassOption =>
      'No availability for this class option.';

  @override
  String get emptyNoAvailDiscipline => 'No availability for this discipline.';

  @override
  String get emptyNoAvailTrainer => 'No availability for this trainer.';

  @override
  String get emptyNoSlotsForFilters =>
      'No available time slots for the selected filters.';

  @override
  String get emptyNoBio => 'No bio available for this trainer.';

  @override
  String get emptyNoGroups =>
      'No class category groups are available right now.';

  @override
  String get emptyNoClassOptions =>
      'No class options available for this subcategory.';

  @override
  String get emptyNoClassTypes =>
      'No class types available for this subcategory.';

  @override
  String get emptyNoDisciplines => 'No disciplines available.';

  @override
  String get emptyNoPlans => 'No membership plans available.';

  @override
  String get commonNoName => 'No name';

  @override
  String get emptyNoPreparation => 'No preparation instructions available.';

  @override
  String get commonNoStatus => 'No status';

  @override
  String get emptyNoSubgroups =>
      'No subcategories available for the selected group.';

  @override
  String get emptyNoTrainers => 'No trainers available.';

  @override
  String get commonNormal => 'Normal';

  @override
  String get commonNotAvailable => 'Not available';

  @override
  String get commonNotDefined => 'Not defined';

  @override
  String get commonPhone => 'Phone';

  @override
  String get pickClassType => 'Pick a class type';

  @override
  String get commonPreparation => 'Preparation';

  @override
  String get commonInsurance => 'Insurance';

  @override
  String get commonScheduledAt => 'Scheduled At';

  @override
  String get pickSubcategory => 'Select a subcategory';

  @override
  String get filterSelectValid => 'Select valid options before searching.';

  @override
  String get commonServiceCentre => 'Service / Centre';

  @override
  String get commonSessionFeedback => 'Session Feedback';

  @override
  String get commonStatus => 'Status';

  @override
  String get commonSubgroup => 'Subgroup';

  @override
  String get commonBranch => 'Branch';

  @override
  String get commonTimeSlots => 'Time Slots';

  @override
  String get commonTrainer => 'Trainer';

  @override
  String get commonTrainerDiscipline => 'Trainer / Discipline';

  @override
  String get commonTrainerNotes => 'Trainer Notes';

  @override
  String get commonTrainers => 'Trainers';

  @override
  String get viewPreparation => 'View Preparation';

  @override
  String get filterWhatClass => 'What type of class are you looking for?';

  @override
  String get commonGroupPrefix => 'Group: ';

  @override
  String comingSoonDetail(String label) {
    return 'Detailed information for $label will be available soon.';
  }

  @override
  String get searchDisciplineHint => 'Search for a discipline';

  @override
  String get searchTrainerHint => 'Search for a trainer';

  @override
  String get homeAssessmentsCard => 'Fitness\nAssessments';

  @override
  String get homeTrainersCard => 'Meet\nTrainers';

  @override
  String get homeSubtitle => 'Book and manage your classes from anywhere';

  @override
  String get homeDiscover => 'Discover everything you can do';

  @override
  String get homeTrainSmarter => 'Train smarter, hassle-free';

  @override
  String get homeStartToday => 'Start today';

  @override
  String get homeLearnMore => 'Learn more';

  @override
  String get homeReadMore => 'Read more';

  @override
  String get homeViewAll => 'View all';

  @override
  String get homeBookingToday => 'Booking for today';

  @override
  String get homeLoadingNext => 'Loading your next booking...';

  @override
  String get homeLoadingHistory => 'Loading your training history...';

  @override
  String get homeHistoryLoadFailed =>
      'We could not load your training history.';

  @override
  String get homeHistoryEmpty => 'Your completed sessions will appear here.';

  @override
  String get commonSession => 'Session';

  @override
  String planPrice(String amount) {
    return 'Price: \$$amount';
  }

  @override
  String planUpToSessions(int count) {
    return 'Up to $count sessions / month';
  }

  @override
  String planUpToSession(int count) {
    return 'Up to $count session / month';
  }

  @override
  String get profileTitle => 'My Profile';

  @override
  String get profilePersonalInfo => 'Personal Information';

  @override
  String get profileFullName => 'Full Name';

  @override
  String get profileMembershipPlan => 'Membership Plan';

  @override
  String get profileTrainingHistory => 'Training History';

  @override
  String get profileAssessmentResults => 'Assessment Results';

  @override
  String get profileSignOut => 'Sign Out';

  @override
  String get profileDetails => 'Details';

  @override
  String get profileNoAssessments => 'No assessment notes yet.';

  @override
  String get profileNoSessions => 'No completed sessions yet.';

  @override
  String get profileTrainerFeedback => 'Trainer feedback';

  @override
  String get profilePhotoUpdated => 'Profile photo updated.';

  @override
  String profileSignOutFailed(String error) {
    return 'Could not sign out: $error';
  }

  @override
  String profilePhotoFailed(String error) {
    return 'Could not update the photo: $error';
  }

  @override
  String get commonDetailsLoadFailed => 'Could not load details';

  @override
  String get commonUnexpectedError => 'Unexpected error';

  @override
  String homeLastSession(String session, String trainer, String date) {
    return 'Last: $session$trainer, $date.';
  }

  @override
  String homeTodaySession(String session, String trainer, String time) {
    return 'Today: $session$trainer, $time.';
  }

  @override
  String homeNextSession(
    String session,
    String trainer,
    String date,
    String time,
  ) {
    return 'Next: $session$trainer, $date at $time.';
  }

  @override
  String commonWithTrainer(String trainer) {
    return ' with $trainer';
  }

  @override
  String get assessmentEmpty =>
      'Your trainer\'s feedback will appear here after a completed session.';

  @override
  String get commonTime => 'Time';
}

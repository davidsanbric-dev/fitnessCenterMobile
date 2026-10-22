import 'package:fitnesscenter_mobile/app/config/app_router.dart';
import 'package:fitnesscenter_mobile/app/config/app_tab.dart';
import 'package:fitnesscenter_mobile/app/core/api/booking_agenda_api.dart';
import 'package:fitnesscenter_mobile/app/core/services/bookings_navigation_service.dart';
import 'package:fitnesscenter_mobile/app/core/services/profile_navigation_service.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/bookings/booking_dto.dart';
import 'package:fitnesscenter_mobile/features/home/feature.dart';
import 'package:fitnesscenter_mobile/app/core/auth/auth.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/brand/brand_header.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/buttons/login_submit_button.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/layout/page_header_config.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/table/row_cells/date_time_cell.dart';
import 'package:fitnesscenter_mobile/features/bookings/presentation/pages/bookings_page.dart';
import 'package:fitnesscenter_mobile/features/fitness_directory/feature.dart';
import 'package:fitnesscenter_mobile/features/fitness_directory/presentation/pages/trainers_directory_subpage.dart';
import 'package:fitnesscenter_mobile/features/fitness_directory/presentation/pages/disciplines_directory_subpage.dart';
import 'package:fitnesscenter_mobile/features/home/presentation/widgets/blog_slider.dart';
import 'package:fitnesscenter_mobile/features/home/presentation/widgets/info_slider.dart';
import 'package:fitnesscenter_mobile/features/home/presentation/widgets/info_summary.dart';
import 'package:fitnesscenter_mobile/features/home/presentation/widgets/shortcuts_display.dart';
import 'package:fitnesscenter_mobile/app/core/services/local_notification_service.dart';
import 'package:fitnesscenter_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.onHeaderChanged});

  /// When provided, Home reports its brand header up instead of rendering it
  /// directly, letting a host (the bottom-nav shell) own a single header that
  /// crossfades between the brand mark and other tabs' titles.
  final PageHeaderReporter? onHeaderChanged;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late final BookingAgendaApi _bookingsApi;
  late final BlogViewModel _blogViewModel;
  late Future<AvailableSlotDto?> _upcomingBooking;
  late Future<BookingDto?> _lastCompletedBooking;
  bool _hasNotified = false;
  Worker? _navWorker;

  @override
  void initState() {
    super.initState();
    _bookingsApi = BookingAgendaApi();
    // Shared view-model: loads blogs and re-fetches when a "new blog" push
    // arrives (wired in HomeInjector), so the slider updates on-time.
    _blogViewModel = HomeInjector.getBlogViewModel();
    _upcomingBooking = _loadUpcomingBooking();
    _lastCompletedBooking = _loadLastCompletedBooking();
    // Safety net for the "user already on home" case: keep the slider current
    // even if a foreground push is delayed/dropped, and re-sync on resume.
    WidgetsBinding.instance.addObserver(this);
    _blogViewModel.startAutoRefresh();
    _attachNavListener();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _navWorker?.dispose();
    _blogViewModel.stopAutoRefresh();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _blogViewModel.loadBlogs();
      _blogViewModel.startAutoRefresh();
      // A booking may have been cancelled/changed (web, push, another device)
      // while backgrounded; re-sync the upcoming summary on resume.
      _refreshUpcomingBooking();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _blogViewModel.stopAutoRefresh();
    }
  }

  // The bottom-nav uses an IndexedStack, so this page stays mounted across tab
  // switches. Watch the active tab and re-fetch the upcoming booking whenever
  // the user returns to Home, so a status change made on the Bookings tab
  // (e.g. cancelling) is reflected here without a full app restart.
  void _attachNavListener() {
    if (!Get.isRegistered<AppRouter>()) {
      return;
    }
    final appRouter = Get.find<AppRouter>();
    _navWorker = ever<AppTab>(appRouter.current, (tab) {
      if (tab == AppTab.home) {
        _refreshUpcomingBooking();
      }
    });
  }

  void _refreshUpcomingBooking() {
    if (!mounted) {
      return;
    }
    setState(() {
      _upcomingBooking = _loadUpcomingBooking();
    });
  }

  Future<AvailableSlotDto?> _loadUpcomingBooking() async {
    try {
      return await _bookingsApi.getNextUpcomingBooking();
    } catch (error) {
      rethrow;
    }
  }

  Future<BookingDto?> _loadLastCompletedBooking() async {
    final items = await _bookingsApi.getAgenda(
      bookingStatus: 'COMPLETED',
      // Completed sessions are past-dated; bypass the default upcoming window
      // so the home "History" summary can surface the most recent one.
      includeAllDates: true,
    );
    // API returns results sorted booking_datetime DESC; first entry is most recent.
    return items.isEmpty ? null : items.first;
  }

  void _handleProfileHistoryNavigation() {
    ProfileNavigationService.instance.requestTrainingHistory();
    if (Get.isRegistered<AppRouter>()) {
      Get.find<AppRouter>().goTo(AppTab.profile);
      return;
    }
  }

  void _handleAssessmentResultsNavigation() {
    ProfileNavigationService.instance.requestAssessmentResults();
    if (Get.isRegistered<AppRouter>()) {
      Get.find<AppRouter>().goTo(AppTab.profile);
      return;
    }
  }

  String _greetingFor(AuthService authService) {
    final name = authService.userName?.trim();
    if (name == null || name.isEmpty) {
      return AppLocalizations.of(context).homeGreetingNoName;
    }
    final firstName = name.split(' ').first;
    return AppLocalizations.of(context).homeGreeting(firstName);
  }

  void _openBookSessionFlow() {
    // Reuse the exact same in-page "Book a Session" flow as the Bookings page
    // button (the three-tier header experience), instead of a standalone
    // dialog: request the flow and switch to the Bookings tab so the page
    // opens it on arrival. The upcoming-booking summary re-syncs automatically
    // when the user returns to Home (see _attachNavListener).
    BookingsNavigationService.instance.requestBookFlow();
    _handleBookingsNavigation();
  }

  void _handleBookingsNavigation() {
    if (Get.isRegistered<AppRouter>()) {
      Get.find<AppRouter>().goTo(AppTab.bookings);
      return;
    }
    Get.to(() => const BookingsPage());
  }

  FitnessDirectoryViewModel _ensureFitnessDirectoryController() {
    return FitnessDirectoryInjector.getFitnessDirectoryViewModel();
  }

  DisciplinesDirectoryViewModel _ensureDisciplinesController() {
    return FitnessDirectoryInjector.getDisciplinesDirectoryViewModel();
  }

  void _handleDisciplinesNavigation() {
    if (Get.isRegistered<AppRouter>()) {
      final directoryController = _ensureFitnessDirectoryController();
      final disciplinesController = _ensureDisciplinesController();
      directoryController.showDisciplines();
      disciplinesController.loadDisciplines(forceRefresh: true);
      Get.find<AppRouter>().goTo(AppTab.fitnessDirectory);
      return;
    }
    Get.to(() => const DisciplinesDirectoryStandalonePage());
  }

  void _handleTrainersNavigation() {
    if (Get.isRegistered<AppRouter>()) {
      final controller = _ensureFitnessDirectoryController();
      controller.showTrainers();
      Get.find<AppRouter>().goTo(AppTab.fitnessDirectory);
      return;
    }
    Get.to(() => const TrainersDirectoryStandalonePage());
  }

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final greeting = _greetingFor(authService);
    final sliderSlides = [
      InfoSlide(
        title: AppLocalizations.of(context).homeDiscover,
        description: 'with your FitnessCenter app',
        callToAction: AppLocalizations.of(context).homeLearnMore,
      ),
      InfoSlide(
        title: AppLocalizations.of(context).homeTrainSmarter,
        description: AppLocalizations.of(context).homeSubtitle,
        callToAction: AppLocalizations.of(context).homeStartToday,
      ),
    ];

    final shortcuts = [
      ShortcutCardData(
        title: AppLocalizations.of(context).homeExploreDisciplines,
        iconData: LucideIcons.dumbbell,
        onTap: _handleDisciplinesNavigation,
      ),
      ShortcutCardData(
        title: AppLocalizations.of(context).homeAssessmentsCard,
        iconData: LucideIcons.heartPulse,
        onTap: _handleAssessmentResultsNavigation,
      ),
      ShortcutCardData(
        title: AppLocalizations.of(context).homeTrainersCard,
        iconData: LucideIcons.usersRound,
        onTap: _handleTrainersNavigation,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              PageHeaderSlot(
                config: const PageHeaderConfig(
                  child: BrandHeader(variant: 'small'),
                ),
                reporter: widget.onHeaderChanged,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            greeting,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                ),
                          ),
                        ),
                        // const MenuTriggerButton(),
                      ],
                    ),
                    const SizedBox(height: 10),
                    AppButton(
                      text: AppLocalizations.of(context).bookingsBookSession,
                      height: 58,
                      fontSize: 18,
                      onPressed: _openBookSessionFlow,
                    ),
                    const SizedBox(height: 22),
                    FutureBuilder<BookingDto?>(
                      future: _lastCompletedBooking,
                      builder: (context, historySnapshot) {
                        return FutureBuilder<AvailableSlotDto?>(
                          future: _upcomingBooking,
                          builder: (context, snapshot) {
                            final slot = snapshot.data;
                            if (slot != null &&
                                !_hasNotified &&
                                snapshot.connectionState ==
                                    ConnectionState.done &&
                                _isToday(slot.schedulingDate)) {
                              _notifyTodayBooking(slot);
                            }
                            final upcomingDescription =
                                _buildUpcomingDescription(
                                  slot,
                                  isLoading:
                                      snapshot.connectionState ==
                                      ConnectionState.waiting,
                                  error: snapshot.error,
                                );
                            final historyDescription = _buildHistoryDescription(
                              historySnapshot.data,
                              isLoading:
                                  historySnapshot.connectionState ==
                                  ConnectionState.waiting,
                              error: historySnapshot.error,
                            );
                            final tabs = [
                              InfoSummaryTab(
                                label: AppLocalizations.of(
                                  context,
                                ).homeUpcomingBookings,
                                description: upcomingDescription,
                                iconData: LucideIcons.calendarClock,
                              ),
                              InfoSummaryTab(
                                label: AppLocalizations.of(context).homeHistory,
                                description: historyDescription,
                                iconData: LucideIcons.history,
                                actionLabel: AppLocalizations.of(
                                  context,
                                ).homeViewHistory,
                                onActionPressed:
                                    _handleProfileHistoryNavigation,
                              ),
                            ];
                            return InfoSummary(
                              tabs: tabs,
                              iconData: LucideIcons.activity,
                              onActionPressed: _handleBookingsNavigation,
                              actionLabel: AppLocalizations.of(
                                context,
                              ).homeViewBookings,
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                    ShortcutsDisplay(shortcuts: shortcuts, spacing: 8),
                    const SizedBox(height: 32),
                    ListenableBuilder(
                      listenable: _blogViewModel,
                      builder: (context, _) {
                        final blogs = _blogViewModel.blogs;
                        if (blogs.isNotEmpty) {
                          // Reactive: refreshes on-time when a "new blog" push
                          // arrives via BlogViewModel.
                          return BlogSlider(blogs: blogs.toList());
                        }
                        // No blogs (or still loading / failed): keep the
                        // original promotional slider so home is never empty.
                        return InfoSlider(slides: sliderSlides);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildHistoryDescription(
    BookingDto? booking, {
    required bool isLoading,
    Object? error,
  }) {
    if (isLoading) {
      return AppLocalizations.of(context).homeLoadingHistory;
    }
    if (error != null)
      return AppLocalizations.of(context).homeHistoryLoadFailed;
    if (booking == null) {
      return AppLocalizations.of(context).homeHistoryEmpty;
    }
    final service = booking.serviceName?.trim() ?? '';
    final trainer = booking.trainerName?.trim() ?? '';
    final date = booking.schedulingDate.toLocal();
    final dateText =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    final sessionLabel = service.isNotEmpty
        ? service
        : AppLocalizations.of(context).commonSession;
    final trainerPart = trainer.isNotEmpty
        ? AppLocalizations.of(context).commonWithTrainer(trainer)
        : '';
    return AppLocalizations.of(
      context,
    ).homeLastSession(sessionLabel, trainerPart, dateText);
  }

  String _buildUpcomingDescription(
    AvailableSlotDto? slot, {
    required bool isLoading,
    Object? error,
  }) {
    if (isLoading) {
      return AppLocalizations.of(context).homeLoadingNext;
    }
    if (error != null) {
      return AppLocalizations.of(context).homeUpcomingLoadFailed;
    }
    if (slot == null) {
      return AppLocalizations.of(context).homeNoUpcoming;
    }
    final timeText = DateTimeCell.formatTime(slot.schedulingDate);
    final service = slot.serviceName.isEmpty
        ? AppLocalizations.of(context).commonClass
        : slot.serviceName;
    final trainer = slot.trainerName.isEmpty
        ? ''
        : AppLocalizations.of(context).commonWithTrainer(slot.trainerName);
    if (_isToday(slot.schedulingDate)) {
      return AppLocalizations.of(
        context,
      ).homeTodaySession(service, trainer, timeText);
    }
    final dateText = DateTimeCell.formatDate(slot.schedulingDate);
    return AppLocalizations.of(
      context,
    ).homeNextSession(service, trainer, dateText, timeText);
  }

  bool _isToday(DateTime value) {
    final now = DateTime.now();
    final local = value.toLocal();
    return local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
  }

  Future<void> _notifyTodayBooking(AvailableSlotDto slot) async {
    if (!mounted || _hasNotified) return;
    _hasNotified = true;

    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) {
      return;
    }

    final lifecycle = WidgetsBinding.instance.lifecycleState;
    if (lifecycle != AppLifecycleState.resumed) {
      return;
    }

    if (!Get.isRegistered<LocalNotificationService>()) {
      return;
    }

    final local = Get.find<LocalNotificationService>();
    local.setOnNotificationTap((_) => _handleBookingsNavigation());

    await local.showLocalNotification(
      title: AppLocalizations.of(context).homeBookingToday,
      body:
          '${slot.serviceName.isEmpty ? 'Class' : slot.serviceName} · ${DateTimeCell.formatTime(slot.schedulingDate)}',
      payload: const {'action': 'open_member_bookings'},
    );
  }
}

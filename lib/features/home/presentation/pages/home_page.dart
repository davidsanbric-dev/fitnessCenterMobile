import 'package:portfolio_mobile_app/app/config/app_router.dart';
import 'package:portfolio_mobile_app/app/core/api/booking_agenda_api.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:portfolio_mobile_app/features/home/logic/blog_controller.dart';
import 'package:portfolio_mobile_app/app/core/auth/auth.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/brand/brand_header.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/buttons/login_submit_button.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/layout/page_header.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/row_cells/date_time_cell.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/presentation/widgets/book_session_dialog.dart';
import 'package:portfolio_mobile_app/features/bookings/presentation/pages/bookings_page.dart';
import 'package:portfolio_mobile_app/features/fitness_directory/feature.dart';
import 'package:portfolio_mobile_app/features/fitness_directory/presentation/pages/trainers_directory_subpage.dart';
import 'package:portfolio_mobile_app/features/fitness_directory/presentation/pages/disciplines_directory_subpage.dart';
import 'package:portfolio_mobile_app/features/home/presentation/widgets/blog_slider.dart';
import 'package:portfolio_mobile_app/features/home/presentation/widgets/info_slider.dart';
import 'package:portfolio_mobile_app/features/home/presentation/widgets/info_summary.dart';
import 'package:portfolio_mobile_app/features/home/presentation/widgets/shortcuts_display.dart';
import 'package:portfolio_mobile_app/app/core/services/local_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  static const int _homeTabIndex = 0;
  static const int _bookingsTabIndex = 1;
  static const int _fitnessDirectoryTabIndex = 6;

  late final BookingAgendaApi _bookingsApi;
  late final BlogController _blogController;
  late Future<AvailableSlotDto?> _upcomingBooking;
  bool _hasNotified = false;
  Worker? _navWorker;

  @override
  void initState() {
    super.initState();
    _bookingsApi = BookingAgendaApi();
    // Shared controller: loads blogs and re-fetches when a "new blog" push
    // arrives (wired in BlogController.onInit), so the slider updates on-time.
    _blogController = Get.isRegistered<BlogController>()
        ? Get.find<BlogController>()
        : Get.put(BlogController(), permanent: true);
    _upcomingBooking = _loadUpcomingBooking();
    // Safety net for the "user already on home" case: keep the slider current
    // even if a foreground push is delayed/dropped, and re-sync on resume.
    WidgetsBinding.instance.addObserver(this);
    _blogController.startAutoRefresh();
    _attachNavListener();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _navWorker?.dispose();
    _blogController.stopAutoRefresh();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _blogController.loadBlogs();
      _blogController.startAutoRefresh();
      // A booking may have been cancelled/changed (web, push, another device)
      // while backgrounded; re-sync the upcoming summary on resume.
      _refreshUpcomingBooking();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _blogController.stopAutoRefresh();
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
    _navWorker = ever<int>(appRouter.currentIndex, (index) {
      if (index == _homeTabIndex) {
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

  String _greetingFor(AuthService authService) {
    final name = authService.userName?.trim();
    if (name == null || name.isEmpty) {
      return 'Hi!';
    }
    final firstName = name.split(' ').first;
    return 'Hi, $firstName!';
  }

  Future<void> _openBookSessionDialog() async {
    // Reuse the exact same "Book a Session" flow as the Bookings page button.
    await showBookSessionDialog(context);
    if (!mounted) {
      return;
    }
    // A session may have been booked within the dialog; refresh the home
    // "upcoming" summary so it reflects the change.
    _refreshUpcomingBooking();
  }

  void _handleBookingsNavigation() {
    if (Get.isRegistered<AppRouter>()) {
      Get.find<AppRouter>().changeTab(_bookingsTabIndex);
      return;
    }
    Get.to(() => const BookingsPage());
  }

  FitnessDirectoryController _ensureFitnessDirectoryController() {
    return FitnessDirectoryInjector.getFitnessDirectoryController();
  }

  DisciplinesDirectoryController _ensureDisciplinesController() {
    return FitnessDirectoryInjector.getDisciplinesDirectoryController();
  }

  void _handleDisciplinesNavigation() {
    if (Get.isRegistered<AppRouter>()) {
      final directoryController = _ensureFitnessDirectoryController();
      final disciplinesController = _ensureDisciplinesController();
      directoryController.showDisciplines();
      disciplinesController.loadDisciplines(forceRefresh: true);
      Get.find<AppRouter>().changeTab(_fitnessDirectoryTabIndex);
      return;
    }
    Get.to(() => const DisciplinesDirectoryStandalonePage());
  }

  void _handleTrainersNavigation() {
    if (Get.isRegistered<AppRouter>()) {
      final controller = _ensureFitnessDirectoryController();
      controller.showTrainers();
      Get.find<AppRouter>().changeTab(_fitnessDirectoryTabIndex);
      return;
    }
    Get.to(() => const TrainersDirectoryStandalonePage());
  }

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final greeting = _greetingFor(authService);
    final sliderSlides = [
      const InfoSlide(
        title: 'Discover everything you can do',
        description: 'with your FitnessCenter app',
        callToAction: 'Learn more',
      ),
      const InfoSlide(
        title: 'Train smarter, hassle-free',
        description: 'Book and manage your classes from anywhere',
        callToAction: 'Start today',
      ),
    ];

    final shortcuts = [
      ShortcutCardData(
        title: 'Explore\nDisciplines',
        iconData: LucideIcons.dumbbell,
        onTap: _handleDisciplinesNavigation,
      ),
      const ShortcutCardData(
        title: 'Fitness\nAssessments',
        iconData: LucideIcons.heartPulse,
      ),
      ShortcutCardData(
        title: 'Meet\nTrainers',
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
              const PageHeader(child: BrandHeader(variant: 'small')),
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
                      text: 'Book a Session',
                      height: 58,
                      fontSize: 18,
                      onPressed: _openBookSessionDialog,
                    ),
                    const SizedBox(height: 22),
                    FutureBuilder<AvailableSlotDto?>(
                      future: _upcomingBooking,
                      builder: (context, snapshot) {
                        final slot = snapshot.data;
                        if (slot != null &&
                            !_hasNotified &&
                            snapshot.connectionState == ConnectionState.done &&
                            _isToday(slot.schedulingDate)) {
                          _notifyTodayBooking(slot);
                        }
                        final upcomingDescription = _buildUpcomingDescription(
                          slot,
                          isLoading:
                              snapshot.connectionState ==
                              ConnectionState.waiting,
                          error: snapshot.error,
                        );
                        final tabs = [
                          InfoSummaryTab(
                            label: 'Upcoming Bookings',
                            description: upcomingDescription,
                            iconData: LucideIcons.calendarClock,
                          ),
                          const InfoSummaryTab(
                            label: 'History',
                            description: 'Your past sessions will appear here.',
                            iconData: LucideIcons.history,
                          ),
                        ];
                        return InfoSummary(
                          tabs: tabs,
                          iconData: LucideIcons.activity,
                          onActionPressed: _handleBookingsNavigation,
                          actionLabel: 'View bookings',
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                    ShortcutsDisplay(shortcuts: shortcuts, spacing: 8),
                    const SizedBox(height: 32),
                    Obx(() {
                      final blogs = _blogController.blogs;
                      if (blogs.isNotEmpty) {
                        // Reactive: refreshes on-time when a "new blog" push
                        // arrives via BlogController.
                        return BlogSlider(blogs: blogs.toList());
                      }
                      // No blogs (or still loading / failed): keep the original
                      // promotional slider so home is never empty.
                      return InfoSlider(slides: sliderSlides);
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildUpcomingDescription(
    AvailableSlotDto? slot, {
    required bool isLoading,
    Object? error,
  }) {
    if (isLoading) {
      return 'Loading your next booking...';
    }
    if (error != null) {
      return 'We could not load your upcoming bookings.';
    }
    if (slot == null) {
      return 'You have no upcoming bookings at FitnessCenter.';
    }
    final timeText = DateTimeCell.formatTime(slot.schedulingDate);
    final service = slot.serviceName.isEmpty ? 'Class' : slot.serviceName;
    final trainer = slot.trainerName.isEmpty ? '' : ' with ${slot.trainerName}';
    final location = slot.locationName.isEmpty
        ? 'FitnessCenter'
        : slot.locationName;
    if (_isToday(slot.schedulingDate)) {
      return 'Today: $service$trainer at $location, $timeText.';
    }
    final dateText = DateTimeCell.formatDate(slot.schedulingDate);
    return 'Next: $service$trainer at $location, $dateText at $timeText.';
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
      title: 'Booking for today',
      body:
          '${slot.serviceName.isEmpty ? 'Class' : slot.serviceName} · ${slot.locationName} · ${DateTimeCell.formatTime(slot.schedulingDate)}',
      payload: const {'action': 'open_member_bookings'},
    );
  }
}

import 'package:portfolio_mobile_app/app/config/app_router.dart';
import 'package:portfolio_mobile_app/app/config/app_routes.dart';
import 'package:portfolio_mobile_app/app/core/api/blog_api.dart';
import 'package:portfolio_mobile_app/app/core/api/booking_agenda_api.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/blog/blog_dto.dart';
import 'package:portfolio_mobile_app/app/core/auth/auth.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/brand/brand_header.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/buttons/login_submit_button.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/layout/page_header.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/row_cells/date_time_cell.dart';
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

const _sliderImage = 'assets/info_slider_image.png';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const int _scheduleTabIndex = 4;
  static const int _bookingsTabIndex = 1;
  static const int _fitnessDirectoryTabIndex = 6;

  late final BookingAgendaApi _bookingsApi;
  late final BlogApi _blogApi;
  late final Future<AvailableSlotDto?> _todayBooking;
  late final Future<List<BlogDto>> _blogs;
  bool _hasNotified = false;

  @override
  void initState() {
    super.initState();
    _bookingsApi = BookingAgendaApi();
    _blogApi = BlogApi();
    _todayBooking = _loadTodayBooking();
    _blogs = _loadBlogs();
  }

  Future<List<BlogDto>> _loadBlogs() async {
    try {
      return await _blogApi.getBlogs();
    } catch (_) {
      // Non-critical: fall back to the static slider if blogs cannot load.
      return const <BlogDto>[];
    }
  }

  Future<AvailableSlotDto?> _loadTodayBooking() async {
    try {
      return await _bookingsApi.getTodayBooking();
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

  void _handleAgendaNavigation() {
    if (Get.isRegistered<AppRouter>()) {
      Get.find<AppRouter>().changeTab(_scheduleTabIndex);
      return;
    }
    Get.toNamed(AppRoutes.memberBookings);
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
        imageAsset: _sliderImage,
      ),
      const InfoSlide(
        title: 'Train smarter, hassle-free',
        description: 'Book and manage your classes from anywhere',
        callToAction: 'Start today',
        imageAsset: _sliderImage,
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
        iconData: LucideIcons.activity,
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
                      onPressed: _handleAgendaNavigation,
                    ),
                    const SizedBox(height: 22),
                    FutureBuilder<AvailableSlotDto?>(
                      future: _todayBooking,
                      builder: (context, snapshot) {
                        final slot = snapshot.data;
                        if (slot != null &&
                            !_hasNotified &&
                            snapshot.connectionState == ConnectionState.done) {
                          _notifyTodayBooking(slot);
                        }
                        final todayDescription = _buildTodayDescription(
                          slot,
                          isLoading:
                              snapshot.connectionState ==
                              ConnectionState.waiting,
                          error: snapshot.error,
                        );
                        final tabs = [
                          InfoSummaryTab(
                            label: 'Upcoming Bookings',
                            description: todayDescription,
                          ),
                          const InfoSummaryTab(
                            label: 'History',
                            description: 'Your past sessions will appear here.',
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
                    FutureBuilder<List<BlogDto>>(
                      future: _blogs,
                      builder: (context, snapshot) {
                        final blogs = snapshot.data ?? const <BlogDto>[];
                        if (blogs.isNotEmpty) {
                          return BlogSlider(blogs: blogs);
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

  String _buildTodayDescription(
    AvailableSlotDto? slot, {
    required bool isLoading,
    Object? error,
  }) {
    if (isLoading) {
      return 'Loading your booking for today...';
    }
    if (error != null) {
      return 'We could not load your booking for today.';
    }
    if (slot == null) {
      return 'You have no upcoming bookings at FitnessCenter.';
    }
    final dateText = DateTimeCell.formatDate(slot.schedulingDate);
    final timeText = DateTimeCell.formatTime(slot.schedulingDate);
    final service = slot.serviceName.isEmpty ? 'Class' : slot.serviceName;
    final trainer = slot.trainerName.isEmpty ? '' : ' with ${slot.trainerName}';
    return 'Today: $service$trainer at ${slot.locationName}, $dateText at $timeText.';
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

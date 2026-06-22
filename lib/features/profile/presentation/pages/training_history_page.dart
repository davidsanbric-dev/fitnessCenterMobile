import 'package:fitnesscenter_mobile/app/core/shared/widgets/layout/page_header_config.dart';
import 'package:fitnesscenter_mobile/app/core/viewmodel/shared_view_model_host.dart';
import 'package:fitnesscenter_mobile/features/bookings/presentation/widgets/bookings_table.dart';
import 'package:fitnesscenter_mobile/features/profile/feature.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

/// Read-only list of the member's COMPLETED bookings, opened as an in-page
/// sub-view of the profile (mirrors the Personal Information breadcrumb pattern).
class TrainingHistoryView extends StatefulWidget {
  const TrainingHistoryView({super.key, this.onBack, this.onHeaderChanged});

  final VoidCallback? onBack;

  /// When provided, reports the header up instead of rendering it directly,
  /// letting a host (the bottom-nav shell) own a single header that
  /// crossfades between tabs.
  final PageHeaderReporter? onHeaderChanged;

  @override
  State<TrainingHistoryView> createState() => _TrainingHistoryViewState();
}

class _TrainingHistoryViewState extends State<TrainingHistoryView>
    with SharedViewModelHost<TrainingHistoryView, TrainingHistoryViewModel> {
  @override
  TrainingHistoryViewModel createViewModel() =>
      ProfileInjector.getTrainingHistoryViewModel();

  @override
  void initState() {
    super.initState();
    acquireViewModel();
    // The controller used to load on GetX `onReady`; the ChangeNotifier model
    // has no such hook, so kick off the initial load once mounted.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      viewModel.loadHistory();
    });
  }

  @override
  void dispose() {
    releaseViewModel();
    super.dispose();
  }

  Future<void> _refresh() => viewModel.reload();

  PageHeaderConfig _resolveHeaderConfig() {
    if (widget.onBack == null) {
      return const PageHeaderConfig(title: 'Training History');
    }
    return PageHeaderConfig(
      title: 'My Profile',
      subtitle: 'Training History',
      subtitleIcon: LucideIcons.history,
      onBackButtonPressed: widget.onBack,
    );
  }

  Widget _buildHeader() {
    return PageHeaderSlot(
      config: _resolveHeaderConfig(),
      reporter: widget.onHeaderChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: ListenableBuilder(
                listenable: viewModel,
                builder: (context, _) {
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        BookingsTable(
                          bookings: viewModel.pageRows,
                          isLoading: viewModel.isLoading,
                          errorMessage: viewModel.error,
                          onViewDetails: viewModel.showBookingDetails,
                          pageNumber: viewModel.pageNumber,
                          pageSize: viewModel.pageSize,
                          totalItems: viewModel.totalItems,
                          onPageChanged: viewModel.setPageNumber,
                          showPagination: true,
                          emptyLabel: 'No completed sessions yet.',
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:fitnesscenter_mobile/app/config/app_theme.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/layout/page_header_config.dart';
import 'package:fitnesscenter_mobile/app/core/viewmodel/shared_view_model_host.dart';
import 'package:fitnesscenter_mobile/features/profile/feature.dart';
import 'package:fitnesscenter_mobile/features/profile/presentation/widgets/assessment_feedback_card.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

/// Read-only list of the member's completed sessions that carry a trainer
/// feedback note. Opened as an in-page sub-view of the profile, mirroring the
/// Personal Information / Training History breadcrumb pattern.
class AssessmentResultsView extends StatefulWidget {
  const AssessmentResultsView({super.key, this.onBack, this.onHeaderChanged});

  final VoidCallback? onBack;

  /// When provided, reports the header up instead of rendering it directly,
  /// letting a host (the bottom-nav shell) own a single header that
  /// crossfades between tabs.
  final PageHeaderReporter? onHeaderChanged;

  @override
  State<AssessmentResultsView> createState() => _AssessmentResultsViewState();
}

class _AssessmentResultsViewState extends State<AssessmentResultsView>
    with
        SharedViewModelHost<AssessmentResultsView, AssessmentResultsViewModel> {
  @override
  AssessmentResultsViewModel createViewModel() =>
      ProfileInjector.getAssessmentResultsViewModel();

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
      viewModel.load();
    });
  }

  @override
  void dispose() {
    releaseViewModel();
    super.dispose();
  }

  PageHeaderConfig _resolveHeaderConfig() {
    if (widget.onBack == null) {
      return const PageHeaderConfig(title: 'Assessment Results');
    }
    return PageHeaderConfig(
      title: 'My Profile',
      subtitle: 'Assessment Results',
      subtitleIcon: LucideIcons.clipboardList,
      onBackButtonPressed: widget.onBack,
    );
  }

  Widget _buildHeader() {
    return PageHeaderSlot(
      config: _resolveHeaderConfig(),
      reporter: widget.onHeaderChanged,
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.clipboardList,
              size: 48,
              color: AppTheme.secondaryTextColor(context),
            ),
            const SizedBox(height: 16),
            Text(
              'No assessment notes yet.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.secondaryTextColor(context),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your trainer\'s feedback will appear here after a completed session.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.mutedTextColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.danger),
        ),
      ),
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
            child: ListenableBuilder(
              listenable: viewModel,
              builder: (context, _) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final errorMsg = viewModel.error;
                if (errorMsg != null) {
                  return _buildError(context, errorMsg);
                }

                final items = viewModel.assessments;

                return RefreshIndicator(
                  onRefresh: viewModel.reload,
                  child: items.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.45,
                              child: _buildEmpty(context),
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                          itemCount: items.length,
                          itemBuilder: (context, index) =>
                              AssessmentFeedbackCard(
                                booking: items[index],
                                initiallyExpanded: index == 0,
                              ),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/layout/page_header.dart';
import 'package:portfolio_mobile_app/features/profile/logic/assessment_results_controller.dart';
import 'package:portfolio_mobile_app/features/profile/presentation/widgets/assessment_feedback_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

/// Read-only list of the member's completed sessions that carry a trainer
/// feedback note. Opened as an in-page sub-view of the profile, mirroring the
/// Personal Information / Training History breadcrumb pattern.
class AssessmentResultsView extends StatefulWidget {
  const AssessmentResultsView({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  State<AssessmentResultsView> createState() => _AssessmentResultsViewState();
}

class _AssessmentResultsViewState extends State<AssessmentResultsView> {
  late final AssessmentResultsController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<AssessmentResultsController>()) {
      _controller = Get.find<AssessmentResultsController>();
      _ownsController = false;
    } else {
      _controller = Get.put(AssessmentResultsController());
      _ownsController = true;
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      Get.delete<AssessmentResultsController>();
    }
    super.dispose();
  }

  Widget _buildHeader() {
    if (widget.onBack == null) {
      return const PageHeader(title: 'Assessment Results');
    }
    return PageHeader(
      title: 'My Profile',
      subtitle: 'Assessment Results',
      subtitleIcon: LucideIcons.clipboardList,
      onBackButtonPressed: widget.onBack,
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
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.danger,
          ),
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
            child: Obx(() {
              if (_controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final errorMsg = _controller.error.value;
              if (errorMsg != null) {
                return _buildError(context, errorMsg);
              }

              final items = _controller.assessments;

              return RefreshIndicator(
                onRefresh: _controller.reload,
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
            }),
          ),
        ],
      ),
    );
  }
}

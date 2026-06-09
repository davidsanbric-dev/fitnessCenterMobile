import 'package:portfolio_mobile_app/app/core/shared/widgets/layout/page_header.dart';
import 'package:portfolio_mobile_app/features/bookings/presentation/widgets/bookings_table.dart';
import 'package:portfolio_mobile_app/features/profile/logic/training_history_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

/// Read-only list of the member's COMPLETED bookings, opened as an in-page
/// sub-view of the profile (mirrors the Personal Information breadcrumb pattern).
class TrainingHistoryView extends StatefulWidget {
  const TrainingHistoryView({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  State<TrainingHistoryView> createState() => _TrainingHistoryViewState();
}

class _TrainingHistoryViewState extends State<TrainingHistoryView> {
  late final TrainingHistoryController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<TrainingHistoryController>()) {
      _controller = Get.find<TrainingHistoryController>();
      _ownsController = false;
    } else {
      _controller = Get.put(TrainingHistoryController());
      _ownsController = true;
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      Get.delete<TrainingHistoryController>();
    }
    super.dispose();
  }

  Future<void> _refresh() => _controller.reload();

  Widget _buildHeader() {
    if (widget.onBack == null) {
      return const PageHeader(title: 'Training History');
    }
    return PageHeader(
      title: 'My Profile',
      subtitle: 'Training History',
      subtitleIcon: LucideIcons.history,
      onBackButtonPressed: widget.onBack,
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
              child: Obx(() {
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      BookingsTable(
                        bookings: _controller.pageRows,
                        isLoading: _controller.isLoading.value,
                        errorMessage: _controller.error.value,
                        onViewDetails: _controller.showBookingDetails,
                        pageNumber: _controller.pageNumber.value,
                        pageSize: _controller.pageSize.value,
                        totalItems: _controller.totalItems.value,
                        onPageChanged: _controller.setPageNumber,
                        showPagination: true,
                        emptyLabel: 'No completed sessions yet.',
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

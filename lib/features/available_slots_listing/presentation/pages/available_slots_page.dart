import 'package:fitnesscenter_mobile/app/config/app_router.dart';
import 'package:fitnesscenter_mobile/app/config/app_tab.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/presentation/widgets/book_session_flow.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AvailableSlotsPage extends StatefulWidget {
  const AvailableSlotsPage({super.key});

  @override
  State<AvailableSlotsPage> createState() => _AvailableSlotsPageState();
}

class _AvailableSlotsPageState extends State<AvailableSlotsPage> {
  final GlobalKey<BookSessionFlowState> _flowKey =
      GlobalKey<BookSessionFlowState>();
  AppRouter? _appRouter;
  Worker? _navWorker;

  @override
  void initState() {
    super.initState();
    _attachNavListener();
  }

  @override
  void dispose() {
    _navWorker?.dispose();
    super.dispose();
  }

  void _attachNavListener() {
    if (!Get.isRegistered<AppRouter>()) {
      return;
    }
    _appRouter = Get.find<AppRouter>();
    _navWorker = ever<AppTab>(_appRouter!.current, (tab) {
      if (tab == AppTab.availableSlots) {
        return;
      }
      _flowKey.currentState?.resetToInitial();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(top: false, child: BookSessionFlow(key: _flowKey)),
    );
  }
}

import 'package:portfolio_mobile_app/app/core/shared/widgets/buttons/consult_button.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/feature.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/types.dart';
import 'package:flutter/material.dart';

bool shouldShowConsultButton({
  required String? selectedService,
  required TextEditingController primaryController,
  required List<String> primaryOptions,
}) {
  if (selectedService == null) {
    return false;
  }
  return _isControllerValueInOptions(
    primaryController,
    primaryOptions,
  );
}

bool _isControllerValueInOptions(
  TextEditingController controller,
  List<String> options,
) {
  final value = controller.text.trim();
  if (value.isEmpty) {
    return false;
  }
  final normalizedValue = value.toLowerCase();
  return options.any((option) => option.toLowerCase() == normalizedValue);
}

class AvailableSlotsConsultButton extends StatefulWidget {
  const AvailableSlotsConsultButton({
    super.key,
    required this.horizontalPadding,
    required this.selectedService,
    required this.primaryController,
    required this.searchMode,
    required this.filtersController,
    required this.onHideSheet,
    this.buildParams,
  });

  final double horizontalPadding;
  final String? selectedService;
  final TextEditingController primaryController;
  final DisciplineSearchMode searchMode;
  final AvailableSlotsController filtersController;
  final VoidCallback onHideSheet;
  final MemberAvailabilityParams? Function()? buildParams;

  @override
  State<AvailableSlotsConsultButton> createState() =>
      _AvailableSlotsConsultButtonState();
}

class _AvailableSlotsConsultButtonState
    extends State<AvailableSlotsConsultButton> {
  void _handleCheckPressed() {
    final service = widget.selectedService;
    final primaryValue = widget.primaryController.text.trim();

    if (service == null || primaryValue.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select valid options before searching.')),
      );
      return;
    }

    final params = widget.buildParams != null
        ? widget.buildParams!()
        : MemberAvailabilityParams(
            serviceLabel: service,
            primarySelectionLabel: primaryValue,
            searchMode: widget.searchMode,
          );
    if (params == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select valid options before searching.')),
      );
      return;
    }

    widget.filtersController.consultAvailability(params);

    widget.onHideSheet();
  }

  @override
  Widget build(BuildContext context) {
    return ConsultButton(
      horizontalPadding: widget.horizontalPadding,
      onPressed: _handleCheckPressed,
    );
  }
}

import 'package:portfolio_mobile_app/app/core/shared/widgets/forms/form_search_field.dart';
import 'package:flutter/material.dart';

class AvailableSlotsFilterFields extends StatelessWidget {
  const AvailableSlotsFilterFields({
    super.key,
    required this.primaryController,
    required this.locationController,
    required this.primaryFocusNode,
    required this.locationFocusNode,
    required this.primaryPlaceholder,
    this.liftToTop = false,
    this.showOnlyActiveField = false,
    this.activeFocusNode,
    this.primaryFieldKey,
    this.locationFieldKey,
    this.onPrimaryTap,
    this.onLocationTap,
    this.suppressActiveUnderline = false,
  });

  final TextEditingController primaryController;
  final TextEditingController locationController;
  final FocusNode primaryFocusNode;
  final FocusNode locationFocusNode;
  final String primaryPlaceholder;
  final bool liftToTop;
  final bool showOnlyActiveField;
  final FocusNode? activeFocusNode;
  final Key? primaryFieldKey;
  final Key? locationFieldKey;
  final VoidCallback? onPrimaryTap;
  final VoidCallback? onLocationTap;
  final bool suppressActiveUnderline;

  @override
  Widget build(BuildContext context) {
    bool showPrimary =
        !showOnlyActiveField || activeFocusNode == primaryFocusNode;
    bool showLocation =
        !showOnlyActiveField || activeFocusNode == locationFocusNode;

    if (!showPrimary && !showLocation) {
      showPrimary = true;
      showLocation = true;
    }

    final children = <Widget>[];

    if (showPrimary) {
      final hideUnderline =
          suppressActiveUnderline && activeFocusNode == primaryFocusNode;
      Widget field = SearchField(
        controller: primaryController,
        focusNode: primaryFocusNode,
        hintText: primaryPlaceholder,
        showUnderline: !hideUnderline,
        onTap: () {
          primaryFocusNode.requestFocus();
          onPrimaryTap?.call();
        },
      );

      if (primaryFieldKey != null) {
        field = Container(key: primaryFieldKey, child: field);
      }
      children.add(field);
    }

    if (showLocation) {
      if (children.isNotEmpty) {
        children.add(const SizedBox(height: 20));
      }
      final hideUnderline =
          suppressActiveUnderline && activeFocusNode == locationFocusNode;
      Widget field = SearchField(
        controller: locationController,
        focusNode: locationFocusNode,
        hintText: 'Search by club location',
        showUnderline: !hideUnderline,
        onTap: () {
          locationFocusNode.requestFocus();
          onLocationTap?.call();
        },
      );

      if (locationFieldKey != null) {
        field = Container(key: locationFieldKey, child: field);
      }
      children.add(field);
    }

    final fields = Column(children: children);

    if (!liftToTop) {
      return fields;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: fields,
    );
  }
}

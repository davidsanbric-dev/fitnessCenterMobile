import 'package:portfolio_mobile_app/app/core/shared/widgets/forms/form_search_field.dart';
import 'package:flutter/material.dart';

class AvailableSlotsFilterFields extends StatelessWidget {
  const AvailableSlotsFilterFields({
    super.key,
    required this.primaryController,
    required this.primaryFocusNode,
    required this.primaryPlaceholder,
    this.liftToTop = false,
    this.showOnlyActiveField = false,
    this.activeFocusNode,
    this.primaryFieldKey,
    this.onPrimaryTap,
    this.suppressActiveUnderline = false,
  });

  final TextEditingController primaryController;
  final FocusNode primaryFocusNode;
  final String primaryPlaceholder;
  final bool liftToTop;
  final bool showOnlyActiveField;
  final FocusNode? activeFocusNode;
  final Key? primaryFieldKey;
  final VoidCallback? onPrimaryTap;
  final bool suppressActiveUnderline;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    final hideUnderline =
        suppressActiveUnderline && activeFocusNode == primaryFocusNode;
    Widget field = SearchField(
      controller: primaryController,
      focusNode: primaryFocusNode,
      hintText: primaryPlaceholder,
      showUnderline: !hideUnderline,
      showClearButton: true,
      onTap: () {
        primaryFocusNode.requestFocus();
        onPrimaryTap?.call();
      },
    );

    if (primaryFieldKey != null) {
      field = Container(key: primaryFieldKey, child: field);
    }
    children.add(field);

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

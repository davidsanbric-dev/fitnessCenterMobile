import 'package:flutter/material.dart';

import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/buttons/create_button.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/table_header.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/table_pagination.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/table_title.dart';

export 'package:portfolio_mobile_app/app/core/shared/widgets/table/table_pagination.dart'
    show TableCardPaginationConfig;

class TableCardCreateButtonConfig {
  const TableCardCreateButtonConfig({
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.loadingLabel,
    this.icon = const Icon(Icons.add),
    this.loadingIcon,
    this.spacing = 12,
    this.alignment = Alignment.centerLeft,
    this.style,
  });

  final VoidCallback? onPressed;
  final bool isLoading;
  final String label;
  final String? loadingLabel;
  final Widget icon;
  final Widget? loadingIcon;
  final double spacing;
  final Alignment alignment;
  final ButtonStyle? style;
}

class TableCard extends StatelessWidget {
  const TableCard({
    super.key,
    this.title,
    this.headers,
    required this.body,
    this.icon = Icons.admin_panel_settings,
    this.showTitle = true,
    this.showHeader = true,
    this.toolbar,
    this.toolbarSpacing = 8,
    this.createButton,
    this.height,
    this.heightFactor = 0.4,
    this.width = double.infinity,
    this.margin = const EdgeInsets.all(16),
    this.padding = const EdgeInsets.all(16),
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.headerSpacing = 12,
    this.bodySpacing = 0,
    this.titlePadding,
    this.pagination,
  });

  final String? title;
  final IconData icon;
  final List<String>? headers;
  final Widget body;
  final bool showTitle;
  final bool showHeader;
  final Widget? toolbar;
  final double toolbarSpacing;
  final TableCardCreateButtonConfig? createButton;
  final double? height;
  final double heightFactor;
  final double? width;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final double headerSpacing;
  final double bodySpacing;
  final EdgeInsetsGeometry? titlePadding;
  final TableCardPaginationConfig? pagination;

  @override
  Widget build(BuildContext context) {
    final resolvedHeight =
        height ?? MediaQuery.of(context).size.height * heightFactor;
    final resolvedHeaders = headers ?? const <String>[];
    final hasTitle = title != null && title!.trim().isNotEmpty;
    final shouldShowTitle = showTitle && hasTitle;
    final shouldShowHeader = showHeader && resolvedHeaders.length > 1;
    final resolvedToolbar = toolbar;

    final columnChildren = <Widget>[
      if (shouldShowTitle)
        TableTitle(
          text: title!,
          icon: icon,
          padding:
              titlePadding ?? const EdgeInsets.only(bottom: 8, left: 4, top: 4),
        ),
      if (createButton != null)
        CreateButton(
          label: createButton!.label,
          onPressed: createButton!.onPressed,
          isLoading: createButton!.isLoading,
          loadingLabel: createButton!.loadingLabel,
          icon: createButton!.icon,
          loadingIcon: createButton!.loadingIcon,
          spacing: createButton!.spacing,
          alignment: createButton!.alignment,
          style: createButton!.style,
        ),
      if (resolvedToolbar != null) ...[
        if (toolbarSpacing > 0) SizedBox(height: toolbarSpacing),
        resolvedToolbar,
      ],
      if (shouldShowHeader && headerSpacing > 0)
        SizedBox(height: headerSpacing),
      if (shouldShowHeader) TableHeader(headers: resolvedHeaders),
      if (bodySpacing > 0) SizedBox(height: bodySpacing),
      body,
      if (pagination != null) TablePagination(config: pagination!),
    ];

    return Container(
      height: resolvedHeight,
      width: width,
      margin: margin,
      padding: padding,
      decoration: AppTheme.tableCardDecoration,
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        children: columnChildren,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:fitnesscenter_mobile/app/config/app_theme.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class ResolvedTablePagination {
  const ResolvedTablePagination({
    required this.pageNumber,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });

  final int pageNumber;
  final int pageSize;
  final int totalItems;
  final int totalPages;
}

ResolvedTablePagination resolveTablePagination({
  required int totalItems,
  required int pageNumber,
  required int pageSize,
  required int defaultPageSize,
}) {
  final resolvedPageSize = resolveTablePageSize(
    pageSize,
    defaultPageSize: defaultPageSize,
  );
  final resolvedTotalItems = totalItems < 0 ? 0 : totalItems;
  final totalPages = resolvedTotalItems == 0
      ? 0
      : (resolvedTotalItems + resolvedPageSize - 1) ~/ resolvedPageSize;
  final resolvedPageNumber = totalPages == 0
      ? 1
      : pageNumber.clamp(1, totalPages).toInt();

  return ResolvedTablePagination(
    pageNumber: resolvedPageNumber,
    pageSize: resolvedPageSize,
    totalItems: resolvedTotalItems,
    totalPages: totalPages,
  );
}

bool setTablePageNumber({
  required RxInt pageNumber,
  required int value,
  required VoidCallback syncPagination,
}) {
  if (value < 1 || value == pageNumber.value) {
    return false;
  }

  pageNumber.value = value;
  syncPagination();
  return true;
}

bool setTablePageSize({
  required RxInt pageNumber,
  required RxInt pageSize,
  required int value,
  required VoidCallback syncPagination,
}) {
  if (value < 1 || value == pageSize.value) {
    return false;
  }

  pageSize.value = value;
  pageNumber.value = 1;
  syncPagination();
  return true;
}

ResolvedTablePagination syncTablePaginationState({
  required int totalItems,
  required RxInt pageNumber,
  required RxInt pageSize,
  required int defaultPageSize,
  ValueChanged<int>? onTotalItemsResolved,
}) {
  final pagination = resolveTablePagination(
    totalItems: totalItems,
    pageNumber: pageNumber.value,
    pageSize: pageSize.value,
    defaultPageSize: defaultPageSize,
  );
  onTotalItemsResolved?.call(pagination.totalItems);
  if (pagination.pageNumber != pageNumber.value) {
    pageNumber.value = pagination.pageNumber;
  }
  if (pagination.pageSize != pageSize.value) {
    pageSize.value = pagination.pageSize;
  }
  return pagination;
}

// ChangeNotifier-friendly variants of the helpers above: they operate on plain
// `int` state via setter callbacks instead of `RxInt`, for view-models that
// drive rebuilds with `notifyListeners()` rather than GetX reactivity.
bool applyTablePageNumber({
  required int currentPageNumber,
  required int value,
  required ValueChanged<int> setPageNumber,
  required VoidCallback syncPagination,
}) {
  if (value < 1 || value == currentPageNumber) {
    return false;
  }

  setPageNumber(value);
  syncPagination();
  return true;
}

bool applyTablePageSize({
  required int currentPageSize,
  required int value,
  required ValueChanged<int> setPageNumber,
  required ValueChanged<int> setPageSize,
  required VoidCallback syncPagination,
}) {
  if (value < 1 || value == currentPageSize) {
    return false;
  }

  setPageSize(value);
  setPageNumber(1);
  syncPagination();
  return true;
}

ResolvedTablePagination syncTablePaginationValues({
  required int totalItems,
  required int pageNumber,
  required int pageSize,
  required int defaultPageSize,
  required ValueChanged<int> setPageNumber,
  required ValueChanged<int> setPageSize,
  ValueChanged<int>? onTotalItemsResolved,
}) {
  final pagination = resolveTablePagination(
    totalItems: totalItems,
    pageNumber: pageNumber,
    pageSize: pageSize,
    defaultPageSize: defaultPageSize,
  );
  onTotalItemsResolved?.call(pagination.totalItems);
  if (pagination.pageNumber != pageNumber) {
    setPageNumber(pagination.pageNumber);
  }
  if (pagination.pageSize != pageSize) {
    setPageSize(pagination.pageSize);
  }
  return pagination;
}

List<T> sliceTablePage<T>(
  List<T> items, {
  required int pageNumber,
  required int pageSize,
  required int defaultPageSize,
}) {
  if (items.isEmpty) {
    return List<T>.empty();
  }

  final resolvedPageNumber = pageNumber > 0 ? pageNumber : 1;
  final resolvedPageSize = resolveTablePageSize(
    pageSize,
    defaultPageSize: defaultPageSize,
  );
  final startIndex = (resolvedPageNumber - 1) * resolvedPageSize;
  if (startIndex >= items.length) {
    return List<T>.empty();
  }

  final endIndex = (startIndex + resolvedPageSize)
      .clamp(0, items.length)
      .toInt();
  return items.sublist(startIndex, endIndex);
}

int resolveTablePageSize(int pageSize, {required int defaultPageSize}) {
  if (pageSize > 0) {
    return pageSize;
  }
  return defaultPageSize > 0 ? defaultPageSize : 1;
}

class TableCardPaginationConfig {
  const TableCardPaginationConfig({
    this.pageNumber,
    this.pageSize,
    this.totalItems,
    this.onPageChanged,
    this.defaultPageSize = 7,
    this.padding = const EdgeInsets.only(top: 12),
    this.previousTooltip = 'Previous page',
    this.nextTooltip = 'Next page',
    this.zeroResultsLabel = '0 results',
  });

  final int? pageNumber;
  final int? pageSize;
  final int? totalItems;
  final ValueChanged<int>? onPageChanged;
  final int defaultPageSize;
  final EdgeInsetsGeometry padding;
  final String previousTooltip;
  final String nextTooltip;
  final String zeroResultsLabel;
}

class TablePagination extends StatelessWidget {
  const TablePagination({super.key, required this.config});

  final TableCardPaginationConfig config;

  @override
  Widget build(BuildContext context) {
    final resolvedPageSize = _resolvePageSize(config.pageSize);
    final resolvedTotalPages = _resolveTotalPages(config.totalItems);
    final resolvedPageNumber = _resolvePageNumber(
      config.pageNumber,
      resolvedTotalPages,
    );
    final canChangePage = config.onPageChanged != null;
    final canGoPrevious = canChangePage && resolvedPageNumber > 1;
    final canGoNext =
        canChangePage &&
        (resolvedTotalPages == null || resolvedPageNumber < resolvedTotalPages);
    final textStyle = AppTheme.bodySmallMuted(context);

    return Padding(
      padding: config.padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final shouldStack = constraints.maxWidth < 420;
          final summary = _buildSummary(
            resolvedPageNumber: resolvedPageNumber,
            resolvedPageSize: resolvedPageSize,
            totalPages: resolvedTotalPages,
            textStyle: textStyle,
          );
          final controls = _buildControls(
            resolvedPageNumber: resolvedPageNumber,
            totalPages: resolvedTotalPages,
            canGoPrevious: canGoPrevious,
            canGoNext: canGoNext,
            textStyle: textStyle,
            allowWrapping: shouldStack,
          );

          if (shouldStack) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                summary,
                const SizedBox(height: 6),
                Align(alignment: Alignment.centerRight, child: controls),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: summary),
              const SizedBox(width: 8),
              Flexible(
                child: Align(alignment: Alignment.centerRight, child: controls),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummary({
    required int resolvedPageNumber,
    required int resolvedPageSize,
    required int? totalPages,
    TextStyle? textStyle,
  }) {
    if (config.totalItems == null) {
      final label = totalPages == null
          ? 'Page $resolvedPageNumber'
          : 'Page $resolvedPageNumber of $totalPages';
      return Text(label, style: textStyle);
    }

    if (config.totalItems == 0) {
      return Text(config.zeroResultsLabel, style: textStyle);
    }

    final startItem = (resolvedPageNumber - 1) * resolvedPageSize + 1;
    var endItem = resolvedPageNumber * resolvedPageSize;
    if (endItem > config.totalItems!) {
      endItem = config.totalItems!;
    }
    return Text(
      'Showing $startItem-$endItem of ${config.totalItems}',
      style: textStyle,
    );
  }

  Widget _buildControls({
    required int resolvedPageNumber,
    required int? totalPages,
    required bool canGoPrevious,
    required bool canGoNext,
    bool allowWrapping = false,
    TextStyle? textStyle,
  }) {
    final pageLabel = totalPages == null
        ? 'Page $resolvedPageNumber'
        : 'Page $resolvedPageNumber of $totalPages';
    final pageIndicator = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 180),
      child: Text(
        pageLabel,
        style: textStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );

    final previousButton = IconButton(
      onPressed: canGoPrevious
          ? () => config.onPageChanged!(resolvedPageNumber - 1)
          : null,
      tooltip: config.previousTooltip,
      icon: const Icon(LucideIcons.chevronLeft),
      iconSize: 20,
      visualDensity: VisualDensity.compact,
    );
    final nextButton = IconButton(
      onPressed: canGoNext
          ? () => config.onPageChanged!(resolvedPageNumber + 1)
          : null,
      tooltip: config.nextTooltip,
      icon: const Icon(LucideIcons.chevronRight),
      iconSize: 20,
      visualDensity: VisualDensity.compact,
    );

    if (allowWrapping) {
      return Wrap(
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 6,
        children: [previousButton, pageIndicator, nextButton],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        previousButton,
        const SizedBox(width: 2),
        pageIndicator,
        const SizedBox(width: 2),
        nextButton,
      ],
    );
  }

  int _resolvePageSize(int? value) {
    return resolveTablePageSize(
      value ?? 0,
      defaultPageSize: config.defaultPageSize,
    );
  }

  int _resolvePageNumber(int? value, int? totalPages) {
    var resolved = value ?? 1;
    if (resolved < 1) {
      resolved = 1;
    }
    if (totalPages != null && resolved > totalPages) {
      resolved = totalPages;
    }
    return resolved;
  }

  int? _resolveTotalPages(int? totalItems) {
    if (totalItems == null) {
      return null;
    }
    if (totalItems <= 0) {
      return 1;
    }
    final pageSize = _resolvePageSize(config.pageSize);
    return (totalItems + pageSize - 1) ~/ pageSize;
  }
}

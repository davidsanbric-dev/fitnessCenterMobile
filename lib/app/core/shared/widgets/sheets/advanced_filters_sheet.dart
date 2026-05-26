import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:portfolio_mobile_app/app/core/utils/format/input.dart';
import 'package:portfolio_mobile_app/app/core/utils/normalize.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class AdvancedFilterDropdownOption<T> {
  const AdvancedFilterDropdownOption({
    required this.value,
    required this.label,
  });

  final T value;
  final String label;
}

class AdvancedFiltersSheetResult<TMember, TLocation> {
  const AdvancedFiltersSheetResult({this.memberValue, this.locationValue});

  final TMember? memberValue;
  final TLocation? locationValue;
}

bool _isCompleteRut(String value) {
  final sanitized = sanitizeRutInput(value);
  return sanitized.length == 8 || sanitized.length == 9;
}

class _MemberIdInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final sanitized = sanitizeRutInput(newValue.text);
    final formatted = formatRut(sanitized);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Displays a reusable bottom sheet with dropdowns to select member and/or
/// location filters. Returns the chosen values when the user taps "Apply".
Future<AdvancedFiltersSheetResult<TMember, TLocation>?>
showAdvancedFiltersSheet<TMember, TLocation>({
  required BuildContext context,
  List<AdvancedFilterDropdownOption<TMember>> memberOptions = const [],
  List<AdvancedFilterDropdownOption<TLocation>> locationOptions = const [],
  TMember? selectedMemberValue,
  TLocation? selectedLocationValue,
  TMember? resetMemberValue,
  TLocation? resetLocationValue,
  String memberLabel = 'Member',
  String memberSearchLabel = 'Member ID',
  String? memberSearchValue,
  String locationLabel = 'Club location',
  Future<AdvancedFilterDropdownOption<TMember>?> Function(String memberId)?
  onMemberSearch,
}) async {
  final canSearchMember = onMemberSearch != null;
  final hasMemberFilters = memberOptions.isNotEmpty || canSearchMember;
  final hasLocationFilters = locationOptions.isNotEmpty;
  if (!hasMemberFilters && !hasLocationFilters) {
    return null;
  }

  final memberSearchController = TextEditingController(
    text: memberSearchValue ?? '',
  );
  final memberSearchFocus = FocusNode();
  final memberDropdownKey = GlobalKey<FormFieldState<TMember?>>();
  final locationDropdownKey = GlobalKey<FormFieldState<TLocation?>>();
  var memberOptionsState = List<AdvancedFilterDropdownOption<TMember>>.from(
    memberOptions,
  );
  var isSearching = false;

  final effectiveSelectedLocation =
      selectedLocationValue ??
      (hasLocationFilters ? locationOptions.first.value : null);
  final effectiveResetLocation =
      resetLocationValue ??
      (hasLocationFilters ? locationOptions.first.value : null);

  final result =
      await showModalBottomSheet<
        AdvancedFiltersSheetResult<TMember, TLocation>
      >(
        context: context,
        useSafeArea: true,
        showDragHandle: true,
        builder: (sheetContext) {
          TMember? tempMember = selectedMemberValue;
          TLocation? tempLocation = effectiveSelectedLocation;

          return StatefulBuilder(
            builder: (sheetContext, setState) {
              Future<void> runMemberSearch() async {
                if (onMemberSearch == null) return;

                final query = memberSearchController.text.trim();
                if (query.isEmpty || !_isCompleteRut(query) || isSearching) {
                  return;
                }
                setState(() {
                  isSearching = true;
                });

                final result = await onMemberSearch(query);
                if (!sheetContext.mounted) return;

                setState(() {
                  isSearching = false;
                  if (result == null) return;

                  if (memberOptionsState.isNotEmpty &&
                      memberOptionsState.first.value == null) {
                    memberOptionsState = [memberOptionsState.first, result];
                  } else {
                    memberOptionsState = [result];
                  }
                  tempMember = result.value;
                  memberDropdownKey.currentState?.didChange(tempMember);
                });
              }

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Advanced filters',
                        style: Theme.of(sheetContext).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      if (canSearchMember) ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: memberSearchController,
                                focusNode: memberSearchFocus,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.search,
                                inputFormatters: [_MemberIdInputFormatter()],
                                decoration: InputDecoration(
                                  labelText: memberSearchLabel,
                                  border: const OutlineInputBorder(),
                                ),
                                onChanged: (_) => setState(() {}),
                                onFieldSubmitted: (_) {
                                  if (_isCompleteRut(
                                    memberSearchController.text,
                                  )) {
                                    runMemberSearch();
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              height: 56,
                              child: FilledButton.icon(
                                onPressed:
                                    isSearching ||
                                        !_isCompleteRut(
                                          memberSearchController.text,
                                        )
                                    ? null
                                    : runMemberSearch,
                                icon: isSearching
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(LucideIcons.search),
                                label: const Text('Search'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppTheme.brandBlue,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (hasMemberFilters) ...[
                        DropdownButtonFormField<TMember?>(
                          key: memberDropdownKey,
                          isExpanded: true,
                          initialValue: tempMember,
                          decoration: InputDecoration(
                            labelText: memberLabel,
                            border: const OutlineInputBorder(),
                          ),
                          items: memberOptionsState
                              .map(
                                (option) => DropdownMenuItem<TMember?>(
                                  value: option.value,
                                  child: Text(option.label),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: (value) {
                            setState(() {
                              tempMember = value;
                            });
                          },
                        ),
                      ],
                      if (hasLocationFilters) ...[
                        if (hasMemberFilters) const SizedBox(height: 16),
                        DropdownButtonFormField<TLocation?>(
                          key: locationDropdownKey,
                          isExpanded: true,
                          initialValue: tempLocation,
                          decoration: InputDecoration(
                            labelText: locationLabel,
                            border: const OutlineInputBorder(),
                          ),
                          items: locationOptions
                              .map(
                                (option) => DropdownMenuItem<TLocation?>(
                                  value: option.value,
                                  child: Text(option.label),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              tempLocation = value;
                            });
                          },
                        ),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                tempMember = resetMemberValue;
                                tempLocation = effectiveResetLocation;
                                memberDropdownKey.currentState?.didChange(
                                  tempMember,
                                );
                                locationDropdownKey.currentState?.didChange(
                                  tempLocation,
                                );
                              });
                            },
                            icon: const Icon(LucideIcons.refreshCw),
                            label: const Text('Reset'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.brandBlue,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              Navigator.of(sheetContext).pop();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.brandBlue,
                            ),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: () {
                              Navigator.of(sheetContext).pop(
                                AdvancedFiltersSheetResult<TMember, TLocation>(
                                  memberValue: tempMember,
                                  locationValue: tempLocation,
                                ),
                              );
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.brandBlue,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Apply'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );

  memberSearchController.dispose();
  memberSearchFocus.dispose();
  return result;
}

import 'package:fitnesscenter_mobile/l10n/app_localizations.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/memberships/membership_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/table/table_pagination.dart';
import 'package:fitnesscenter_mobile/app/core/viewmodel/view_model_base.dart';
import 'package:fitnesscenter_mobile/features/fitness_directory/domain/domain.dart';
import 'package:fitnesscenter_mobile/features/fitness_directory/types.dart';

class FitnessDirectoryViewModel extends ViewModelBase {
  FitnessDirectoryViewModel({
    required MembershipsDirectoryRepository repository,
  }) : _repository = repository;

  final MembershipsDirectoryRepository _repository;
  static const int _defaultMembershipsPageSize = 6;

  FitnessDirectoryView view = FitnessDirectoryView.options;
  bool isLoading = false;
  String? error;

  final List<MembershipDto> memberships = <MembershipDto>[];
  int membershipsPageNumber = 1;
  int membershipsPageSize = _defaultMembershipsPageSize;
  int membershipsTotalItems = 0;

  List<Map<String, dynamic>> membershipsRows(AppLocalizations l10n) {
    final rows = memberships
        .map(
          (item) => {
            'id': item.membershipId,
            'name': item.membershipName,
            'price': _formatPrice(l10n, item.price),
            'maxBookings': _formatMaxBookings(l10n, item.maxBookingsPerMonth),
          },
        )
        .toList(growable: false);
    return sliceTablePage(
      rows,
      pageNumber: membershipsPageNumber,
      pageSize: membershipsPageSize,
      defaultPageSize: _defaultMembershipsPageSize,
    );
  }

  Future<void> loadMemberships({bool forceRefresh = false}) async {
    view = FitnessDirectoryView.memberships;
    if (!forceRefresh && memberships.isNotEmpty && error == null) {
      _syncMembershipsPagination();
      return;
    }

    await runLoad<List<MembershipDto>>(
      setLoading: (value) => isLoading = value,
      setError: (message) => error = message,
      loader: () => _repository.fetchMemberships(),
      onSuccess: (response) {
        memberships
          ..clear()
          ..addAll(response);
        membershipsPageNumber = 1;
        _syncMembershipsPagination();
      },
      onError: () {
        memberships.clear();
        _syncMembershipsPagination();
      },
      unexpectedErrorMessage: 'Unexpected error while loading membership plans',
    );
  }

  void resetToInitialState() {
    isLoading = false;
    error = null;
    view = FitnessDirectoryView.options;
    memberships.clear();
    membershipsPageNumber = 1;
    membershipsPageSize = _defaultMembershipsPageSize;
    _syncMembershipsPagination();
  }

  void showDirectoryOptions() {
    view = FitnessDirectoryView.options;
    error = null;
    notifyListeners();
  }

  void showDisciplines() {
    view = FitnessDirectoryView.disciplines;
    error = null;
    notifyListeners();
  }

  void showDisciplineAvailabilityView() {
    view = FitnessDirectoryView.disciplineAvailability;
    error = null;
    notifyListeners();
  }

  void showTrainers() {
    view = FitnessDirectoryView.trainers;
    error = null;
    notifyListeners();
  }

  void showCapabilities() {
    view = FitnessDirectoryView.capabilities;
    error = null;
    notifyListeners();
  }

  void setMembershipsPageNumber(int value) => applyTablePageNumber(
    currentPageNumber: membershipsPageNumber,
    value: value,
    setPageNumber: (v) => membershipsPageNumber = v,
    syncPagination: _syncMembershipsPagination,
  );

  void setMembershipsPageSize(int value) => applyTablePageSize(
    currentPageSize: membershipsPageSize,
    value: value,
    setPageNumber: (v) => membershipsPageNumber = v,
    setPageSize: (v) => membershipsPageSize = v,
    syncPagination: _syncMembershipsPagination,
  );

  String _formatPrice(AppLocalizations l10n, double? price) {
    if (price == null) {
      return '';
    }
    // Drop the decimals for whole amounts (e.g. 30 -> "$30"), keep cents
    // otherwise (e.g. 29.99 -> "$29.99").
    final isWhole = price == price.roundToDouble();
    final amount = isWhole
        ? price.toStringAsFixed(0)
        : price.toStringAsFixed(2);
    return l10n.planPrice(amount);
  }

  String _formatMaxBookings(AppLocalizations l10n, int? maxBookings) {
    if (maxBookings == null || maxBookings <= 0) {
      return '';
    }
    return maxBookings == 1
        ? l10n.planUpToSession(maxBookings)
        : l10n.planUpToSessions(maxBookings);
  }

  void _syncMembershipsPagination() {
    syncTablePaginationValues(
      totalItems: memberships.length,
      pageNumber: membershipsPageNumber,
      pageSize: membershipsPageSize,
      defaultPageSize: _defaultMembershipsPageSize,
      setPageNumber: (v) => membershipsPageNumber = v,
      setPageSize: (v) => membershipsPageSize = v,
      onTotalItemsResolved: (value) => membershipsTotalItems = value,
    );
    notifyListeners();
  }
}

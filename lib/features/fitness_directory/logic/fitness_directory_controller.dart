import 'package:portfolio_mobile_app/app/core/controller/controller_base.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/memberships/membership_dto.dart';
import 'package:portfolio_mobile_app/app/core/exceptions/api_exception.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/table_pagination.dart';
import 'package:portfolio_mobile_app/features/fitness_directory/domain/domain.dart';
import 'package:portfolio_mobile_app/features/fitness_directory/types.dart';
import 'package:get/get.dart';

class FitnessDirectoryController extends ControllerBase {
  FitnessDirectoryController({MembershipsDirectoryRepository? repository})
    : _repository = repository ?? (throw ArgumentError.notNull('repository'));

  final MembershipsDirectoryRepository _repository;
  static const int _defaultMembershipsPageSize = 6;

  final view = FitnessDirectoryView.options.obs;

  final memberships = <MembershipDto>[].obs;
  final membershipsPageNumber = 1.obs;
  final membershipsPageSize = _defaultMembershipsPageSize.obs;
  final membershipsTotalItems = 0.obs;

  List<Map<String, dynamic>> get membershipsRows {
    final rows = memberships
        .map(
          (item) => {
            'id': item.membershipId,
            'name': item.membershipName,
            'price': _formatPrice(item.price),
            'maxBookings': _formatMaxBookings(item.maxBookingsPerMonth),
          },
        )
        .toList(growable: false);
    return sliceTablePage(
      rows,
      pageNumber: membershipsPageNumber.value,
      pageSize: membershipsPageSize.value,
      defaultPageSize: _defaultMembershipsPageSize,
    );
  }

  Future<void> loadMemberships({bool forceRefresh = false}) async {
    view.value = FitnessDirectoryView.memberships;
    if (!forceRefresh && memberships.isNotEmpty && error.value == null) {
      _syncMembershipsPagination();
      return;
    }

    isLoading.value = true;
    error.value = null;

    try {
      final response = await _repository.fetchMemberships();
      memberships.assignAll(response);
      membershipsPageNumber.value = 1;
      _syncMembershipsPagination();
    } on ApiException catch (apiError) {
      error.value = apiError.message;
      memberships.clear();
      _syncMembershipsPagination();
    } catch (err) {
      error.value = 'Unexpected error while loading membership plans: $err';
      memberships.clear();
      _syncMembershipsPagination();
    } finally {
      isLoading.value = false;
    }
  }

  void resetToInitialState() {
    isLoading.value = false;
    error.value = null;
    view.value = FitnessDirectoryView.options;
    memberships.clear();
    membershipsPageNumber.value = 1;
    membershipsPageSize.value = _defaultMembershipsPageSize;
    _syncMembershipsPagination();
  }

  void showDirectoryOptions() {
    view.value = FitnessDirectoryView.options;
    error.value = null;
  }

  void showDisciplines() {
    view.value = FitnessDirectoryView.disciplines;
    error.value = null;
  }

  void showDisciplineAvailabilityView() {
    view.value = FitnessDirectoryView.disciplineAvailability;
    error.value = null;
  }

  void showTrainers() {
    view.value = FitnessDirectoryView.trainers;
    error.value = null;
  }

  void showCapabilities() {
    view.value = FitnessDirectoryView.capabilities;
    error.value = null;
  }

  void setMembershipsPageNumber(int value) => setTablePageNumber(
    pageNumber: membershipsPageNumber,
    value: value,
    syncPagination: _syncMembershipsPagination,
  );

  void setMembershipsPageSize(int value) => setTablePageSize(
    pageNumber: membershipsPageNumber,
    pageSize: membershipsPageSize,
    value: value,
    syncPagination: _syncMembershipsPagination,
  );

  String _formatPrice(double? price) {
    if (price == null) {
      return '';
    }
    // Drop the decimals for whole amounts (e.g. 30 -> "$30"), keep cents
    // otherwise (e.g. 29.99 -> "$29.99").
    final isWhole = price == price.roundToDouble();
    final amount = isWhole
        ? price.toStringAsFixed(0)
        : price.toStringAsFixed(2);
    return 'Price: \$$amount';
  }

  String _formatMaxBookings(int? maxBookings) {
    if (maxBookings == null || maxBookings <= 0) {
      return '';
    }
    final unit = maxBookings == 1 ? 'session' : 'sessions';
    return 'Up to $maxBookings $unit / month';
  }

  void _syncMembershipsPagination() {
    syncTablePaginationState(
      totalItems: memberships.length,
      pageNumber: membershipsPageNumber,
      pageSize: membershipsPageSize,
      defaultPageSize: _defaultMembershipsPageSize,
      onTotalItemsResolved: (value) => membershipsTotalItems.value = value,
    );
  }
}

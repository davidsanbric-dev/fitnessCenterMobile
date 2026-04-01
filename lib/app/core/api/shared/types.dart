class PaginatedResult<T> {
  const PaginatedResult({
    required this.items,
    this.totalItems,
    this.pageNumber,
    this.pageSize,
  });

  final List<T> items;
  final int? totalItems;
  final int? pageNumber;
  final int? pageSize;
}

class PaginationMeta {
  const PaginationMeta({this.totalItems, this.pageNumber, this.pageSize});

  final int? totalItems;
  final int? pageNumber;
  final int? pageSize;
}

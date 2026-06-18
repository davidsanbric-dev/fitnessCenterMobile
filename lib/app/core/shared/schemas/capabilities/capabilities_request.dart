class CapabilitiesRequest {
  const CapabilitiesRequest({
    required this.queryType,
    required this.id,
    this.parentId,
  });

  final int queryType;
  final int id;
  final int? parentId;

  Map<String, String> toQueryParameters() => {
    'queryType': queryType.toString(),
    'id': id.toString(),
  };
}

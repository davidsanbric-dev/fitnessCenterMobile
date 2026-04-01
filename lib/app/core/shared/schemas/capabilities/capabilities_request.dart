class CapabilitiesRequest {
  const CapabilitiesRequest({
    this.locationId,
    required this.queryType,
    required this.id,
    this.parentId,
  });

  final int? locationId;
  final int queryType;
  final int id;
  final int? parentId;

  Map<String, String> toQueryParameters() => {
    if (locationId != null) 'locationCode': locationId.toString(),
    'queryType': queryType.toString(),
    'id': id.toString(),
  };
}

class TrainersRequest {
  const TrainersRequest({this.locationCode, this.disciplineCode});

  final int? locationCode;
  final int? disciplineCode;

  Map<String, String> toQueryParameters() => <String, String>{
    if (locationCode != null && locationCode! > 0)
      'locationCode': locationCode!.toString(),
    if (disciplineCode != null && disciplineCode! > 0)
      'disciplineCode': disciplineCode!.toString(),
  };
}

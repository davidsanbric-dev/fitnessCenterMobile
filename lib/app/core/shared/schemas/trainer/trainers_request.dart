class TrainersRequest {
  const TrainersRequest({this.disciplineCode});

  final int? disciplineCode;

  Map<String, String> toQueryParameters() => <String, String>{
    if (disciplineCode != null && disciplineCode! > 0)
      'disciplineCode': disciplineCode!.toString(),
  };
}

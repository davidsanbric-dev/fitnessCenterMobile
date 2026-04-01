DateTime startOfToday() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

String newTraceId() {
  return DateTime.now().microsecondsSinceEpoch.toString();
}

class MonthOption {
  const MonthOption(this.value, this.label);

  final String value;
  final String label;
}

const List<MonthOption> monthOptions = [
  MonthOption('1', 'Enero'),
  MonthOption('2', 'Febrero'),
  MonthOption('3', 'Marzo'),
  MonthOption('4', 'Abril'),
  MonthOption('5', 'Mayo'),
  MonthOption('6', 'Junio'),
  MonthOption('7', 'Julio'),
  MonthOption('8', 'Agosto'),
  MonthOption('9', 'Septiembre'),
  MonthOption('10', 'Octubre'),
  MonthOption('11', 'Noviembre'),
  MonthOption('12', 'Diciembre'),
];

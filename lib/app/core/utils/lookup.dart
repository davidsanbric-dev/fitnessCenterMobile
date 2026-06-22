import 'package:fitnesscenter_mobile/app/core/utils/normalize.dart';

Map<String, TValue> buildNormalizedLookupMap<TEntry, TValue>({
  required Iterable<TEntry> data,
  required String Function(TEntry) labelSelector,
  required TValue? Function(TEntry) valueSelector,
  bool Function(TValue value)? isValueValid,
}) {
  final lookup = <String, TValue>{};

  for (final item in data) {
    final normalizedLabel = normalizeKey(labelSelector(item));
    final value = valueSelector(item);

    if (normalizedLabel.isEmpty || value == null) {
      continue;
    }
    if (isValueValid != null && !isValueValid(value)) {
      continue;
    }

    lookup[normalizedLabel] = value;
  }

  return lookup;
}

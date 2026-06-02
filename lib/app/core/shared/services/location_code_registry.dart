/// Session-scoped lookup from the app's UI-facing location id to the real
/// `/statics` location code (e.g. `LOC001`).
///
/// Per the data-environment isolation model, `/statics` returns each company's
/// own locations and their codes must not be hardcoded. The registry is filled
/// from `/statics` whenever locations are loaded ([LocationsApi.getLocations]),
/// so request builders resolve the real code for the logged-in company instead
/// of assuming a fixed mapping.
class LocationCodeRegistry {
  LocationCodeRegistry._();

  /// Shared instance. API clients are constructed directly (not via DI), so a
  /// process-wide singleton keeps the resolved codes available to all of them.
  static final LocationCodeRegistry instance = LocationCodeRegistry._();

  final Map<String, String> _idToCode = <String, String>{};

  /// Replaces the registry with the id → code pairs from the current session's
  /// `/statics` locations.
  void replaceAll(Map<String, String> idToCode) {
    _idToCode
      ..clear()
      ..addAll(idToCode);
  }

  /// Clears the registry (e.g. on logout / company switch).
  void clear() => _idToCode.clear();

  /// Resolves a UI-facing location id to its `/statics` code. Values that are
  /// not known ids — a default/"all" sentinel, or an already-resolved code —
  /// pass through unchanged.
  String resolve(String idOrCode) {
    final key = idOrCode.trim();
    if (key.isEmpty) {
      return key;
    }
    return _idToCode[key] ?? key;
  }
}

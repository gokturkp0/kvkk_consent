import 'dart:convert';

import 'models.dart';

/// Where consent records live.
///
/// The package ships no storage dependency; plug in shared_preferences,
/// secure storage or a backend yourself. Implementations must persist the
/// whole list they are given and return it unchanged from [load].
abstract interface class ConsentStore {
  /// Returns all stored records, oldest first. Empty if nothing is stored.
  Future<List<ConsentRecord>> load();

  /// Replaces the stored records with [records]. Records are only ever
  /// appended by the controller, so [records] always contains every
  /// previously saved record.
  Future<void> save(List<ConsentRecord> records);
}

/// Keeps records in memory. Useful for tests and demos only: everything is
/// lost when the app restarts.
class InMemoryConsentStore implements ConsentStore {
  /// Creates a store, optionally pre-filled with [initial] records.
  InMemoryConsentStore([List<ConsentRecord>? initial])
    : _records = [...?initial];

  List<ConsentRecord> _records;

  @override
  Future<List<ConsentRecord>> load() async => List.of(_records);

  @override
  Future<void> save(List<ConsentRecord> records) async =>
      _records = List.of(records);
}

/// Stores all records as one JSON string through two callbacks, e.g.:
///
/// ```dart
/// final prefs = await SharedPreferences.getInstance();
/// final store = JsonStringConsentStore(
///   read: () async => prefs.getString('kvkk'),
///   write: (v) => prefs.setString('kvkk', v),
/// );
/// ```
class JsonStringConsentStore implements ConsentStore {
  /// Creates a store backed by [read] and [write].
  JsonStringConsentStore({required this.read, required this.write});

  /// Returns the stored JSON string, or null if nothing was stored yet.
  final Future<String?> Function() read;

  /// Persists the given JSON string, replacing any previously stored one.
  final Future<void> Function(String value) write;

  @override
  Future<List<ConsentRecord>> load() async {
    final raw = await read();
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => ConsentRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> save(List<ConsentRecord> records) =>
      write(jsonEncode(records.map((r) => r.toJson()).toList()));
}

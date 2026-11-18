import 'dart:convert';

import 'models.dart';

/// Where consent records live. The package ships no storage dependency;
/// plug in shared_preferences, secure storage or a backend yourself.
abstract interface class ConsentStore {
  Future<List<ConsentRecord>> load();
  Future<void> save(List<ConsentRecord> records);
}

/// Keeps records in memory. Useful for tests and demos only.
class InMemoryConsentStore implements ConsentStore {
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
  JsonStringConsentStore({required this.read, required this.write});

  final Future<String?> Function() read;
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

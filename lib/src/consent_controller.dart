import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'consent_store.dart';
import 'models.dart';

/// Holds consent state, derives it from an append-only record list and
/// persists every change through a [ConsentStore].
class KvkkConsentController extends ChangeNotifier {
  KvkkConsentController({
    required this.config,
    required this.store,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final KvkkConfig config;
  final ConsentStore store;
  final DateTime Function() _clock;

  final List<ConsentRecord> _records = [];
  bool _loaded = false;

  bool get isLoaded => _loaded;

  /// Full audit history, oldest first.
  List<ConsentRecord> get history => List.unmodifiable(_records);

  Future<void> load() async {
    _records
      ..clear()
      ..addAll(await store.load());
    _loaded = true;
    notifyListeners();
  }

  /// True until the current notice version has been acknowledged.
  bool get needsNotice => !_records.any(
    (r) =>
        r.type == ConsentRecordType.notice &&
        r.textVersion == config.noticeVersion,
  );

  /// True if any purpose has no decision for the current consent version.
  /// A "no" is a decision too; refusing does not cause re-prompting.
  bool get needsConsent => config.purposes.any((p) => _latestFor(p.id) == null);

  /// Whether the user currently grants [purposeId]. Defaults to false.
  bool isGranted(String purposeId) => _latestFor(purposeId)?.granted ?? false;

  Future<void> acknowledgeNotice() => _append([
    ConsentRecord(
      type: ConsentRecordType.notice,
      textVersion: config.noticeVersion,
      at: _clock(),
    ),
  ]);

  /// Records a decision for every configured purpose. Purposes missing
  /// from [choices] are recorded as refused (never silently granted).
  Future<void> saveConsents(Map<String, bool> choices) {
    _checkIds(choices.keys);
    final now = _clock();
    return _append([
      for (final p in config.purposes)
        ConsentRecord(
          type: ConsentRecordType.consent,
          textVersion: config.consentVersion,
          at: now,
          purposeId: p.id,
          granted: choices[p.id] ?? false,
        ),
    ]);
  }

  /// Changes a single purpose, e.g. from a settings screen.
  Future<void> setConsent(String purposeId, bool granted) {
    _checkIds([purposeId]);
    return _append([
      ConsentRecord(
        type: ConsentRecordType.consent,
        textVersion: config.consentVersion,
        at: _clock(),
        purposeId: purposeId,
        granted: granted,
      ),
    ]);
  }

  /// Pretty JSON of the full history, for "download my data" requests.
  String exportJson() =>
      const JsonEncoder.withIndent('  ')
          .convert(_records.map((r) => r.toJson()).toList());

  ConsentRecord? _latestFor(String purposeId) {
    for (final r in _records.reversed) {
      if (r.type == ConsentRecordType.consent &&
          r.purposeId == purposeId &&
          r.textVersion == config.consentVersion) {
        return r;
      }
    }
    return null;
  }

  void _checkIds(Iterable<String> ids) {
    final known = config.purposes.map((p) => p.id).toSet();
    for (final id in ids) {
      if (!known.contains(id)) {
        throw ArgumentError.value(id, 'purposeId', 'Unknown purpose');
      }
    }
  }

  Future<void> _append(List<ConsentRecord> records) async {
    if (!_loaded) {
      throw StateError('Call load() before changing consent.');
    }
    final next = [..._records, ...records];
    await store.save(next);
    _records
      ..clear()
      ..addAll(next);
    notifyListeners();
  }
}

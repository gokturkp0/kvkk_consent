import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'consent_store.dart';
import 'models.dart';

/// Holds consent state, derives it from an append-only record list and
/// persists every change through a [ConsentStore].
///
/// Call [load] once before reading state or making changes. Listeners are
/// notified after every successful change.
class KvkkConsentController extends ChangeNotifier {
  /// Creates a controller for [config] that persists to [store].
  ///
  /// [clock] defaults to [DateTime.now]; pass a fixed clock in tests.
  KvkkConsentController({
    required this.config,
    required this.store,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  /// Texts, versions and purposes of this app.
  final KvkkConfig config;

  /// Where records are loaded from and saved to.
  final ConsentStore store;

  final DateTime Function() _clock;

  final List<ConsentRecord> _records = [];
  bool _loaded = false;

  /// Whether [load] has completed.
  bool get isLoaded => _loaded;

  /// Full audit history, oldest first. Records are never edited or removed.
  List<ConsentRecord> get history => List.unmodifiable(_records);

  /// Loads all records from [store]. Must be called before any change.
  Future<void> load() async {
    _records
      ..clear()
      ..addAll(await store.load());
    _loaded = true;
    notifyListeners();
  }

  /// True until the current [KvkkConfig.noticeVersion] has been
  /// acknowledged.
  bool get needsNotice => !_records.any(
    (r) =>
        r.type == ConsentRecordType.notice &&
        r.textVersion == config.noticeVersion,
  );

  /// True if any purpose has no decision for the current
  /// [KvkkConfig.consentVersion].
  ///
  /// A refusal is a decision too, so a user who refused is not asked again
  /// until the consent version changes.
  bool get needsConsent => config.purposes.any((p) => _latestFor(p.id) == null);

  /// Whether the user currently grants [purposeId] under the current
  /// consent version. False when no decision exists (default is "no").
  bool isGranted(String purposeId) => _latestFor(purposeId)?.granted ?? false;

  /// Records that the user saw the current privacy notice.
  ///
  /// This grants no consent for any purpose: the notice (aydınlatma) and
  /// explicit consent (açık rıza) are always separate steps.
  Future<void> acknowledgeNotice() => _append([
    ConsentRecord(
      type: ConsentRecordType.notice,
      textVersion: config.noticeVersion,
      at: _clock(),
    ),
  ]);

  /// Records a decision for every configured purpose at once.
  ///
  /// Purposes missing from [choices] are recorded as `granted: false`;
  /// consent is never granted silently. Passing an empty map rejects all.
  /// Throws [ArgumentError] for an unknown purpose id.
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

  /// Records a decision for a single purpose, e.g. from a settings screen.
  ///
  /// Withdrawing consent (`granted: false`) appends a new record; earlier
  /// records stay in [history]. Throws [ArgumentError] for an unknown id.
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

  /// Pretty-printed JSON of the full [history], e.g. to answer a user's
  /// data access request or to send to your own backend.
  ///
  /// The package itself never sends data anywhere.
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

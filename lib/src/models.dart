import 'package:flutter/foundation.dart';

/// A single processing purpose that needs explicit consent (açık rıza),
/// e.g. personalised recommendations.
///
/// Each purpose is asked for separately; consent for one purpose never
/// implies consent for another. Only add processing that actually relies on
/// explicit consent; processing based on another legal ground belongs in the
/// notice only.
@immutable
class ConsentPurpose {
  /// Creates a purpose. [id] must be unique within a [KvkkConfig].
  const ConsentPurpose({
    required this.id,
    required this.title,
    required this.description,
  });

  /// Stable identifier. Never change it once shipped: stored records refer
  /// to purposes by this id.
  final String id;

  /// Short label shown on the consent switch.
  final String title;

  /// The explicit-consent text for this purpose: what is processed, why,
  /// and with whom it is shared. Bump [KvkkConfig.consentVersion] whenever
  /// it changes.
  final String description;
}

/// App-specific configuration for the notice and consent flow.
///
/// Bump [noticeVersion] or [consentVersion] whenever the matching text
/// changes; records made for an older version no longer count and the user
/// is asked again.
@immutable
class KvkkConfig {
  /// Creates a configuration. Purpose ids in [purposes] must be unique.
  KvkkConfig({
    required this.noticeText,
    required this.noticeVersion,
    required this.consentVersion,
    this.purposes = const [],
  }) : assert(
         purposes.map((p) => p.id).toSet().length == purposes.length,
         'ConsentPurpose ids must be unique',
       );

  /// Aydınlatma metni (privacy notice). Shown separately from consent; it
  /// informs only and never asks for approval, only acknowledgement.
  final String noticeText;

  /// Version label of [noticeText], e.g. a date like `2026-11-18`.
  final String noticeVersion;

  /// Version label of the explicit-consent texts (the purpose
  /// descriptions). Changing it asks every user again for every purpose.
  final String consentVersion;

  /// Purposes that rely on explicit consent. Do not list processing based on
  /// another legal ground (e.g. performing a contract): describe it in
  /// [noticeText] instead. May be empty, in which case only the notice is
  /// shown.
  final List<ConsentPurpose> purposes;
}

/// The kind of event a [ConsentRecord] describes.
enum ConsentRecordType {
  /// The user saw and acknowledged the privacy notice. This is not consent.
  notice,

  /// The user made a consent decision (grant or refuse) for one purpose.
  consent,
}

/// One append-only audit entry.
///
/// Records are never edited or deleted; withdrawing consent appends a new
/// record with `granted: false`. The current state is derived from the
/// latest matching record.
@immutable
class ConsentRecord {
  /// Creates a record. Usually created by `KvkkConsentController`, not by
  /// app code.
  const ConsentRecord({
    required this.type,
    required this.textVersion,
    required this.at,
    this.purposeId,
    this.granted = false,
  });

  /// Restores a record written by [toJson].
  factory ConsentRecord.fromJson(Map<String, dynamic> json) => ConsentRecord(
    type: ConsentRecordType.values.byName(json['type'] as String),
    textVersion: json['textVersion'] as String,
    at: DateTime.parse(json['at'] as String),
    purposeId: json['purposeId'] as String?,
    granted: json['granted'] as bool? ?? false,
  );

  /// Whether this records a notice acknowledgement or a consent decision.
  final ConsentRecordType type;

  /// The [KvkkConfig.noticeVersion] or [KvkkConfig.consentVersion] that was
  /// shown when the record was made.
  final String textVersion;

  /// When the record was made. Serialized in UTC.
  final DateTime at;

  /// The [ConsentPurpose.id] this decision is about. Null for
  /// [ConsentRecordType.notice].
  final String? purposeId;

  /// Whether consent was granted. Always false for
  /// [ConsentRecordType.notice], which never grants anything.
  final bool granted;

  /// Serializes the record. The keys are part of the stored data format and
  /// must stay stable.
  Map<String, dynamic> toJson() => {
    'type': type.name,
    'textVersion': textVersion,
    'at': at.toUtc().toIso8601String(),
    if (purposeId != null) 'purposeId': purposeId,
    if (type == ConsentRecordType.consent) 'granted': granted,
  };
}

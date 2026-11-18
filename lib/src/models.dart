import 'package:flutter/foundation.dart';

/// A single processing purpose that needs explicit consent (açık rıza),
/// e.g. marketing messages or analytics.
@immutable
class ConsentPurpose {
  const ConsentPurpose({
    required this.id,
    required this.title,
    required this.description,
  });

  /// Stable identifier. Never change it once shipped: stored records refer
  /// to purposes by this id.
  final String id;
  final String title;
  final String description;
}

/// App-specific configuration. Bump a version whenever the matching text
/// changes; users will be asked again.
@immutable
class KvkkConfig {
  KvkkConfig({
    required this.noticeText,
    required this.noticeVersion,
    required this.consentVersion,
    this.purposes = const [],
  }) : assert(
         purposes.map((p) => p.id).toSet().length == purposes.length,
         'ConsentPurpose ids must be unique',
       );

  /// Aydınlatma metni. Shown separately from consent and never asks for
  /// approval, only acknowledgement.
  final String noticeText;
  final String noticeVersion;

  /// Version of the explicit-consent texts (the purpose descriptions).
  final String consentVersion;
  final List<ConsentPurpose> purposes;
}

enum ConsentRecordType { notice, consent }

/// One append-only audit entry. Records are never edited or deleted;
/// the current state is derived from the latest entry.
@immutable
class ConsentRecord {
  const ConsentRecord({
    required this.type,
    required this.textVersion,
    required this.at,
    this.purposeId,
    this.granted = false,
  });

  factory ConsentRecord.fromJson(Map<String, dynamic> json) => ConsentRecord(
    type: ConsentRecordType.values.byName(json['type'] as String),
    textVersion: json['textVersion'] as String,
    at: DateTime.parse(json['at'] as String),
    purposeId: json['purposeId'] as String?,
    granted: json['granted'] as bool? ?? false,
  );

  final ConsentRecordType type;
  final String textVersion;
  final DateTime at;

  /// Null for [ConsentRecordType.notice].
  final String? purposeId;

  /// Meaningless for [ConsentRecordType.notice].
  final bool granted;

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'textVersion': textVersion,
    'at': at.toUtc().toIso8601String(),
    if (purposeId != null) 'purposeId': purposeId,
    if (type == ConsentRecordType.consent) 'granted': granted,
  };
}

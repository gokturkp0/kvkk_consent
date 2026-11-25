import 'package:flutter/foundation.dart';

/// UI labels for the notice and consent screens.
///
/// Use [KvkkStrings.tr] or [KvkkStrings.en], or create your own instance.
/// The notice and purpose texts themselves come from `KvkkConfig`.
@immutable
class KvkkStrings {
  /// Creates a custom set of labels.
  const KvkkStrings({
    required this.noticeTitle,
    required this.noticeContinue,
    required this.consentTitle,
    required this.consentIntro,
    required this.rejectAll,
    required this.saveChoices,
  });

  /// Turkish labels (default).
  static const tr = KvkkStrings(
    noticeTitle: 'Kişisel Verilerin Korunması Hakkında Aydınlatma',
    noticeContinue: 'Devam et',
    consentTitle: 'Açık Rıza Tercihleriniz',
    consentIntro:
        'Aşağıdaki işlemler isteğe bağlıdır. Onay vermeseniz de '
        'uygulamayı kullanabilirsiniz. Tercihlerinizi istediğiniz zaman '
        'ayarlardan değiştirebilirsiniz.',
    rejectAll: 'Tümünü reddet',
    saveChoices: 'Seçimlerimi kaydet',
  );

  /// English labels.
  static const en = KvkkStrings(
    noticeTitle: 'Privacy Notice',
    noticeContinue: 'Continue',
    consentTitle: 'Your Consent Choices',
    consentIntro:
        'The following are optional. You can use the app without '
        'agreeing, and change your choices any time in settings.',
    rejectAll: 'Reject all',
    saveChoices: 'Save my choices',
  );

  /// App bar title of the notice screen.
  final String noticeTitle;

  /// Button that acknowledges the notice. Must not imply acceptance or
  /// consent (avoid wording like "I accept").
  final String noticeContinue;

  /// App bar title of the consent screen.
  final String consentTitle;

  /// Intro above the switches. Should say that consent is optional and
  /// that the app can be used without it.
  final String consentIntro;

  /// Button that refuses every purpose.
  final String rejectAll;

  /// Button that saves the switch states as they are.
  final String saveChoices;
}

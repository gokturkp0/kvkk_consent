import 'package:flutter/foundation.dart';

/// UI labels. Use [KvkkStrings.tr] / [KvkkStrings.en] or pass your own.
@immutable
class KvkkStrings {
  const KvkkStrings({
    required this.noticeTitle,
    required this.noticeContinue,
    required this.consentTitle,
    required this.consentIntro,
    required this.rejectAll,
    required this.saveChoices,
  });

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

  final String noticeTitle;
  final String noticeContinue;
  final String consentTitle;
  final String consentIntro;
  final String rejectAll;
  final String saveChoices;
}

import 'package:flutter/widgets.dart';

/// UI labels for the notice and consent screens.
///
/// Use [KvkkStrings.tr] or [KvkkStrings.en], or create your own instance.
/// When a widget gets no `strings`, it calls [KvkkStrings.of], which picks
/// the language from the device. The notice and purpose texts themselves
/// come from `KvkkConfig`.
@immutable
class KvkkStrings {
  /// Creates a custom set of labels.
  const KvkkStrings({
    required this.noticeTitle,
    required this.noticeContinue,
    required this.consentTitle,
    required this.consentIntro,
    required this.viewNotice,
    required this.rejectAll,
    required this.saveChoices,
    required this.saveError,
  });

  /// Turkish labels.
  static const tr = KvkkStrings(
    noticeTitle: 'Aydınlatma Metni',
    noticeContinue: 'Devam et',
    consentTitle: 'Açık Rıza Tercihleriniz',
    consentIntro:
        'Aşağıdaki işlemler isteğe bağlıdır. Onay vermeseniz de '
        'uygulamayı kullanabilirsiniz. Tercihlerinizi istediğiniz zaman '
        'ayarlardan değiştirebilirsiniz.',
    viewNotice: 'Aydınlatma metnini oku',
    rejectAll: 'Tümünü reddet',
    saveChoices: 'Seçimlerimi kaydet',
    saveError: 'Tercihiniz kaydedilemedi. Lütfen tekrar deneyin.',
  );

  /// English labels.
  static const en = KvkkStrings(
    noticeTitle: 'Privacy Notice',
    noticeContinue: 'Continue',
    consentTitle: 'Your Consent Choices',
    consentIntro:
        'The following are optional. You can use the app without '
        'agreeing, and change your choices any time in settings.',
    viewNotice: 'Read the privacy notice',
    rejectAll: 'Reject all',
    saveChoices: 'Save my choices',
    saveError: 'Your choice could not be saved. Please try again.',
  );

  /// Labels for [locale]: Turkish for `tr`, English for everything else.
  static KvkkStrings forLocale(Locale locale) =>
      locale.languageCode == 'tr' ? tr : en;

  /// Labels for the device language, via [forLocale].
  ///
  /// Uses the device locale rather than the app's `Localizations`, because a
  /// `MaterialApp` without `supportedLocales` resolves every device to
  /// `en_US`. Apps with their own language setting should pass `strings`
  /// explicitly instead.
  static KvkkStrings of(BuildContext context) =>
      forLocale(View.of(context).platformDispatcher.locale);

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

  /// Link on the consent screen that opens the notice again, read-only.
  final String viewNotice;

  /// Button that refuses every purpose.
  final String rejectAll;

  /// Button that saves the switch states as they are.
  final String saveChoices;

  /// Shown in a snack bar when the `ConsentStore` fails to save.
  final String saveError;
}

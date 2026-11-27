# kvkk_consent

[![ci](https://github.com/gokturkp0/kvkk_consent/actions/workflows/ci.yml/badge.svg)](https://github.com/gokturkp0/kvkk_consent/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

[Türkçe](README.md) · **English**

<p>
  <img src="doc/screenshots/notice.png" alt="Privacy notice screen" width="260">
  &nbsp;
  <img src="doc/screenshots/consent.png" alt="Explicit consent screen" width="260">
</p>

A small, dependency-free **privacy notice + explicit consent** flow for Flutter
apps that process personal data under **KVKK**, Turkey's Personal Data
Protection Law (Law No. 6698).

- The privacy notice (*aydınlatma metni*) and explicit consent (*açık rıza*)
  are shown on **separate screens**.
- Every processing purpose has its own switch, and all switches start **off**.
- "Reject all" and "Save" have equal visual weight, and users who refuse can
  still use the app.
- Every decision is stored **append-only** with the text version and a
  timestamp; when a text version changes, the user is asked again.
- The full history can be exported as JSON.

UI labels ship in Turkish and English and follow the device language by
default.

> ⚠️ **Important:** This package is **infrastructure** for compliance; it is not
> legal advice and not a compliance guarantee. The explanations in this README,
> the FAQ answers, and the texts and consent purposes in the example app are
> **examples only**. Prepare your privacy notice, your consent purposes and the
> legal ground of each processing activity based on your own data processing,
> **in consultation with a lawyer or a qualified data protection
> professional**. Legal responsibility for using the package lies with the data
> controller.

## Why this package?

Under KVKK, informing users and obtaining explicit consent are two different
things: the user is informed first, while explicit consent is defined as
consent on a specific matter, based on information and given with free will
(Article 3 of the Law). That means consent has to be asked per purpose, and
refusing has to be possible. The Personal Data Protection Board's
[principle decision 2026/347](https://www.kvkk.gov.tr/Icerik/8710/veri-sorumlulari-tarafindan-acik-riza-ve-aydinlatma-metinlerinin-ayri-ayri-duzenlenmesi-gerektigi-hakkinda-kisisel-verileri-koruma-kurulunun-18-02-2026-tarihli-ve-2026-347-sayili-ilke-kararina-iliskin-kamuoyu-duyurusu)
(in Turkish) also states that the privacy notice and the explicit consent text
must be prepared separately. Many apps still squeeze this into a single "I
have read and accept" checkbox; this package gives you a ready-made flow that
keeps the two steps apart.

## Installation

```yaml
dependencies:
  kvkk_consent: ^0.1.0
```

or:

```bash
flutter pub add kvkk_consent
```

### Development version

```yaml
dependencies:
  kvkk_consent:
    git: https://github.com/gokturkp0/kvkk_consent.git
```

## Usage

```dart
final kvkk = KvkkConsentController(
  config: KvkkConfig(
    noticeText: privacyNoticeText,
    noticeVersion: '2026-11-18',
    consentVersion: '2026-11-18',
    purposes: const [
      ConsentPurpose(
        id: 'marketing',
        title: 'Commercial electronic messages',
        description: 'Sending campaigns by e-mail.',
      ),
    ],
  ),
  store: JsonStringConsentStore(
    read: () async => prefs.getString('kvkk'),
    write: (v) => prefs.setString('kvkk', v),
  ),
);
await kvkk.load();

runApp(MaterialApp(
  home: KvkkGate(
    controller: kvkk,
    strings: KvkkStrings.en,
    child: const HomePage(),
  ),
));

// Before sending a campaign e-mail:
if (kvkk.isGranted('marketing')) { /* ... */ }
```

To let users change their choices later, open `KvkkConsentPage` from your
settings screen. Its "Read the privacy notice" link lets users look at the
notice again while deciding.

**Language:** without `strings`, labels follow the device language: Turkish
on Turkish devices, English everywhere else. Pass `strings: KvkkStrings.tr`
(or `.en`) to pin a language or to follow your app's own language setting.

**While saving:** buttons are disabled, so a double tap never records twice.
If the `ConsentStore` fails, the user sees a short message, nothing is
recorded, and the error reaches your logs through `FlutterError.reportError`.

Working example: [`example/lib/main.dart`](example/lib/main.dart).

## FAQ

**Which processing should go into `purposes`?**
Only processing that relies on explicit consent. If processing is based on
another legal ground (for example performing a contract or a legal
obligation), describe it in the privacy notice but do not add it to the
consent screen; principle decision 2026/347 says no separate consent text
should be presented in that case. If none of your processing relies on
explicit consent, leave `purposes` empty and only the notice is shown.

**Is this enough for commercial electronic messages (marketing messages)?**
No. Sending commercial electronic messages needs a separate approval under Law
No. 6563, and these approvals are managed through the Message Management
System (İYS). This package is not integrated with İYS; it only keeps consent
records under KVKK.

**Can I rely on explicit consent to transfer data abroad?**
Since the amendment that took effect on 1 June 2024 (Law No. 7499), explicit
consent is a transfer route only for occasional (non-regular) transfers.
Regular transfers in the ordinary course of business (for example a
continuously running analytics or cloud service) need an adequacy decision
or appropriate safeguards. See the Authority's
[cross-border transfer page](https://www.kvkk.gov.tr/Icerik/2053/Yurtdisina-Aktarim)
(in Turkish).

**Can I use it for GDPR?**
The package is designed for KVKK. Its structure (separate notice, per-purpose
consent that defaults to off, an audit history) can be a starting point for
other regulations, but there is no GDPR-specific mode or ready-made text, and
assessing compliance is up to you.

**How do I send consent records to my server?**
The package never sends any data by itself. Either implement your own
`ConsentStore` and send the records in `save`, or send the output of
`kvkk.exportJson()` yourself.

**What happens when I change the privacy notice?**
Bump `noticeVersion` (or `consentVersion` for the consent texts). Records made
for the old version no longer count and the user is asked again; the old
records stay in the history.

## Used by

Nobody yet.

If you use this package, add your app to this list with a PR.

## Development

```bash
./tool/check.sh   # format + analyze + test
```

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for the contribution process (in
Turkish, with an English summary at the top). AI coding agents read
[`AGENTS.md`](AGENTS.md) first; it lists the package's invariants and a file
map.

## License

Released under the [MIT License](LICENSE). You can use it freely in your own
projects, including commercial and closed-source apps; the only condition is
keeping the license text with its copyright notice.

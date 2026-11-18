# kvkk_consent

[![ci](https://github.com/gokturkp0/kvkk_consent/actions/workflows/ci.yml/badge.svg)](https://github.com/gokturkp0/kvkk_consent/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Flutter uygulamaları için küçük, bağımlılıksız bir **KVKK aydınlatma + açık
rıza** akışı.

- Aydınlatma metni ile açık rıza **ayrı ekranlarda** gösterilir.
- Her işleme amacı için ayrı anahtar vardır; hepsi **kapalı** başlar.
- "Tümünü reddet" ile "Kaydet" eşit ağırlıktadır; reddeden kullanıcı da
  uygulamayı kullanır.
- Her karar metin sürümü ve zamanıyla **eklemeli** olarak kaydedilir; metin
  sürümü değişince kullanıcıya yeniden sorulur.
- Geçmiş JSON olarak dışa aktarılabilir.

> ⚠️ Bu paket uyum için bir **altyapıdır**, hukuki tavsiye ya da uyum garantisi
> değildir. Aydınlatma metninizi ve rıza amaçlarınızı kendi veri işleme
> faaliyetlerinize göre hazırlayın.

## Kurulum

```yaml
dependencies:
  kvkk_consent:
    git: https://github.com/gokturkp0/kvkk_consent.git
```

## Kullanım

```dart
final kvkk = KvkkConsentController(
  config: KvkkConfig(
    noticeText: aydinlatmaMetni,
    noticeVersion: '2026-11-18',
    consentVersion: '2026-11-18',
    purposes: const [
      ConsentPurpose(
        id: 'marketing',
        title: 'Ticari elektronik ileti',
        description: 'Kampanyaların e-posta ile gönderilmesi.',
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
  home: KvkkGate(controller: kvkk, child: const HomePage()),
));

// Bir analitik SDK'sını başlatmadan önce:
if (kvkk.isGranted('analytics')) { /* ... */ }
```

Tercihleri sonradan değiştirmek için ayarlardan `KvkkConsentPage` açın.
İngilizce arayüz için `strings: KvkkStrings.en` verin.

Çalışan örnek: [`example/lib/main.dart`](example/lib/main.dart).

## Geliştirme

```bash
./tool/check.sh   # format + analyze + test
```

Bu depoda yapay zekâ kodlama ajanlarıyla çalışıyorsanız ajanlar önce
[`AGENTS.md`](AGENTS.md) dosyasını okur. Bu dosya paketin değişmez kurallarını
ve dosya haritasını içerir.

## Lisans

[MIT Lisansı](LICENSE) ile dağıtılır. Kendi projelerinizde, ticari ve kapalı
kaynak uygulamalar dahil, özgürce kullanabilirsiniz; tek koşul lisans
metnini (telif bildirimiyle birlikte) korumaktır.

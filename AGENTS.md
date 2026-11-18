# AGENTS.md — AI ajanları için çalışma kılavuzu

Bu dosya Claude, Codex, Copilot vb. kodlama ajanları içindir. Bu depoda
değişiklik yapmadan önce baştan sona oku.

## Paket ne yapar (tek cümle)
Flutter uygulamalarında KVKK **aydınlatma** ve **açık rıza** adımlarını
ayrı ayrı gösterir ve her kararı sürümlü, eklemeli (append-only) bir kayıt
olarak saklar.

## Kapsam: bilerek küçük
Kapsam içi: aydınlatma ekranı, amaç bazlı açık rıza ekranı, kayıt geçmişi,
sürüm değişince yeniden sorma, JSON dışa aktarma.
Kapsam dışı (eklemeden önce kullanıcıya sor): çerez banner'ı, sunucu/
backend senkronu, hukuki metin üretimi, analitik SDK entegrasyonları,
yeni bağımlılıklar.

## Dosya haritası
| Dosya | Sorumluluk |
|---|---|
| `lib/kvkk_consent.dart` | Tek public giriş noktası (yalnızca export). |
| `lib/src/models.dart` | `ConsentPurpose`, `KvkkConfig`, `ConsentRecord` (+ JSON). |
| `lib/src/consent_store.dart` | `ConsentStore` arayüzü, `InMemoryConsentStore`, `JsonStringConsentStore`. |
| `lib/src/consent_controller.dart` | Tüm iş kuralları. Durum kayıtlardan türetilir. |
| `lib/src/strings.dart` | `KvkkStrings.tr` / `.en` arayüz metinleri. |
| `lib/src/widgets/` | `KvkkNoticePage`, `KvkkConsentPage`, `KvkkGate`. Mantık içermez, controller'ı çağırır. |
| `test/` | Kurallar `consent_controller_test.dart`, ekran akışı `widgets_test.dart`. |
| `example/lib/main.dart` | Çalışan en küçük örnek. |

## Bozulmaması gereken kurallar (değişmezler)
Bunlardan biri değişecekse önce kullanıcıya sor; her biri bir testle korunur.

1. **Aydınlatma ≠ rıza.** Aydınlatma ekranında onay kutusu, "kabul ediyorum"
   ifadesi ya da rıza kaydı olmaz. `acknowledgeNotice()` hiçbir amacı
   onaylamaz.
2. **Varsayılan her zaman "hayır".** Anahtarlar kapalı başlar; `saveConsents`
   içinde verilmeyen amaç `granted: false` kaydedilir.
3. **Reddetmek onaylamak kadar kolay.** "Tümünü reddet" ve "Kaydet" aynı
   görsel ağırlıkta, aynı ekranda. Reddeden kullanıcıya tekrar sorulmaz.
4. **Hizmet rızaya bağlanmaz.** `KvkkGate`, reddeden kullanıcıyı da
   uygulamaya geçirir.
5. **Kayıtlar yalnızca eklenir.** Hiçbir kayıt düzenlenmez ya da silinmez;
   geri çekme yeni bir `granted: false` kaydıdır.
6. **Sürüm değişince yeniden sor.** `noticeVersion` / `consentVersion`
   değişirse eski kayıtlar geçerli sayılmaz.
7. **`ConsentPurpose.id` ve `ConsentRecord.toJson` anahtarları kalıcıdır.**
   Değiştirmek, kullanıcıların kayıtlı verisini bozar (breaking change).
8. **Sıfır üçüncü taraf bağımlılık** (yalnızca Flutter SDK).

## Sık yapılan değişiklikler: nasıl
- **Yeni dil:** `strings.dart` içine `static const xx = KvkkStrings(...)` ekle.
  Yeni alan eklersen `tr` ve `en` dahil hepsini doldur.
- **Yeni metin alanı:** `KvkkStrings`'e `required` alan ekle, tüm sabitleri
  güncelle, widget'ta kullan.
- **Yeni depolama:** paket içine bağımlılık ekleme; README'de
  `JsonStringConsentStore` ile örnek göster ya da `ConsentStore`'u uygulayan
  ayrı bir paket öner.
- **Yeni davranış:** kuralı `KvkkConsentController`'a koy, widget'a değil.
  Önce testini yaz.

## Kontrol komutu (her değişiklikten sonra zorunlu)
```bash
./tool/check.sh
```
Biçim, analiz ve testleri çalıştırır. Hepsi geçmeden işi bitmiş sayma.

## Sürümleme
- Public API değişirse `CHANGELOG.md`'ye yaz ve `pubspec.yaml` sürümünü artır
  (semver; 1.0 öncesi kırıcı değişiklik = minor artışı).
- `pub publish` komutunu **çalıştırma**; yayın kararı kullanıcınındır.

## Dil
Kod, API adları ve kod yorumları İngilizce. Arayüz metinleri TR + EN.
Bu dosya ve README Türkçe.

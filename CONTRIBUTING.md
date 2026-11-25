# Katkı rehberi

Katkın için teşekkürler! Bu paket bilerek küçük tutuluyor; büyük bir
değişikliğe başlamadan önce bir issue açıp fikrini paylaşırsan zaman kaybını
önlemiş oluruz.

## Geliştirme ortamı

- Flutter (stable). CI'da kullanılan sürüm `.github/workflows/ci.yml`
  dosyasında yazılıdır; biçimlendirme farkı yaşamamak için aynı sürümü
  kullanman önerilir.
- Paketin üçüncü taraf bağımlılığı yoktur ve olmamalıdır.

```bash
git clone https://github.com/gokturkp0/kvkk_consent.git
cd kvkk_consent
flutter pub get
./tool/check.sh
```

## Kontrol komutu

Her değişiklikten sonra çalıştır:

```bash
./tool/check.sh
```

Biçim (`dart format`), analiz (`flutter analyze`) ve testleri (`flutter test`)
çalıştırır. CI aynı komutu kullanır; bu komut geçmeden PR birleştirilmez.

Ekran görüntülerini (`doc/screenshots/`) değiştiren bir arayüz değişikliği
yaptıysan görüntüleri yeniden üret:

```bash
./tool/screenshots.sh
```

## Değişmez kurallar

Paketin bozulmaması gereken kuralları (aydınlatma ile rızanın ayrı olması,
varsayılanın "hayır" olması, kayıtların yalnızca eklenmesi vb.) ve kapsam
dışı konular [`AGENTS.md`](AGENTS.md) dosyasında yazılıdır. Bu kurallardan
birini değiştirmesi gereken bir öneri varsa önce issue aç.

## PR beklentileri

- Bir PR tek bir konuyu ele alsın.
- Yeni davranış için test ekle; iş kuralları `KvkkConsentController` içinde
  olsun, widget'larda değil.
- Public API'ye eklenen her üyeye `///` belge yorumu yaz
  (`public_member_api_docs` kuralı bunu denetler).
- Kullanıcıyı etkileyen her değişikliği `CHANGELOG.md`'ye ekle.
- Kod, API adları, kod yorumları ve commit mesajları İngilizce; README ve
  CHANGELOG Türkçe.
- Hukuki bir ifade ekliyorsan kaynağını belirt. Paket hukuki tavsiye vermez.

## 0.1.0

- İlk sürüm: aydınlatma ekranı, amaç bazlı açık rıza ekranı, `KvkkGate`,
  eklemeli kayıt geçmişi, sürüm değişince yeniden sorma, JSON dışa aktarma.
- Tüm public API için dartdoc belgeleri; `public_member_api_docs` lint kuralı.
- Aydınlatma metni artık sola hizalı ve ekranın tamamını kaplıyor (önceden
  ortalanıyordu).
- Türkçe aydınlatma ekranı başlığı kısaltıldı: "Aydınlatma Metni" (uzun başlık
  telefonda kesiliyordu).
- README: ekran görüntüleri, "Neden bu paket?", pub.dev kurulumu, SSS ve
  "Kullananlar" bölümleri.
- Katkı rehberi (`CONTRIBUTING.md`), issue ve PR şablonları.
- pub.dev için ekran görüntüleri ve `issue_tracker` alanı.
- Kayıt sırasında düğmeler devre dışı kalır; çift dokunma artık çift kayıt
  oluşturmaz. `ConsentStore` hatası kullanıcıya `saveError` ile gösterilir ve
  `FlutterError.reportError` ile raporlanır.
- Rıza ekranına salt okunur "Aydınlatma metnini oku" bağlantısı.
- `strings` verilmezse arayüz dili cihaz diline göre seçilir
  (`KvkkStrings.of`, `KvkkStrings.forLocale`). `KvkkStrings`'e `viewNotice` ve
  `saveError` alanları eklendi; kendi `KvkkStrings` örneğini oluşturanlar bu
  iki alanı da doldurmalı.
- Örnek uygulama: dil seçimi, ayarlardan tercih değiştirme, rıza durumu ve
  kayıt geçmişi ekranı.
- Hukuki içerik düzeltmeleri: örnek uygulamadaki "yurt dışına aktarım"
  amacı kaldırıldı (7499 sayılı Kanun sonrası açık rıza yalnızca arızi
  aktarımlar için), yerine "Kişiselleştirilmiş öneriler" kondu; örnek
  aydınlatma metnine "toplama yöntemi" başlığı eklendi; README'ye 2026/347
  sayılı ilke kararı, `purposes` kapsamı, İYS ve yurt dışı aktarım SSS'leri
  eklendi.
- README (TR/EN) ve örnek metindeki uyarı netleştirildi: içerik yalnızca
  örnektir; metinler bir avukata ya da yetkili bir uzmana danışılarak
  hazırlanmalıdır.
- İngilizce belgeler: `README.en.md`, README ve `CONTRIBUTING.md` başında
  İngilizce özet, iki dilli issue şablonları.

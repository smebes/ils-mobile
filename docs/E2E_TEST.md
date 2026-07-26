# SprachApp — Uçtan Uca Test Senaryoları

**Hedef platform:** iOS / Android telefon (asıl ürün). Web sadece hızlı smoke için.  
**Build:** `mobile/` → `flutter run` (cihaz veya simülatör).  
**Temiz başlangıç:** uygulama verisini sil / yeniden yükle (SharedPreferences sıfırlansın).

> **2026-07-26 (yeniden test turu):** Dilim oturumu sıkılaştırıldı (max ~6 yeni + 5 tekrar kartı + max 4 egzersiz); ileri Schritt SR sızıntısı kesildi; Tekrar caught-up sinyali güçlendirildi; fill chip highlight; session AnimatedSwitcher pointer fix; web audio guard genişletildi.  
> **Kritik:** `localhost:5281` eski build kalabiliyor — her turda **hard restart** (`flutter run` yeniden) şart. Tarayıcıda hard refresh (Cmd+Shift+R).  
> **Tester doğrulama (2026-07-26 akşam):** 6 kritik madde (sheet, dilim uzunluğu, caught-up, profil, donma, Welche/Frankreich/chip) yeni build’de geçti. Büyük dilimlerde “~N ders kaldı” ipucu eklendi.  
> **S1 not:** Result `XpFlightBurst` → `Positioned(right)` içinde `width: infinity` layout crash + mouse_tracker (Keep learning tepkisiz) — düzeltildi (`left`+`right` bound).  
> **Sprint A kapanış (2026-07-26 gece):** Result Keep learning widget test ile doğrulandı (`result_screen_test.dart`). S2 mechanic smoke (`mechanic_smoke_test.dart`). S4 soft placeholder — cream + nötr çerçeve, `Icons.broken_image*` yok (`SoftMediaPlaceholder` / `media_image_test.dart`).  
> **Tester (opsiyonel):** kısa ders → Result → Öğrenmeye devam; bir flashcard’da eksik görselde kırık ikon flaşı olmamalı.

## Sistem hazırlığı (özet)

| Alan | Durum |
|------|--------|
| Onboarding (4 adım) | Hazır |
| Home + öğrenme haritası (Öğren / Tekrar / Profil) | Hazır |
| Dilim-sınırlı ders oturumu | Hazır |
| Flashcard / Quiz / Fill / Listening / Matching | Hazır |
| Result + seri | Hazır |
| Tekrar sekmesi + review oturumu | Hazır |
| Profil (hedef, dil, hatırlatma soft-ask, isim) | Hazır |
| UI i18n (TR / EN / FR) | Hazır |
| Bayrak SVG’leri (DE/AT/PL/IT/ES/FR/CH/SY) | Düzeltildi — doğrula |
| Seviye testi | **Yok** (“yakında”) |
| Gerçek push bildirimi | **Yok** (sadece tercih kaydı) |
| App icon / native splash | **Yok** (yer tutucu) |

**Sonuç:** A1 L1 öğrenme döngüsü test edilebilir. Store’a çıkmadan önce aşağıdaki senaryolar + bilinen boşluklar kapanmalı.

---

## Ortam kurulumu

1. Temiz kurulum (ilk açılış = onboarding).
2. İkinci tur için: aynı cihaz, veri silmeden devam.
3. (Opsiyonel) Profil → uygulama dili TR / EN / FR değiştirerek chrome’u doğrula.
4. Ses: kulaklık veya normal ses açık; sessiz moda alma.

**Genel geç / kal:** Her adımda “Beklenen” ile ekran uyuşmuyorsa **FAIL** + ekran görüntüsü + cihaz/OS.

---

## T0 — Smoke (5 dk)

| # | Adım | Beklenen |
|---|------|----------|
| T0.1 | Uygulamayı aç | Çökme yok; onboarding veya Home gelir |
| T0.2 | Alt nav: Öğren / Tekrar / Profil | 3 tab, seçili teal |
| T0.3 | Öğren → dersi başlat → X ile çık | Home’a döner; kilitlenmez |

---

## T1 — Onboarding (temiz kurulum)

| # | Adım | Beklenen |
|---|------|----------|
| T1.1 | İsim gir (ör. Ayşe) → Devam | Önizleme: “Günaydın, Ayşe!” (veya günün saatine göre selam) |
| T1.2 | İsmi boş bırakıp Devam | Sonra Home’da “Merhaba!” / Öğrenci fallback |
| T1.3 | Seviye: “Sıfırdan başlıyorum” | Devam aktif |
| T1.4 | “Biraz Almanca biliyorum” | “Seviye testi yakında” (snack/uyarı); test ekranı **açılmaz** |
| T1.5 | Günlük hedef seç (5/10/15) | Seçim vurgulu; Devam |
| T1.6 | Artikel ekranı (der/die/das renkleri) | Renkler: mavi / kırmızı / yeşil |
| T1.7 | Başlayalım | Home açılır; tekrar onboarding gelmez |

---

## T2 — Öğrenme haritası (Öğren)

| # | Adım | Beklenen |
|---|------|----------|
| T2.1 | Selamlama + streak | İsimli/genel selam; streak rozeti |
| T2.2 | Üst CTA | “Bugünkü derse devam” (veya dil karşılığı) |
| T2.3 | Sabit özet şerit | 7 bölüm × 5 sütun (35 hücre); aktif dilim daha yüksek |
| T2.4 | Yılan yol L1 | 5 dilim node + bölüm sonu yıldız; aktif node büyük + halkalı |
| T2.5 | L2–L7 bantları | Soluk ama görünür; kilit ikonu |
| T2.6 | Aktif node / CTA | Session açılır |
| T2.7 | Kilitli Lektion 2+ | Bottom sheet: kilit açıklaması + ilerleme |

---

## T3 — Session (dilim dersi) — kritik

| # | Adım | Beklenen |
|---|------|----------|
| T3.1 | Üst chrome | X, progress bar, adım sayacı (`n/m`) |
| T3.2 | Dilim chip | `Dilim 1/5 · …` (TR’de Tanışma vb.) |
| T3.3 | Süre | ~7–12 adım civarı (tüm L1’i tek seferde yutmamalı) |
| T3.4 | Flashcard | SVG/görsel, kelime, Dinle, “Çeviriyi göster”, Devam |
| T3.5 | Dinle | Ses çalar; UI donmaz |
| T3.6 | Quiz | Seçenek + radio nokta; Kontrol et → Richtig/Fast + Devam |
| T3.7 | Fill blank | Chip seçimi; doğru/yanlış state |
| T3.8 | Listening | Langsam / Normal; sorular; tümü cevaplanmadan Kontrol kapalı/uyarı |
| T3.9 | Matching | Sol–sağ eşleme; yanlışta geri alınabilir |
| T3.10 | Ortada X | Çıkış; Home’a dönüş; donma yok |
| T3.11 | Sona kadar bitir | Result: Harika / istatistik / seri badge / Öğrenmeye devam |
| T3.12 | Result sonrası Home | Günlük hedef “tamamlandı” veya ilerleme artmış |
| T3.13 | Aynı gün 2. ders | Yeni dilime zorlamamalı veya kısa ek pratik; uzun L1 dump yok |

---

## T4 — Bayrak / ülke görselleri (Dilim 3’e gelince veya ilgili kartlarda)

> Dilim 1’de bayrak çıkmayabilir. Dilim 3 (ülke/dil) veya eşleme/quiz’de ülke görsellerini yakala.

| # | Kelime / ülke | Beklenen |
|---|----------------|----------|
| T4.1 | Deutschland | Siyah–kırmızı–sarı şeritler **dolu** (boş çerçeve değil) |
| T4.2 | Österreich | Kırmızı–beyaz–kırmızı |
| T4.3 | Polen | Beyaz–kırmızı |
| T4.4 | Italien | Yeşil–beyaz–kırmızı (dikey) |
| T4.5 | Spanien | Kırmızı–sarı–kırmızı |
| T4.6 | Frankreich | Mavi–beyaz–kırmızı (dikey) |
| T4.7 | Schweiz | Kırmızı zemin + beyaz haç |
| T4.8 | Syrien | Kırmızı–beyaz–siyah |
| T4.9 | Hata durumu | Kırık ikon yerine krem + nötr çerçeve placeholder (`SoftMediaPlaceholder`; çökme yok) |

---

## T5 — Tekrar sekmesi

| # | Adım | Beklenen |
|---|------|----------|
| T5.1 | Hiç ders bitirmeden Tekrar | “Henüz tekrar yok” + empty illüstrasyon + “Bugünkü derse başla” |
| T5.2 | En az 1 ders bitir; ertesi gün veya due oluşunca | “Bugün tekrar etmen gereken N kelime” + Tekrara başla |
| T5.3 | Hatalarım / Zayıf / Yaklaşan | Liste veya 0; çökme yok |
| T5.4 | Tekrara başla | Chip “Tekrar”; flashcard ağırlıklı; Result’ta günlük hedef zorunlu artmayabilir |
| T5.5 | Sadece hatalarımı çalış | Oturum açılır / ilgili akış |

---

## T6 — Profil

| # | Adım | Beklenen |
|---|------|----------|
| T6.1 | İsim / avatar’a dokun | İsim düzenle sheet → Kaydet → Home selamı güncellenir |
| T6.2 | Bu hafta | 7 gün; tamamlanan gün ✓ |
| T6.3 | Günlük hedef süresi | Değişir, kaydolur |
| T6.4 | Hatırlatma saati seç | Soft-ask: “Günde bir kez…” → Hatırlat → saat kaydolur |
| T6.5 | Soft-ask “Şimdi değil” | Saat **kaydolmaz** / kapalı kalır |
| T6.6 | Hatırlatma Kapalı | Değer temizlenir |
| T6.7 | Uygulama dili EN | Menüler EN; ders içeriği Almanca kalır |
| T6.8 | Dil FR | Aynı kural |
| T6.9 | Uygulamayı öldürüp aç | Dil, isim, streak, hedef persist |

---

## T7 — Ses & donmama (regresyon)

| # | Adım | Beklenen |
|---|------|----------|
| T7.1 | Flashcard Dinle ×3 | Her seferinde ses; UI kilitlenmez |
| T7.2 | Listening Langsam → hemen X | Çıkış temiz; sonra yeni ders açılır |
| T7.3 | Listening bitmeden Devam yok | Uyarı veya buton pasif |
| T7.4 | Hızlı: cevap → Devam → cevap | Gecikme makul; donma yok |

---

## T8 — i18n chrome

| # | Adım | Beklenen |
|---|------|----------|
| T8.1 | UI = TR | Tab/CTA Türkçe |
| T8.2 | UI = EN | Tab/CTA İngilizce |
| T8.3 | Flashcard kelime / örnek | Almanca |
| T8.4 | Feedback | “Richtig!” + lokal “Doğru” |

---

## T9 — Negatif / kenar

| # | Adım | Beklenen |
|---|------|----------|
| T9.1 | Uçak modu | İçerik offline açılır (asset’ler) |
| T9.2 | Çok hızlı tab değiştirme | Çökme yok |
| T9.3 | Session ortasında telefon çağrısı simülasyonu (mümkünse) | Dönüşte stabil |

---

## Bilinçli FAIL etmeyin (bilinen eksik)

- Seviye testi akışı yok → “yakında” **PASS** sayılır.
- Gerçek bildirim gelmez → soft-ask + kayıt yeterli.
- App icon / splash store kalitesi değil.
- Hallo/Tschüss ikon keşif 2a henüz uygulanmadı (görsel tercih).

---

## Tester rapor şablonu

```
Cihaz / OS:
Build / commit:
Tarih:

Senaryo ID | Sonuç (PASS/FAIL) | Not / ekran görüntüsü
T0.1 | | 
T3.5 | | 
T4.1 | | 
...

Bloker (varsa):
```

## Öncelik sırası (kısa süre varsa)

1. T0 → T1 → T3 → T7 (öğrenme döngüsü + ses)  
2. T4 (bayraklar)  
3. T5 → T6  
4. T8 → T9  

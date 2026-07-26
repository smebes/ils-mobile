# SprachApp — Geliştirme Yol Haritası

> **Konum (2026-07):** İyi bir MVP’nin ötesi — çekirdek öğrenme döngüsü çalışıyor (artikel renkleri, SRS, kısa dilim oturumları, harita, Result). Duolingo seviyesinde değil; hedef **güvenilir günlük pratik** + **bilinçli pedagojik fark**.  
> **İlk risk:** içerik hacmi değil, tekrarlayan etkileşim donmaları.

---

## Nasıl ilerleriz (çalışma modeli)

1. **Tek odak sprint’leri** — aynı anda “stabilite + L2 içerik + maskot” değil. Her sprint 1 ana hedef.
2. **Doğrulama kapısı** — sprint bitince `docs/E2E_TEST.md` ilgili senaryolar + dar ekran (360–414px) smoke.
3. **Ürün kararı önce** — can/kalp, lig, mağaza gibi Duolingo kopyaları bilinçli *evet/hayır*; varsayılan: **cezasız pedagoji** (can yok).
4. **Tasarım / içerik / kod ayrımı** — designer SVG & brief; içerik JSON (L2+); kod etkileşim + native.

---

## Kısa vade — Stabilizasyon (öncelik #1)

**Amaç:** “Bir kez donarsa geri dönmez” riskini kapatmak.

| # | İş | Çıktı |
|---|-----|--------|
| S1 | Etkileşim donması kök neden | ✅ Ortak ses-DOM ayrımı; fill / listen AnimatedSwitcher; Result XP layout |
| S2 | Otomatik regresyon (widget/integration) | ✅ `mechanic_smoke_test.dart` — quiz / fill / listen / match / flashcard Check→Continue |
| S3 | Responsive tarama | 360 / 390 / 414px: Home harita, Session, Result, Profil — overflow yok |
| S4 | Kozmetik pürüzler | ✅ SoftMediaPlaceholder (kırık ikon yok); “son ders” `seen > 0`; UI dil çevirisi mevcut |

**Kapı:** 2 tam L1 dilim oturumu + 5× fill-blank + 5× listening ardışık, sıfır donma.

---

## Orta vade — Alışkanlık + derinlik

**Amaç:** Günlük geri dönüş ve “gerçekten öğretir mi” cevabı.

| # | İş | Not |
|---|-----|-----|
| M1 | Gerçek push (FCM/APNs) | Soft-ask UI hazır; tercih → gerçek bildirim |
| M2 | Placement test | Onboarding “yakında” → 4 soru + dilim atlama kuralı |
| M3 | İçerik: L1 tamam + L2 açılış | ✅ Meine Familie — 3 dilim, 25 vocab, 12 egzersiz; kilit %80 mastery |
| M4 | Streak dondurma / nazik kaçırma akışı | Can sistemi *yok* (bilinçli); streak koruma sade |
| M5 | Result cesur animasyonlar (seçmeli) | XP jeton + takvim flip yapıldı; kart destesi orta öncelik |

**Kapı:** Temiz kullanıcı 7 gün streak tutabiliyor; L1→L2 geçişi mümkün.

---

## Uzun vade — Marka + (isteğe bağlı) sosyal

**Konumlanma (önerilen):** Duolingo kopyası değil — **artikel-öncelikli, sakin, cezasız** Almanca A1. Lig/kalp/mağaza varsayılan **hayır**.

| # | İş | Not |
|---|-----|-----|
| L1 | Maskot / illüstrasyon dili | Jenerik balon-figür → tutarlı karakter veya zengin vocab seti |
| L2 | App icon + splash + store paket | Native performans / a11y denetimi |
| L3 | Konuşma pratiği | “Yakında” → kayıt/TTS geri bildirim (kapsam ayrı brief) |
| L4 | Sosyal (opsiyonel faz) | Lig/arkadaş — marka kararı “evet” ise ayrı epik |

---

## Bilinçli *yapmayacaklarımız* (şimdilik)

- Can/kalp ile dersi kesmek (anksiyete + monetizasyon modeli)
- Gem / mağaza ekonomisi
- Lig / liderlik (L4 kararı olmadan)

---

## Şimdi sıradaki sprint (öneri)

**Sprint A — Stabilite:** S1 + S2 + S4 ✅  
**M3 — L2 içerik:** ✅ Meine Familie (3 dilim) + unlock + oturum.  
Sonra **Sprint B — S3 responsive** (360/390/414).  
Sonra orta vade M1 (push) veya L3 doldurma.

Tester ile: her sprint sonrası kısa E2E; donma görülürse yeni özellik dondurulur.

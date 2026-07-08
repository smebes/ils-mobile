# SprachApp — Ürün & Deneyim Tasarımı

**Ne:** A1 Almanca öğrenme uygulaması (Schritte Plus Neu 1 temelli)
**Kim için:** Almanya'da yaşayan/çalışacak göçmenler, gastronomi çalışanları — sınavı geçmesi *ve* konuşması gereken yetişkinler
**Platform:** Mobil-öncelikli, ticari
**Tez:** Anki'nin kalıcılığı + Duolingo'nun motivasyonu — ama ikisinin de hatasını yapmadan

İlgili teknik dokümanlar: `Project.md` (mimari), `sprachapp_pipeline_detayli.md` (içerik pipeline), `content/l3/` (pilot içerik).

---

## 1. ÜRÜN TEZİ (her kararın dayanağı)

Piyasada iki uç var, ikisi de kusurlu:

| | Duolingo | Anki | **SprachApp hedefi** |
|---|---|---|---|
| Güçlü yanı | Bağımlılık yapan motivasyon | Bilimsel kalıcılık | İkisi birden |
| Zayıf yanı | Yıllarca kullan, konuşamazsın | Sıkıcı, çoğu bırakır | — |
| SR (tekrar) | Zayıf/gizli | Merkezde ama çıplak | **Görünmez ama güçlü** |
| Konuşma | Neredeyse yok | Yok | **AI partner merkezi** |

**Tek cümlelik ürün kararı:**
> Kalıcılık motoru (spaced repetition) *görünmez* çalışır; oyunlaştırma (streak, seviye) *görünür* motive eder; gerçek yeterlilik *AI konuşma* ile kanıtlanır.

Bu üç katman ürünün belkemiği. Aşağıdaki her şey bunlara hizmet eder.

---

## 2. ÜÇ KATMANLI MİMARİ (deneyim)

```
┌─────────────────────────────────────────────┐
│  KATMAN 3: KANIT — AI Konuşma Partneri        │  ← "Öğrendim mi?"
│  Senaryolu diyalog, gerçek üretim              │
├─────────────────────────────────────────────┤
│  KATMAN 2: MOTİVASYON — Oyunlaştırma (görünür) │  ← "Devam etmek istiyorum"
│  Streak, günlük hedef, seviye, rozet, XP        │
├─────────────────────────────────────────────┤
│  KATMAN 1: KALICILIK — SR Motoru (görünmez)    │  ← "Unutmuyorum"
│  Leitner kutuları, optimal tekrar zamanlaması   │
└─────────────────────────────────────────────┘
```

Öğrenci sadece Katman 2'yi *görür* ("bugünkü görevim: 15 kelime"). Katman 1 arkada hangi kelimelerin geleceğine karar verir. Katman 3 haftada birkaç kez "sınav" gibi hissettirir ama eğlencelidir.

---

## 3. KALICILIK MOTORU (Katman 1 — görünmez)

**Sorun:** Yetişkin 55 kelimeyi tek oturumda "öğrenir" ama 3 gün sonra %80'ini unutur. Çözüm: unutma eğrisine karşı zamanlanmış tekrar.

**Leitner sistemi (5 kutu):**
```
Kutu 1 → 1 gün sonra
Kutu 2 → 3 gün
Kutu 3 → 7 gün
Kutu 4 → 14 gün
Kutu 5 → 30 gün (öğrenildi sayılır)

Doğru cevap → bir üst kutu (daha seyrek görür)
Yanlış cevap → Kutu 1'e düşer (yarın tekrar)
```

**Günlük oturum kompozisyonu:**
- %60 vadesi gelmiş **tekrar** (SR kuyruğundan)
- %30 **yeni** kelime
- %10 **zayıf noktalar** (en çok yanlış yapılanlar)

**Öğrenci bunu görmez.** Sadece "Günün 15 kelimesi" görür. Arkada motor karışımı hazırlar. Bu gizlilik kritik — Anki'nin hatası SR'yi çıplak göstermesi, sıkıcılaşması.

**Veri:**
```sql
user_sr_progress (
  user_id UUID,
  vocab_id BIGINT,           -- prod.vocab
  box INT DEFAULT 1,         -- 1..5
  next_review DATE,
  correct_streak INT,
  total_attempts INT,
  last_result BOOL,
  updated_at TIMESTAMPTZ
)
```

**Neden bu ürünün kalbi:** Ticari dil uygulamalarının çoğu bunu atlar; kullanıcı "ilerliyorum" hisseder ama aslında unutur, sonra bırakır. SR retention'ı 2-3x artırır → ticari olarak = düşük churn.

---

## 4. OYUNLAŞTIRMA (Katman 2 — görünür, motive eder)

Amaç: **alışkanlık oluşturmak.** Yetişkin öğrenci disiplinini dışarıdan alır.

**Çekirdek döngü — "Tägliches Ziel" (günlük hedef):**
- Her gün X kelime/dakika hedefi (kullanıcı seçer: 5/10/20 dk).
- Tamamlanınca görsel kutlama (konfeti, ses).
- **Streak** (kesintisiz gün sayısı) — en güçlü tutucu mekanik.

**Streak koruma (Duolingo'dan öğrenilen ama insancıllaştırılmış):**
- Streak freeze: bir gün kaçırırsan streak ölmesin (haftada 1-2 hak).
- **Ama** aşırı ceza yok — bıraktırmak değil, geri getirmek amaç. Streak kaybı utandırmamalı.

**İlerleme yapısı:**
```
Lektion (7 tane) → içinde Schritt (A-E) → içinde kelime grupları
Her Lektion: ilerleme çubuğu + "hakimiyet %" (SR kutularından hesaplanır)
```
- **Hakimiyet ≠ görüldü.** Kelime Kutu 4-5'teyse "hakim". Bu dürüst metrik — öğrenci "gördüm" değil "biliyorum" görür.

**XP & seviye:** Her doğru = XP. Seviye atlama = yeni Lektion/özellik açılır. Ama XP *ikincil* — asıl metrik hakimiyet.

**Rozetler (anlamlı, süs değil):**
- "İlk diyalog" (ilk AI konuşması)
- "50 kelime hakim"
- "7 gün streak"
- "Schritt A tamamlandı"
- Gastronomi teması: "Erste Bestellung" (ilk sipariş diyaloğu) — kitleye özel

**Kritik denge:** Oyunlaştırma öğrenmeyi *taşımalı*, *değiştirmemeli*. Duolingo'nun tuzağı: insanlar XP için tıklar, öğrenmez. Bizim XP'miz sadece gerçek hakimiyet artınca anlamlı artar (SR kutusu yükselince bonus XP).

---

## 5. AI KONUŞMA PARTNERİ (Katman 3 — yeterlilik kanıtı)

**Bu ürünün asıl farkı.** Rakiplerin çoğunda yok. A1 öğrencisi kelime bilir ama *konuşamaz* — bu köprüyü AI kurar.

**Nasıl çalışır:**
- Öğrenci bir Lektion'ı bitirince **senaryolu konuşma** açılır.
- Senaryo o Lektion'ın kelimelerini kullanır. L1 örneği: *"Yeni bir kursa kaydoluyorsun, kendini tanıt."*
- AI (Claude API) A1 seviyesinde konuşur: basit cümle, yavaş, sabırlı, hata düzeltir.

**Sistem promptu kalıbı:**
```
Sen A1 Almanca konuşma partnerisin. Senaryo: {scenario}.
Kullanıcının seviyesi A1 — SADECE basit cümle kullan, öğrendiği kelimelere sadık kal:
{lektion_vocab}. Kullanıcı hata yaparsa nazikçe düzelt ve doğrusunu göster.
Kısa konuş, kullanıcıyı konuştur. Türkçe açıklama gerekirse parantez içinde ver.
```

**İki mod:**
1. **Yazılı chat** (düşük bariyer, utangaç öğrenci için).
2. **Sesli** (STT ile konuş → AI sesli yanıt ElevenLabs ile). Gerçek konuşma pratiği.

**Değerlendirme:** Konuşma sonunda ikinci Claude çağrısı rubrik puanı verir:
```json
{ "grammar": 3, "vocabulary": 4, "task_completion": 5,
  "feedback_tr": "Artikelleri karıştırdın ama iletişim başarılı!" }
```
Bu puan → XP + "konuşma rozeti" + zayıf noktalar SR'ye eklenir.

**Gastronomi kitlesi için özel senaryolar** (ürünün satış noktası):
- "Müşteriden sipariş al"
- "İş görüşmesinde kendini tanıt"
- "Mola/vardiya hakkında konuş"

Bu senaryolar B2B satarken (restoran zincirlerine) doğrudan değer.

---

## 6. EKRAN EKRAN — MOBİL AKIŞ

### 6.1 Ana ekran (Home)
Tek bir net eylem: **"Heute lernen" (bugün öğren)** butonu, büyük.
```
┌────────────────────┐
│  🔥 7   ⭐ Lvl 3    │  ← streak + seviye (üst bar)
│                     │
│   [Guten Tag! 👋]   │  ← kişisel selam (öğrendiği dille)
│                     │
│  Lektion 1 ▓▓▓░░ 68%│  ← aktif Lektion, hakimiyet
│                     │
│  ┌───────────────┐  │
│  │  HEUTE LERNEN  │  │  ← tek büyük CTA
│  │   15 Wörter    │  │
│  └───────────────┘  │
│                     │
│  💬 Sprechen  🎯 Test│  ← ikincil eylemler
└────────────────────┘
```
Kural: Home'da **karar felci olmasın.** Bir ana buton. SR motoru zaten ne öğreneceğini biliyor.

### 6.2 Öğrenme oturumu (çekirdek deneyim)
Kelimeler mekanik-döngüsünden geçer:
```
Kart 1: flashcard   → görsel + kelime + ses (tanıtım)
Kart 2: quiz        → görsel göster, kelimeyi seç (tanıma)
Kart 3: matching    → görsel↔kelime eşleştir (bağ)
Kart 4: fill_blank  → cümle boşluğu doldur (üretim)
[her 5 kartta bir mikro-kutlama, ilerleme çubuğu dolar]
```
- Her ekran **tek görev**. Mobilde dikkat kısa.
- Yanlış cevap → nazik, doğrusunu *hemen* göster, ceza yok. Kelime SR Kutu 1'e.
- Ses her kartta 🐢/🐇 (yavaş/normal) butonuyla.

### 6.3 Kelime kartı anatomisi
```
┌────────────────────┐
│    [görsel/resim]   │  ← vocab: SVG ikon; sahne: foto
│                     │
│   die Schweiz  🔴   │  ← artikel renk kodlu (die=kırmızı)
│   [🐢] [🐇]         │  ← ses butonları
│                     │
│   İsviçre           │  ← çevir'e basınca Türkçe
│   "Ich komme aus    │
│    der Schweiz."    │  ← örnek cümle
└────────────────────┘
```
**Artikel renk kodu** (der=mavi, die=kırmızı, das=yeşil) — Alman öğreniminin altın kuralı.

### 6.4 Konuşma ekranı
Chat arayüzü + mikrofon butonu. AI partner senaryo başlatır, öğrenci yanıtlar. Sonda rubrik kartı + XP.

### 6.5 İlerleme ekranı
```
Lektion 1: 38/55 hakim  ▓▓▓▓▓▓░░
Lektion 2: kilitli 🔒 (L1 %80 olunca açılır)
...
Zayıf kelimeler: [der Herr] [buchstabieren] ...  ← tekrar önerisi
```

---

## 7. TEKNİK MİMARİ (mobil-öncelikli, ticari)

**Neden mobil = özel kararlar:**
- **Offline-first:** Metroda, sinyalsizde çalışmalı. İçerik (kelime+görsel+ses) cihaza cache'lenir. SR verisi lokal tutulur, online olunca sync.
- **Ses/görsel preload:** Bir Lektion'a girince tüm medya arka planda iner. Oturum içinde bekleme = ölüm.

**Stack (güncel karar — `Project.md` ile hizalı):**

| Katman | Seçim | Neden |
|---|---|---|
| Mobil app | **Flutter** | Tek kod → iOS+Android; offline güçlü; ekip uzmanlığı |
| Backend | **FastAPI** | Python stack ile uyum; content API + SR sync + AI proxy |
| DB | **PostgreSQL** | content_items + user_sr_progress |
| AI konuşma | **Claude API** (backend proxy) | Anahtar client'ta durmaz |
| STT (sesli mod) | Whisper / cihaz STT | Konuşma tanıma |
| TTS | ElevenLabs (build-time) | Sesler önceden üretilir → ucuz+hızlı |
| Medya CDN | Cloudflare R2 + Images | Görsel+ses dağıtımı |
| Auth+ödeme | RevenueCat / Stripe | Abonelik (V5+) |

**Önemli:** AI konuşma runtime, gerisi önceden üretilmiş. Kelime kartları, sesler, görseller = build-time. Sadece konuşma partneri canlı Claude çağrısı.

**Offline SR senkronizasyon:**
```
Lokal (Hive/SQLite) → oturum verisi birikir → online olunca backend'e sync
Çakışma: last-write-wins + timestamp
```

**Medya stratejisi (uygulama kararı):**
- Vocab → **SVG** (`assets/vocab/`) — vektör, offline minik, tema renkleri
- Sahneler → **foto WebP/AVIF** (`public/img/`) — GPT fotogerçekçi, CDN'den

---

## 8. TİCARİ MODEL

**Freemium:**
- **Ücretsiz:** Lektion 1-2, günlük sınırlı kelime, temel oyunlaştırma.
- **Premium:** Tüm Lektion, sınırsız AI konuşma, sesli mod, offline indirme, detaylı istatistik.

**B2B:**
- Restoran zincirleri çalışanları için toplu lisans. "Personelini 3 ayda A1 yap" paketi.
- Gastronomi senaryoları + B2B lisans = hazır ürün-pazar uyumu.

---

## 9. YAPMA / TUZAKLAR

1. **SR'yi çıplak gösterme.** "Kutu 3'tesin" deme; "hakimiyet %68" de.
2. **Aşırı cezalandırma.** Yanlış cevap/kaçan gün utandırmamalı.
3. **XP'yi öğrenmenin önüne geçirme.** XP sadece gerçek hakimiyet artınca anlamlı artmalı.
4. **AI konuşmayı A1 üstüne kaçırma.** Partner öğrencinin bildiği kelimelere sadık kalmalı.
5. **Online zorunluluğu.** Offline çalışmazsa hedef kitle kullanamaz.
6. **Görsel tutarsızlığı.** Vocab SVG + foto sahne ayrımı korunmalı (`gorsel_prompt_yonetimi.md`).
7. **de-CH sızması.** Kitap İsviçre, öğrenci de-DE sınavına girecek.

---

## 10. YOL HARİTASI

| Faz | Ne | Kanıt |
|---|---|---|
| **V0** | İçerik pipeline (kelime+görsel+ses) | Çalışır Lektion içeriği |
| **V1 MVP** | Flutter: flashcard+quiz+matching+fill_blank, L1, temel streak | Bir kişi L1'i uçtan uca öğreniyor |
| **V2** | SR motoru + günlük hedef + hakimiyet metriği | Kalıcılık çalışıyor |
| **V3** | AI konuşma (yazılı) + rubrik | Konuşma kanıt katmanı |
| **V4** | Oyunlaştırma tam + offline | Alışkanlık döngüsü kapalı |
| **V5** | Sesli konuşma + freemium/ödeme + 7 Lektion | Ticari lansman |
| **V6** | B2B lisans + gastronomi senaryoları | Kurumsal satış |

**Kritik:** V1-V3 tek Lektion'da mükemmelleş. Önce derinlik, sonra genişlik.

### Mevcut durum (repo — güncel)

| Faz | Durum | Kanıt |
|---|---|---|
| V0 (L3 pilot) | **~%80** | `content/l3/` (26 vocab SVG, 6 foto sahne, 28 ses, 8 egzersiz JSON) |
| V0 (L1) | Bekliyor | L1 vocab + sahneler + ses üretilecek |
| V1 | Bekliyor | Flutter app iskeleti yok |

---

## Özet — bir cümlede

SprachApp: **görünmez bilim** (SR kalıcılık) + **görünür oyun** (streak/seviye) + **gerçek kanıt** (AI konuşma), mobil-offline, gastronomi kitlesine özel senaryolarla B2B'ye de satılabilen bir A1 Almanca uygulaması.

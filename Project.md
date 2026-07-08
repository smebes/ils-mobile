# SprachApp — Genel Mimari ve Ürün Planı (v2 · GÜNCEL)

> **Bu doküman v2'dir.** İlk versiyon (v1) "firmanın lisanslı dijital kitabını uygulamaya taşıyan reader/import platformu" olarak kurgulanmıştı. Telif analizinden (bkz. `sprachapp_pipeline_detayli.md`) sonra ürün yönü değişti: **artık kitabın içeriğini göstermiyoruz; kitabı yalnızca "iskelet/şablon" olarak kullanıp sıfırdan özgün içerik üretiyoruz.** Bu doküman genel mimariyi bu son duruma göre günceller.
>
> İlgili dokümanlar:
> - **`PRODUCT.md`** — ürün tezi, 3 katmanlı deneyim (SR / oyunlaştırma / AI konuşma), ekran akışları, ticari model, V0–V6 yol haritası
> - `sprachapp_pipeline_detayli.md` — içerik pipeline'ının implementasyon-hazır detayı (Extract/Structure/Generate)
> - `gorsel_prompt_yonetimi.md` — GPT foto sahneler + vocab SVG stratejisi
> - `content/l3/` — L3 pilot içerik (vocab, egzersizler, medya referansları)
> - `tools/elevenlabs_tts.py` — tüm diyalogların Almanca seslendirme script'i

---

## 0. Tek Cümlelik Ürün Tanımı

**SprachApp**, Schritte Plus Neu 1 (A1) temelli; **görünmez SR kalıcılığı** + **görünür oyunlaştırma** + **AI konuşma kanıtı** ile çalışan, mobil-öncelikli, ticari bir A1 Almanca uygulamasıdır. İçerik kitabın *mekaniğinden* ilham alınır ama metin/görsel/ses **%100 özgün üretilir** (telif güvenli).

Ürün deneyimi detayı: **`PRODUCT.md`**

---

## 1. v1 → v2: Ne Değişti?

| Konu | v1 (eski) | v2 (güncel) |
|---|---|---|
| İçerik kaynağı | Kitaptan birebir import (PDF sayfa görüntüsü + kırpılan görseller) | Kitaptan **sadece iskelet**; içerik AI ile sıfırdan üretilir |
| Kullanıcıya gösterilen | Kitabın orijinal sayfaları/görselleri | Özgün üretilmiş içerik + üretilmiş görsel + üretilmiş ses |
| Telif riski | Yüksek (birebir çıkarım) | Kontrol altında (staging/prod izolasyonu, fikir telifsiz) |
| PDF viewer / sayfa render | Ürünün merkezinde | **Kaldırıldı** (telifli sayfa göstermek ihlal) — sadece pipeline'da iç kullanım |
| Canvas/annotation import (Fabric.js) | Ürün modülü | **Kaldırıldı** (lisanslı reader'a bağlıydı) |
| Görsel kaynağı | Sayfadan kırpma | **GPT ile üretim** (`gorsel_prompt_yonetimi.md`) |
| Ses kaynağı | Firmadan mp3 | **ElevenLabs ile üretim** (`tools/elevenlabs_tts.py`) |
| Egzersiz mekanikleri | 8-10 tip (esnek) | Odak **5 mekanik**: matching, fill_blank, listening, quiz, speaking |
| Platform/LMS katmanı (roller, sınıf, ödev, ilerleme) | Var | **Korunuyor** (bu doküman) |

**Korunanlar (v1'den taşınan sağlam kısımlar):** organizasyon/rol modeli, exercise engine + validator mimarisi, sınıf/ödev/attempt/ilerleme şeması, admin/teacher/student panelleri.

---

## 2. Telif Stratejisi (kırmızı çizgi — mimariye gömülü)

**Sorun:** Kaynak (Hueber, Schritte Plus Neu 1) telifli. Birebir çıkarıp yayınlamak ihlaldir.

**Çözüm — "iskelet çıkar, içerik üret":**

| Katman | Ne yapar | Telif | Nerede |
|---|---|---|---|
| Extract | Ham metin/bbox/görsel çıkarır | Riskli | `staging` şeması (prod'a asla) |
| Structure | Mekanik tipi + gramer/kelime etiketi + parametre | Güvenli (fikir) | `staging.skeletons` (metin taşımaz) |
| Generate | Sıfırdan özgün cümle/diyalog/görsel/ses | Özgün | `prod.*` |

**Kod-seviyesi kural:** `prod` şemasına yazan hiçbir fonksiyon `staging.raw_blocks.raw_text` okuyamaz. CI'da statik kontrol: `raw_text` → `prod` importunu grep ile engelle.

**İki istisna telifsiz:** (1) kelime listeleri (Lernwortschatz — fikir), (2) gramer konu adları (Plural, Akkusativ). Bunlar doğrudan kullanılabilir.

Detay: `sprachapp_pipeline_detayli.md` §1.

---

## 3. Genel Mimari

```
┌──────────────────────── İÇERİK ÜRETİM HATTI (offline, build-time) ────────────────────────┐
│                                                                                            │
│  [PDF]──Extract──▶ staging.raw_blocks ──Structure──▶ staging.skeletons ──Generate──┐       │
│  (telifli, izole)                        (metinsiz iskelet)                          │       │
│                                                                                     ▼       │
│   Claude API ──▶ metin/diyalog/egzersiz ─┐                                   prod.content_  │
│   GPT gpt-image-1 ──▶ görsel (PNG) ──WebP─┼──▶ Kalite kapısı (2. LLM) ──────▶  items +      │
│   ElevenLabs ──▶ ses (mp3) ──────────────┘   + Busra QA (reviewed=true)      media_assets   │
│                                                                                            │
└────────────────────────────────────────────────────────────────────────────────────────┘
                                             │
                                             ▼
┌──────────────────────────────── RUNTIME (uygulama) ───────────────────────────────────────┐
│                                                                                            │
│  PostgreSQL ──▶ FastAPI ──▶ CDN (Cloudflare R2 + Images)                                   │
│                     │                                                                       │
│        ┌────────────┼────────────┐                                                         │
│        ▼            ▼            ▼                                                          │
│   Flutter App   (V5+ Admin)   AI proxy          speaking = runtime Claude; SR sync endpoint  │
│  iOS/Android    web panel     Claude API         offline: Hive + asset bundle per Lektion    │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

İki net dünya var:
- **Build-time (offline pipeline):** İçerik + görsel + ses üretilir, kalite kapısından geçer, prod'a yazılır. Ağır ve pahalı işler burada bir kez yapılır.
- **Runtime (uygulama):** Sadece hazır `prod` içeriğini servis eder. Tek AI runtime maliyeti: `speaking` (konuşma partneri).

---

## 4. İçerik Üretim Pipeline'ı (özet)

Tam detay `sprachapp_pipeline_detayli.md`'de. Özet:

1. **Extract (Katman 1):** `pdfplumber` ile sayfa→blok; kitap/Lektion/Schritt etiketi; görsel sayfaları raster; ses referansları. → `staging.raw_blocks`.
2. **Structure (Katman 2):** Kural+LLM hibrit sınıflandırma → 5 mekanikten biri + gramer/kelime alanı + parametre. → `staging.skeletons` (telifsiz).
3. **Generate (Katman 3):** Mekanik başına generator → Claude ile özgün içerik → JSON şema doğrula → kalite kapısı (2. Claude çağrısı) → `prod.content_items`.

**7 Lektion (A1):** 1 Tanışma · 2 Familie · 3 Einkaufen · 4 Wohnung · 5 Tagesabläufe · 6 Freizeit · 7 Kinder und Schule.
**Pilot:** Lektion 3 (Einkaufen) — 4 mekaniğin hepsini test eder.

---

## 5. Görsel Üretim Pipeline'ı (GPT)

- **Araç:** GPT görsel üretimi (`gpt-image-1` / ChatGPT). İlk fazda **manuel** (Emre promptları yapıştırır), sonra API ile batch.
- **Tutarlılık:** Tüm uygulama tek bir görsel dilinde olmalı → `gorsel_prompt_yonetimi.md` içinde **master stil promptu** + **karakter kanonu** tanımlı; her prompt bu stili miras alır.
- **Adlandırma:** `l{lektion}_{tip}_{slug}.webp` (ör. `l3_vocab_apfel.webp`, `l3_scene_supermarkt.webp`). Kural dokümanda.
- **Format:** GPT büyük PNG üretir → **WebP/AVIF**'e dönüştürülür. Önerilen yöntem: master PNG'yi R2'ye at, **Cloudflare Images** ile cihaza göre AVIF/WebP + boyut on-the-fly servis et (manuel dönüştürmeye gerek kalmaz). Yerel/manuel dönüştürme için `sharp`/`cwebp` script'i dokümanda. Detay §11 ve `gorsel_prompt_yonetimi.md`.

---

## 6. Ses Üretim Pipeline'ı (ElevenLabs)

- **Araç:** ElevenLabs `eleven_multilingual_v2` (Almanca uzun-form için ideal).
- **Ruh:** Almanca **anadil**, A1 öğrenciye uygun **yavaş ve akıcı** (`speed ≈ 0.85`, yüksek `stability`), net telaffuz.
- **Çok sesli:** Her karaktere/konuşmacıya sabit bir ses (voice) atanır → diyaloglar tutarlı.
- **Script:** `tools/elevenlabs_tts.py` tüm `prod.content_items` diyaloglarını batch seslendirir, mp3 üretir, `media_assets`'e URL yazar. İki hız (yavaş + normal) üretebilir (A1 pedagojisi için faydalı).

---

## 7. Egzersiz Mekanikleri (5)

Runtime motoru mekanik-agnostik: her mekanik `payload` (render) + `solution` (değerlendirme) JSON'u ile gelir; frontend `mechanic` alanına göre bileşen seçer, backend `validators/*` ile puanlar.

| Mekanik | Açıklama | Değerlendirme |
|---|---|---|
| `matching` | Eşleştirme (kelime↔görsel, tekil↔çoğul) | Tam eşleşme (kısmi puan opsiyonel) |
| `fill_blank` | Boşluk doldurma | Normalize + `answer`/`alt` eşleşmesi |
| `listening` | Ses dinle → anlama sorusu (MC) | Doğru şık |
| `quiz` | Çoktan seçmeli / doğru-yanlış | Doğru şık |
| `speaking` | AI konuşma partneri (runtime) | Konuşma sonu 2. Claude çağrısı → rubrik |

Payload/solution şemaları `sprachapp_pipeline_detayli.md` §4'te. Örnek render JSON'ları §8.4'te.

---

## 8. Kullanıcı Rolleri (LMS katmanı — v1'den korunuyor)

**Admin:** organizasyon yönetimi, içerik pipeline'ını tetikleme, üretilen içeriği QA/onaylama (`reviewed=true`), yayınlama, kullanıcı yönetimi.
**Teacher:** sınıf oluşturma, öğrenci ekleme, ödev atama, ilerleme/yanlış analizi.
**Student:** Lektion/ders açma, egzersiz çözme, ses dinleme, konuşma pratiği, ilerleme takibi.

Not: v2'de admin artık "PDF kırpma / canvas import" yapmıyor; onun yerine **içerik/QA operatörü** rolü (üretilen içeriği gözden geçir → onayla).

---

## 9. TEKNOLOJİ KARARI (mobil-öncelikli, ticari)

> Ürün kararı: **`PRODUCT.md` §7**. Özet: Flutter (offline-first mobil) + FastAPI (Python stack ile uyum) + PostgreSQL.

| Katman | Seçim | Gerekçe |
|---|---|---|
| **Mobil app** | **Flutter** | iOS+Android tek kod; offline/cache olgun; ekip uzmanlığı; B2C ticari ürün odak |
| **Backend** | **FastAPI** + PostgreSQL | Content API, SR sync, AI konuşma proxy; pipeline (Python) ile aynı ekosistem |
| **Lokal (mobil)** | **Hive** veya SQLite | SR kutuları + oturum verisi offline; online sync |
| **Depolama + CDN** | **Cloudflare R2 + Images** | Foto sahneler WebP/AVIF; vocab SVG doğrudan bundle/CDN |
| **İçerik pipeline** | **Python** (pdfplumber, pydantic, anthropic SDK) | Extract/Structure/Generate |
| **TTS (build-time)** | ElevenLabs (`tools/elevenlabs_tts.py`) | Sesler önceden üretilir — runtime maliyet yok |
| **AI konuşma (runtime)** | Claude API (backend proxy) | Tek canlı maliyet noktası |
| **Auth + ödeme (V5+)** | RevenueCat / Stripe | Freemium abonelik |

**Medya ayrımı:** Vocab = **SVG** (`assets/vocab/`, repoda, offline bundle). Sahneler = **foto WebP** (`public/img/` → CDN). Görsel performansının çoğu CDN + preload + offline cache'ten gelir.

**Not:** Öğretmen/LMS paneli (`Project.md` §8) B2B fazında (V6); V1–V4 öğrenci uygulaması odaklı.

---

## 10. Klasör Yapısı (monorepo)

```
sprachapp/
  mobile/                     # Flutter — iOS/Android (ana ürün)
    lib/
      features/ home/ learn/ speaking/ progress/
      core/ sr/ audio/ assets/
  api/                        # FastAPI
    app/routers/ content.py sr.py speaking.py auth.py
  content/                    # Üretilmiş içerik (git'te örnek L3)
    l3/lektion.json exercises.json
  assets/vocab/               # SVG ikonlar (offline bundle)
  pipeline/                   # Python içerik üretim hattı
  tools/                      # elevenlabs_tts, img_to_webp
  masters/ public/img/ storage/ # medya (gitignore)
  PRODUCT.md Project.md sprachapp_pipeline_detayli.md
```

---

## 11. Görsel/Asset Dağıtım Stratejisi ("çok resim" problemi)

**Problem:** GPT büyük PNG üretiyor (çoğu ~1024–1536 px, birkaç MB). Yüzlerce/binlerce görsel olacak.

**Strateji (katmanlı):**

1. **Master:** GPT çıktısı PNG → R2'de `masters/` altında saklanır (orijinal, kayıpsız). Kaynak olarak bir kez.
2. **Servis:** İstemci görseli **CDN üzerinden** ister; Cloudflare Images (veya imgproxy) cihazın `Accept` başlığına göre **AVIF > WebP > PNG** ve istenen genişlikte döner. İstemci asla ham PNG çekmez.
3. **İstemci:** Flutter `cached_network_image` + asset bundle (SVG vocab) + Lektion preload. Offline'da bundle'dan okur.
4. **Boyut disiplini:** Vocab/flashcard görselleri 512–768 px yeter; sahne/kapak 1024–1280 px. Master'ı gereğinden büyük tutma.

**Neden bu "manuel WebP çevirmekten" daha iyi?** Manuel çevirmede tek bir sabit boyut/format üretirsin; telefon da tablet de aynı dosyayı çeker. CDN yaklaşımında her cihaz kendine en uygun format+boyutu alır, sen tek master tutarsın. Bakımı sıfıra yakın.

**İlk fazda manuel çalışırken** (henüz CDN yokken) yerel dönüştürme için `tools/img_to_webp.mjs` (sharp): PNG → WebP (q80) + AVIF + 2 boyut (768/1280). Detay `gorsel_prompt_yonetimi.md` §8.

---

## 12. Veri Modeli (PostgreSQL)

İki şema: `staging` (telifli, izole) ve `prod` (uygulama tüketir). Aşağıda özet; pipeline tabloları `sprachapp_pipeline_detayli.md` §5'te ayrıntılı.

### 12.1 Referans / telifsiz
```sql
CREATE TABLE prod.lektionen (
  id INT PRIMARY KEY, nummer INT, titel TEXT, thema TEXT, grammar_focus TEXT[]);

CREATE TABLE prod.vocab (           -- Lernwortschatz'tan parse (fikir telifsiz)
  id BIGSERIAL PRIMARY KEY, lektion_id INT,
  artikel TEXT, wort TEXT, plural TEXT, wortart TEXT,
  beispiel TEXT, uebersetzung_tr TEXT,
  image_asset_id UUID);            -- kelimenin üretilmiş görseli
```

### 12.2 Staging (izole, prod'a sızmaz)
```sql
-- staging.raw_blocks, staging.skeletons
-- (tam tanım sprachapp_pipeline_detayli.md §2, §3)
```

### 12.3 Prod içerik
```sql
CREATE TABLE prod.content_items (
  id            TEXT PRIMARY KEY,
  skeleton_id   TEXT,
  lektion_id    INT,
  mechanic      TEXT,              -- matching|fill_blank|listening|quiz|speaking
  cefr          TEXT DEFAULT 'A1',
  grammar_topic TEXT,
  vocab_domain  TEXT,
  payload       JSONB,             -- render verisi
  solution      JSONB,             -- değerlendirme anahtarı
  audio_url     TEXT,
  quality_pass  BOOL,
  reviewed      BOOL DEFAULT false,  -- QA onayı
  generated_at  TIMESTAMPTZ DEFAULT now());
```

### 12.4 Media assets (üretilen görsel/ses)
```sql
CREATE TABLE prod.media_assets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type TEXT NOT NULL,             -- image | audio
  origin TEXT NOT NULL,           -- 'gpt_image' | 'elevenlabs'
  master_url TEXT NOT NULL,       -- R2 master (PNG/mp3)
  cdn_url TEXT,                   -- Cloudflare Images tabanı
  prompt_ref TEXT,                -- gorsel_prompt_yonetimi.md kaydı / tts text hash
  lektion_id INT, slug TEXT,
  width INT, height INT, duration_seconds NUMERIC,
  license_status TEXT DEFAULT 'original_generated',
  created_at TIMESTAMPTZ DEFAULT now());
```

### 12.6 SR + oyunlaştırma (PRODUCT.md §3–4)
```sql
CREATE TABLE user_sr_progress (
  user_id UUID, vocab_id BIGINT,
  box INT DEFAULT 1,           -- Leitner 1..5
  next_review DATE,
  correct_streak INT DEFAULT 0,
  total_attempts INT DEFAULT 0,
  last_result BOOL,
  updated_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (user_id, vocab_id));

CREATE TABLE user_gamification (
  user_id UUID PRIMARY KEY,
  streak INT DEFAULT 0,
  streak_freeze_remaining INT DEFAULT 1,
  xp INT DEFAULT 0,
  level INT DEFAULT 1,
  daily_goal_minutes INT DEFAULT 10,
  last_active_date DATE
);
```
Mobil offline: Hive'da aynı şema → sync endpoint `POST /sr/sync`.

### 12.7 Platform / LMS (B2B — V6, opsiyonel)

`organizations`, `users`, `classes`, `assignments` — kurumsal lisans fazında. V1–V4 B2C öğrenci app odaklı.

```sql
CREATE TABLE prod.attempt_responses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID, content_id TEXT REFERENCES prod.content_items(id),
  given_answer JSONB, is_correct BOOL, score NUMERIC,
  checked_by TEXT DEFAULT 'system',   -- system | teacher | ai
  feedback JSONB, attempted_at TIMESTAMPTZ DEFAULT now());
```

---

## 13. API Endpoint Planı (v2)

```
Auth       POST /auth/login  /auth/refresh   GET /auth/me
Content    GET  /lektionen                    GET /lektionen/:id/content
           GET  /content/:id                  # payload (solution gizli)
           POST /content/:id/check            # cevap değerlendirme
Speaking   POST /speaking/:contentId/session  # runtime AI partner
           POST /speaking/sessions/:id/turn
           POST /speaking/sessions/:id/finish # rubrik puanı
Media      GET  /media/:id                    # CDN URL resolve
Classes    GET/POST /classes  POST /classes/:id/students
Assign.    POST /assignments  GET /assignments/student/me
Attempts   POST /attempt-sessions  POST /attempt-sessions/:id/answers
           POST /attempt-sessions/:id/complete   GET /students/:id/progress
Admin/QA   GET  /admin/content?reviewed=false    # QA kuyruğu
           POST /admin/content/:id/review        # reviewed=true
           POST /admin/pipeline/run             # üretim job tetikle (BullMQ)
```

---

## 14. Yol Haritası (`PRODUCT.md` §10 ile hizalı)

| Faz | İçerik | Uygulama | Durum |
|---|---|---|---|
| **V0** | Lektion içerik (vocab SVG + foto + ses + egzersiz JSON) | — | **L3 pilot ~%80** (`content/l3/`) |
| **V1 MVP** | L1 tam içerik | Flutter: flashcard→quiz→matching→fill_blank, temel streak | Sırada |
| **V2** | 7 Lektion içerik batch | SR motoru (Leitner) + günlük hedef + hakimiyet % | — |
| **V3** | speaking senaryoları | AI konuşma (yazılı) + rubrik | — |
| **V4** | — | Rozet, seviye, streak freeze, **offline** Lektion bundle | — |
| **V5** | tam set | Sesli konuşma, freemium, 7 Lektion | — |
| **V6** | gastronomi paketi | B2B lisans | — |

**V1 ilk demo:** L3 veya L1 — öğrenci "Heute lernen" → 4 mekanik döngüsü → ses 🐢/🐇. İçerik hazır (L3); app iskeleti eksik.

**Eski sprint planı (teknik borç / pipeline):** Extract/Structure/Generate otomasyonu V2 sonrası ölçekleme için; şimdilik `content/l3/` manuel üretim kanıtı yeterli.

---

## 15. Riskler

| Risk | Etki | Azaltma |
|---|---|---|
| Ham metin prod'a sızar | Telif ihlali | CI statik kontrol: `raw_text`→`prod` import yasak |
| Görsel tutarsızlığı (her resim farklı stil) | Amatör görünüm | Master stil promptu + karakter kanonu (`gorsel_prompt_yonetimi.md`); seed/referans görsel |
| GPT görsel maliyeti/hacmi | Bütçe | Vocab görselleri paylaşımlı (kelime bazlı tekilleştir); boyut disiplini; CDN tek master |
| ElevenLabs karakter tutarsızlığı | Ses kopukluğu | `voices.json` ile karakter→voice sabitleme |
| de-CH vs de-DE karışması | Yanlış öğretim | Kalite kapısında dil normalizasyonu (hedef de-DE) |
| A1 üstü içerik | Seviye kayması | Kalite kapısı CEFR kontrolü + vocab beyaz liste |
| Speaking runtime maliyeti | Değişken maliyet | Kısa cevap sistem promptu; oturum/limit; ucuz model opsiyonu |

---

## 16. Sıradaki İşler (V1 MVP)

1. **Flutter iskelet:** `mobile/` — Home ("Heute lernen"), Learn oturumu, 4 mekanik widget.
2. **İçerik yükleme:** `content/l3/` JSON'ları + `assets/vocab/` + `public/img/` + `storage/audio/` bundle veya API.
3. **FastAPI minimal:** `GET /lektionen/3`, `GET /content/:id`, `POST /content/:id/check`.
4. **Öğrenme döngüsü:** flashcard → quiz → matching → fill_blank (`PRODUCT.md` §6.2).
5. **Ses:** 🐢/🐇 butonları (slow/normal mp3 yolları `exercises.json`'da hazır).
6. **Temel streak:** günlük hedef tamamlanınca +1 (Hive lokal).
7. **L1 içerik:** V0'yı L1 için tekrarla (tanışma teması — kitaptaki foto stiline uygun sahneler).
8. **V2:** Leitner SR motoru (`user_sr_progress` + günlük kuyruk karışımı).

# SprachApp — Genel Mimari ve Ürün Planı (v2 · GÜNCEL)

> **Bu doküman v2'dir.** İlk versiyon (v1) "firmanın lisanslı dijital kitabını uygulamaya taşıyan reader/import platformu" olarak kurgulanmıştı. Telif analizinden (bkz. `sprachapp_pipeline_detayli.md`) sonra ürün yönü değişti: **artık kitabın içeriğini göstermiyoruz; kitabı yalnızca "iskelet/şablon" olarak kullanıp sıfırdan özgün içerik üretiyoruz.** Bu doküman genel mimariyi bu son duruma göre günceller.
>
> İlgili dokümanlar:
> - `sprachapp_pipeline_detayli.md` — içerik pipeline'ının implementasyon-hazır detayı (Extract/Structure/Generate)
> - `gorsel_prompt_yonetimi.md` — GPT görsel üretimi için prompt kataloğu ve stil rehberi
> - `tools/elevenlabs_tts.py` — tüm diyalogların Almanca seslendirme script'i

---

## 0. Tek Cümlelik Ürün Tanımı

**SprachApp**, Schritte Plus Neu 1 (A1) kitabının *öğretim mekaniğini* referans alıp; metinleri Claude, görselleri GPT (gpt-image-1), sesleri ElevenLabs ile **%100 özgün üreten**, öğrenci/öğretmen/admin rolleriyle çalışan, görsel-yoğun bir A1 Almanca öğrenme uygulamasıdır.

Kullanıcıya gösterilen hiçbir metin/görsel/ses telifli kaynaktan **kopyalanmaz**; hepsi üretilir.

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
│  PostgreSQL ──▶ NestJS API ──▶ CDN (Cloudflare R2 + Images: AVIF/WebP)                      │
│                     │                                                                       │
│        ┌────────────┼────────────┐                                                         │
│        ▼            ▼            ▼                                                          │
│   Student App   Teacher Panel  Admin Panel        speaking mekaniği = runtime Claude çağrısı │
│  (Expo RN)      (Next.js)      (Next.js)                                                    │
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

## 9. TEKNOLOJİ KARARI (görsel-yoğun uygulama için)

> Soru: "Çok fazla resim olacağı için en efektif hangisi?" — Kritik ayrım şu: **görsel verimliliği framework'ten çok teslim (delivery) hattından gelir.** Yani asıl kaldıraç CDN + format + lazy-load. Framework'ü de buna göre seçiyoruz.

**Karar:**

| Katman | Seçim | Gerekçe |
|---|---|---|
| **Öğrenci uygulaması** | **Expo (React Native)** + `expo-image` | Tek kod tabanı iOS/Android/Web. `expo-image` bu iş için en güçlüsü: yerel AVIF/WebP desteği, agresif disk+bellek cache, `blurhash`/`thumbhash` placeholder, öncelikli/lazy yükleme. Görsel-yoğun app tam da bunu ister. TS ile tüm stack tek dilde. |
| **Admin + Teacher panel** | **Next.js (React)** + Tailwind + shadcn/ui | `next/image` ile otomatik responsive + AVIF/WebP; QA/onay arayüzü için hızlı. |
| **Backend** | **NestJS** + PostgreSQL + Prisma | v1 kararı geçerli; TS stack bütünlüğü, BullMQ/Redis kuyruğu (üretim job'ları). |
| **Depolama + CDN** | **Cloudflare R2 + Cloudflare Images** | Görsel dağıtımının kalbi. Master PNG'yi bir kez yükle; cihaza göre AVIF/WebP + boyut *on-the-fly*. "PNG→WebP manuel çevirme" derdi CDN'e devredilir. |
| **İçerik pipeline** | **Python** (pdfplumber, pydantic, anthropic SDK) | Extract/Structure/Generate; kanıtlanmış. |
| **TTS** | ElevenLabs (`tools/elevenlabs_tts.py`) | Almanca anadil, hız/stabilite kontrolü. |

**Neden Flutter değil (kullanıcının geçmişi olsa da)?** İki gerçek sebep: (1) Backend+admin zaten TS (NestJS+Next.js) — Expo ile **tüm ürün tek dil (TypeScript)** ve **paylaşılan tipler** olur. (2) Görsel-yoğun senaryoda `expo-image`'in AVIF + cache + placeholder olgunluğu, Flutter `cached_network_image`'e göre daha az uğraşla daha iyi sonuç verir. Flutter ikincil bir alternatif olarak masada kalabilir; ama tavsiye Expo.

**Not:** Framework ne olursa olsun, görsel performansının %80'i şu 3 karardan gelir → (a) CDN'in AVIF/WebP + responsive boyut vermesi, (b) `expo-image`/`next/image` ile lazy-load + placeholder, (c) master görselleri makul çözünürlükte tutmak (aşağı §11).

---

## 10. Klasör Yapısı (monorepo)

```
sprachapp/
  apps/
    api/                      # NestJS
      src/modules/
        auth/ organizations/ users/
        content/              # prod.content_items servis
        media/                # asset servis (R2/CDN URL)
        exercises/            # engine + validators/
        classes/ assignments/ attempts/
        speaking/             # runtime Claude konuşma partneri
    student/                  # Expo (React Native) — iOS/Android/Web
    admin/                    # Next.js — admin + teacher panel
  packages/
    db/prisma/                # şema + migration
    shared/                   # ortak TS tipleri (payload/solution şemaları)
  pipeline/                   # Python içerik üretim hattı
    extract/ structure/ generate/
    quality_gate/
  tools/
    elevenlabs_tts.py         # ses üretimi
    voices.json               # karakter→voice eşlemesi
    dialogues.sample.json     # örnek girdi
    img_to_webp.mjs           # (opsiyonel) yerel PNG→WebP/AVIF
  storage/                    # yerel dev (R2 mock)
  docker-compose.yml
  Project.md · sprachapp_pipeline_detayli.md · gorsel_prompt_yonetimi.md
```

---

## 11. Görsel/Asset Dağıtım Stratejisi ("çok resim" problemi)

**Problem:** GPT büyük PNG üretiyor (çoğu ~1024–1536 px, birkaç MB). Yüzlerce/binlerce görsel olacak.

**Strateji (katmanlı):**

1. **Master:** GPT çıktısı PNG → R2'de `masters/` altında saklanır (orijinal, kayıpsız). Kaynak olarak bir kez.
2. **Servis:** İstemci görseli **CDN üzerinden** ister; Cloudflare Images (veya imgproxy) cihazın `Accept` başlığına göre **AVIF > WebP > PNG** ve istenen genişlikte döner. İstemci asla ham PNG çekmez.
3. **İstemci:** `expo-image` / `next/image` → lazy-load + placeholder (blurhash) + disk cache. Ekranda görünene kadar indirmez.
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

### 12.5 Platform / LMS (v1'den korunan tablolar)
`organizations`, `users`, `roles`, `user_roles`, `classes`, `class_students`,
`assignments`, `attempt_sessions`, `attempt_responses`, `progress_summary`.
(Tam DDL için v1 şeması geçerlidir; `book_files`, `book_pages`, `page_canvas_layers`, `page_objects` **kaldırıldı** — v2'de PDF/canvas göstermiyoruz.)

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

## 14. Uygulama Sırası (build planı / sprintler)

Pipeline fazları (`sprachapp_pipeline_detayli.md` §6) ile uygulama sprintlerini tek hatta hizalıyoruz. Prensip: **önce L3 pilotunu uçtan uca kanıtla, sonra ölçekle.**

| Sprint | İçerik hattı | Uygulama tarafı | Bitiş kriteri |
|---|---|---|---|
| **S0 · Hazırlık** | pipeline repo iskeleti, DB şeması | monorepo, NestJS + Expo + Next.js iskelet, docker-compose, auth temeli | API health + login + boş app çalışır |
| **S1 · Extract/Structure (L3)** | L3 raw_blocks → skeletons | admin QA ekranı iskeleti | L3 iskeletleri telifsiz, etiketli |
| **S2 · Generate metin (L3, 2 mekanik)** | matching + fill_blank + kalite kapısı | student: bu 2 mekaniğin render + check | L3'te 2 mekanik oynanabilir |
| **S3 · Görsel üretim (L3)** | GPT ile L3 vocab+scene görselleri → R2 + CDN | student: görsel render (expo-image) | L3 görselleri app'te CDN'den akıcı |
| **S4 · Ses üretim + listening (L3)** | ElevenLabs ile L3 diyalogları → mp3 | student: listening mekaniği | Sesli dinleme çalışıyor |
| **S5 · quiz + speaking (L3)** | quiz üret; speaking sistem promptu | student: quiz + runtime konuşma partneri | L3 uçtan uca 5 mekanik |
| **S6 · QA/onay akışı** | reviewed flag | admin: içerik onay arayüzü | reviewed=true içerik yayınlanır |
| **S7 · Teacher panel** | — | sınıf/öğrenci/ödev/ilerleme | öğretmen ödev verip sonucu görür |
| **S8 · Ölçekleme** | 7 Lektion'a batch (metin+görsel+ses) | app: tam Lektion listesi | 7 Lektion prod'da, onaylı |

**İlk demo hedefi (S2–S3 sonu):** L3 Einkaufen — öğrenci giriş yapar, üretilmiş görsellerle matching + fill_blank çözer, sonucu görür. Firmaya "özgün içerik + tutarlı görsel dili" vizyonunu kanıtlar.

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

## 16. Özet — Sıradaki İlk 10 İş

1. Monorepo + docker-compose (Postgres + Redis) ayağa kaldır.
2. Prisma şeması: `prod` + `staging` + LMS tabloları.
3. NestJS auth (JWT + rol) + Expo/Next.js iskeletleri.
4. Python pipeline iskeleti (extract/structure/generate klasörleri).
5. L3 Extract → `staging.raw_blocks`.
6. L3 Structure → `staging.skeletons` (telifsiz).
7. L3 Generate: matching + fill_blank + kalite kapısı.
8. `gorsel_prompt_yonetimi.md`'deki L3 promptlarıyla görselleri üret → R2/CDN.
9. `tools/elevenlabs_tts.py` ile L3 diyaloglarını seslendir.
10. Student app'te L3'ü uçtan uca oynanabilir yap → ilk demo.

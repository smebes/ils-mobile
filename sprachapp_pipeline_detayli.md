# SprachApp — İçerik Pipeline: Detaylı Teknik Doküman
**Kaynak:** Schritte Plus Neu 1 (Schweiz), A1 — 215 sayfa
**Amaç:** PDF → yapılandırılmış özgün içerik → 4 mekanik (matching, fill_blank, listening, quiz) + AI konuşma
**Bu doküman:** Claude Code'a doğrudan beslenebilir; her katman implementasyon-hazır.

---

## 0. PDF Yapısı — Ölçülmüş Gerçekler

Aşağıdaki her sayı PDF üzerinde koştutulan analizden gelir, tahmin değil.

**Fiziksel yapı:**
- 215 sayfa, tek PDF. **İki kitap birleşik:**
  - **Kursbuch** (ders kitabı): s1–96
  - **Arbeitsbuch** (alıştırma kitabı): s97–~178 (başlangıç s97)
  - **Lernwortschatz** (kelime listeleri): s179–~215
- Sayfa boyutu 595×793 pt (A4), InDesign kaynaklı, gömülü fontlar var → metin katmanı temiz çıkıyor.

**7 Lektion — başlıklar (TOC'tan doğrulandı):**
| # | Titel | Ana tema | Gramer odağı |
|---|---|---|---|
| 1 | Guten Tag. Mein Name ist … | Tanışma, selamlama | Aussage, W-Frage, sein/heissen/kommen konjugasyonu, Präposition *aus* |
| 2 | Meine Familie | Aile, hâl-hatır | Possessivartikel (mein/dein/Ihr), Personalpronomen |
| 3 | Einkaufen | Alışveriş, yiyecek | Plural der Nomen, Akkusativ, kein- |
| 4 | Meine Wohnung | Ev, mekân | Präpositionen, es gibt |
| 5 | Tagesabläufe | Günlük rutin | trennbare Verben, Uhrzeit |
| 6 | Freizeit | Boş zaman | Modalverben, Satzakzent |
| 7 | Kinder und Schule | Çocuk, okul | Perfekt, Wechselpräpositionen |

**Her Lektion iç yapısı (sabit kalıp — otomasyon için kritik):**
```
Lektion N
├── Foto-Hörgeschichte (Folge N)   → giriş diyalog/dinleme
├── Schritt A ── E                  → 5 öğrenme adımı (A–C temel, D–E beceri)
├── Grammatik & Kommunikation       → gramer tabloları + ifade kalıpları
├── Zwischendurch mal …             → Comic / Lied / Projekt (fakültatif, görsel)
└── (Arbeitsbuch tarafı)
    ├── Übungen A–E                 → adım başına alıştırmalar
    ├── Phonetik                    → telaffuz
    ├── Prüfungsaufgabe             → sınav pratiği (Hören/Lesen/Schreiben/Sprechen Teil X)
    ├── Test                        → Lektion sonu değerlendirme
    └── Fokusseiten                 → Fokus Alltag / Beruf / Familie
```

**Mekanik dağılımı (215 sayfada ham tetikleyici hit sayısı):**
| Mekanik | Hit | Payı | Not |
|---|---|---|---|
| fill_blank (Ergänzen/Schreiben/Notieren) | 273 | %34 | En yaygın — MVP'de önce bu |
| listening (Hören/Phonetik/Satzmelodie) | 186 | %23 | TTS gerektiriyor |
| matching (Ordnen/Verbinden zu) | 122 | %15 | Görsel bağımlı olanlar zor |
| quiz (kreuzen an/Was ist richtig) | 110 | %14 | En kolay değerlendirme |
| speaking (Sprechen mit Partner) | 73 | %9 | AI partner |
- 215 sayfanın **174'ünde** en az bir mekanik var → içerik yoğunluğu yüksek.

**Gramer referans sistemi:** Kitap `ÜG X.YY` kodlarıyla harici gramer kitabına bağlanıyor (17 farklı kod tespit edildi: ÜG5.01=konjugasyon, ÜG10.01=Aussage vb.). Bu kodları **gramer-konu etiketi** olarak kullanacağız.

**Lernwortschatz formatı (s179+) — otomatik parse edilebilir, çok değerli:**
```
an·schauen          Schauen Sie die Fotos an.     ← fiil + örnek cümle
das Bild, -er        Sehen Sie die Bilder an.       ← artikel + isim + çoğul-eki + cümle
das Wort, ¨-er       Raten Sie Wörter.              ← Umlaut-çoğul (¨) işareti
```
Kalıp: `[artikel] Wort, [çoğul-eki]   [örnek cümle]`. Regex ile %90+ yakalanır. **Bu tablo telifsiz kelime hazinesi çıkarımının altın kaynağı** (kelimeler fikir, tek tek koruma altında değil).

---

## 1. TELİF STRATEJİSİ (mimariye gömülü)

**Sorun:** Hueber telifli. Birebir metin çıkarıp yayınlamak ihlal.

**Çözüm — "iskelet çıkar, içerik üret":**

| Katman | Ne çıkar/üretir | Telif durumu | Nerede saklanır |
|---|---|---|---|
| Extract | Ham metin, bbox, görsel | İhlal riski YÜKSEK | `staging` şeması (prod'a asla) |
| Structure | Mekanik tipi, gramer-konu, kelime-alan, parametre | Güvenli (fikir, ifade değil) | `staging.skeletons` |
| Generate | Sıfırdan özgün cümle/diyalog | Özgün, güvenli | `prod.content_items` |

**Kod-seviyesi kural:** `prod` şemasına yazan hiçbir fonksiyon `staging.raw_blocks.text` alanını okuyamaz. Sadece `skeletons` (metin taşımayan şema) okur. Bu bir mimari sınır, yorum değil — CI'da statik kontrol koy (`raw_blocks.text` → `prod` importunu grep'le engelle).

**İki istisna telifsiz kalır:** (1) kelime listeleri (Lernwortschatz), (2) gramer konu adları (Plural, Akkusativ). Bunlar doğrudan kullanılabilir.

---

## 2. KATMAN 1 — EXTRACT

**Girdi:** `9783191810801.pdf`
**Çıktı:** `staging.raw_blocks`

### Şema
```sql
CREATE TABLE staging.raw_blocks (
  id          BIGSERIAL PRIMARY KEY,
  page        INT,
  book        TEXT,          -- 'kursbuch' | 'arbeitsbuch' | 'wortschatz'
  lektion     INT,           -- 1..7, tespit edilirse
  schritt     TEXT,          -- 'A'..'E' | 'phonetik' | 'test' | null
  block_type  TEXT,          -- 'text' | 'image' | 'table'
  bbox        NUMERIC[4],
  raw_text    TEXT,          -- TELİFLİ — staging'de kalır
  image_path  TEXT,
  audio_ref   TEXT           -- 'Folge 3' gibi ses referansı
);
```

### İş adımları
1. **Kitap sınırı:** s1–96 kursbuch, s97+ arbeitsbuch, s179+ wortschatz (ölçüldü).
2. **Lektion tespiti:** Sayfa başında `^\s*([1-7])\s+[A-ZÄÖÜ]` deseni + TOC'tan sayfa aralıkları. Kursbuch'ta her Lektion ~12 sayfa.
3. **Schritt tespiti:** Sayfa içinde `Schritt [A-E]`, `^\s*[A-E]\d` (örn "C1", "C2") alıştırma numaraları.
4. **Blok çıkarımı:** `pdfplumber` `page.extract_words()` + satır gruplama; her mantıksal blok bir satır.
5. **Görsel sayfalar:** Comic (Zwischendurch), Suchbild, resimli matching → `pdftoppm -r 150 -f N -l N` ile rasterle, `image_path` doldur.
6. **Ses referansı:** `Folge \d`, `Hören Sie` içeren blokları `audio_ref` ile işaretle.

### Kod iskeleti
```python
import pdfplumber, re, psycopg2

BOOK_BOUNDS = [(1,96,'kursbuch'), (97,178,'arbeitsbuch'), (179,215,'wortschatz')]
LEKTION_RE  = re.compile(r'^\s*([1-7])\s+[A-ZÄÖÜ]')
SCHRITT_RE  = re.compile(r'\b([A-E])\d\b')

def book_of(page): 
    return next(b for lo,hi,b in BOOK_BOUNDS if lo<=page<=hi)

with pdfplumber.open('9783191810801.pdf') as pdf:
    for i, pg in enumerate(pdf.pages, 1):
        text = pg.extract_text() or ''
        rec = dict(page=i, book=book_of(i),
                   lektion=detect_lektion(text, i),
                   schritt=detect_schritt(text),
                   raw_text=text,
                   audio_ref=(m.group() if (m:=re.search(r'Folge \d', text)) else None))
        insert_raw_block(rec)   # → staging.raw_blocks
```

**Bitiş kriteri:** Her sayfa en az 1 raw_block; %90+ blok lektion+schritt etiketli; görsel sayfalar rasterlenmiş.

---

## 3. KATMAN 2 — STRUCTURE

**Girdi:** `staging.raw_blocks`
**Çıktı:** `staging.skeletons` (metin taşımaz — sadece şema)

### Sınıflandırma kural tablosu (ölçülmüş tetikleyicilerden)
```python
TRIGGERS = {
  'matching':   [r'Ordnen Sie zu', r'Verbinden Sie', r'Wer ist das'],
  'fill_blank': [r'Ergänzen Sie',  r'Schreiben Sie',  r'Notieren Sie', r'…'],
  'listening':  [r'Hören Sie', r'Satzmelodie', r'Wortakzent', r'Phonetik',
                 r'sprechen Sie nach'],
  'quiz':       [r'Was ist richtig', r'kreuzen Sie an', r'Richtig oder falsch'],
  'speaking':   [r'Sprechen Sie mit', r'Ihrer Partner', r'im Kurs'],
}
```

### Parametre çıkarımı (mekanik başına — metin değil, sayı/yapı çıkar)
| Mekanik | Çıkarılan parametre | Nasıl |
|---|---|---|
| matching | `pairs` (çift sayısı) | Sol+sağ liste öğe sayısı, `\|` ayraçlı listeler |
| fill_blank | `blanks`, `grammar_topic` | `…` ve `_____` sayısı; yakın ÜG kodu |
| listening | `audio_ref`, `sub_type` | Folge no; kreuzen/notieren alt-tipi |
| quiz | `options`, `format` | A/B/C/D kolonları; MC vs true-false |
| speaking | `scenario`, `roles` | Fokus başlığı, diyalog rolleri |

### Şema
```sql
CREATE TABLE staging.skeletons (
  id            TEXT PRIMARY KEY,     -- 'L3_C2'
  lektion       INT,
  schritt       TEXT,
  mechanic      TEXT,                 -- 5 mekanikten biri
  grammar_topic TEXT,                 -- 'Plural der Nomen' (ÜG kodundan map)
  vocab_domain  TEXT,                 -- 'Lebensmittel' (Lektion temasından)
  params        JSONB,                -- {"pairs":5} vb.
  source_page   INT,
  needs_audio   BOOL,
  needs_image   BOOL
);
```

### Hibrit sınıflandırma
1. **Kural geçişi:** TRIGGERS regex — tek net eşleşme varsa etiketle.
2. **Belirsizler** (0 veya 2+ eşleşme) → Claude API few-shot:
```
System: Alıştırma tipini sınıflandır. Sadece şu etiketlerden birini döndür:
        matching|fill_blank|listening|quiz|speaking
User: "<blok metni>"
```
3. **ÜG kodu → gramer_konu** eşlemesi (17 kod için sabit tablo):
```python
UG_MAP = {'ÜG5.01':'Verbkonjugation', 'ÜG10.01':'Aussage',
          'ÜG10.03':'W-Frage', 'ÜG2.01':'Possessivartikel', ...}
```

**Bitiş kriteri:** Her skeleton 5 mekanikten birine bağlı, gramer+kelime-alan etiketli, **hiç telifli metin taşımıyor.**

---

## 4. KATMAN 3 — GENERATE

**Girdi:** `staging.skeletons`
**Çıktı:** `prod.content_items` (uygulamanın render ettiği)

Mekanik başına bir generator. Her biri: skeleton parametrelerini alır → Claude API ile özgün içerik → JSON şema doğrula → TTS gerekiyorsa ses üret.

### 4.1 matching (eşleştirme)
**Prompt:**
```
System: A1 Almanca öğretmenisin (de-DE). SADECE JSON döndür, açıklama yok.
User: {pairs} çiftlik eşleştirme üret.
      Gramer: {grammar_topic}. Kelime alanı: {vocab_domain}. Seviye: A1.
      Format: {"left":[...], "right":[...], "solution":{sol:sağ}}
```
**Payload şeması:**
```json
{ "left": ["der Apfel","das Ei","die Banane"],
  "right": ["Äpfel","Eier","Bananen"],
  "solution": {"der Apfel":"Äpfel","das Ei":"Eier","die Banane":"Bananen"} }
```
**Değerlendirme:** kullanıcının eşleşmesi == solution (tam eşleşme, kısmi puan opsiyonel).

### 4.2 fill_blank (boşluk doldurma)
**Prompt:**
```
User: {blanks} boşluklu cümle(ler). Gramer: {grammar_topic}. Alan: {vocab_domain}.
      Her boşluk için doğru cevap + 0-2 çeldirici. A1.
      Format: {"sentence":"Ich ___ aus der Schweiz.", "blanks":[{"answer":"komme","hints":["kommt","kommen"]}]}
```
**Payload:**
```json
{ "text": "Wir ___ zehn ___ .",
  "blanks": [ {"id":1,"answer":"kaufen","alt":["kauft"]},
              {"id":2,"answer":"Eier","alt":["Ei"]} ] }
```
**Değerlendirme:** normalize (küçük harf, trim) sonra `answer` veya `alt` içinde mi.

### 4.3 listening (dinleme/telaffuz)
**Akış:** Generate metin → TTS (`de-DE` / hedefe göre `de-CH`) → audio URL → soru üret.
**Prompt (soru):**
```
User: Kısa A1 diyalog (2-4 replik). Alan: {vocab_domain}. Sonra 2 anlama sorusu (MC).
      Format: {"dialog":[...], "audio_text":"...", "questions":[{"q":"...","options":[...],"answer":0}]}
```
**Payload:**
```json
{ "audio_url": "s3://.../L1_folge1.mp3",
  "transcript_hidden": true,
  "questions": [ {"q":"Woher kommt Lili?","options":["Polen","Schweiz","Italien"],"answer":1} ] }
```
**TTS:** Azure `de-DE-KatjaNeural` veya Google `de-DE-Wavenet`. Telaffuz alıştırmaları için tek kelime + IPA opsiyonel.

### 4.4 quiz (Test / Prüfungsaufgabe)
**Prompt:**
```
User: {options} seçenekli {format} soru. Gramer: {grammar_topic}. A1.
      Format: {"question":"...","options":[...],"answer":<idx>,"explanation":"..."}
```
**Payload:**
```json
{ "question": "Was ist richtig?",
  "options": ["Ich komme aus der Schweiz.","Ich kommen aus Schweiz.","..."],
  "answer": 0, "explanation": "1. Sg. konjugasyon: komme." }
```

### 4.5 speaking (AI konuşma partneri)
**Runtime'da** çalışır (önceden üretilmez). Skeleton → sistem promptu şablonu:
```
System: Sen {scenario} senaryosunda A1 Almanca konuşma partnerisin.
        Rol: {role}. Kullanıcının seviyesi A1 — basit cümle, yavaş, düzelt.
        Hedef gramer: {grammar_topic}. Kısa cevap ver, kullanıcıyı konuştur.
```
Değerlendirme: konuşma sonunda ikinci Claude çağrısı → rubrik (gramer, kelime, hedefe ulaşma) puanı.

### Kalite kapısı (her mekanik için zorunlu)
Üretilen her içerik ikinci bir Claude çağrısından geçer:
```
System: A1 Almanca içerik denetçisisin. Şunu kontrol et: (1) gramer doğru mu,
        (2) A1 seviyesinde mi, (3) çözüm anahtarı tutarlı mı, (4) İsviçre değil
        standart Almanca mı (hedef de-DE ise). JSON: {"pass":bool,"issues":[...]}
```
`pass=false` → yeniden üret (max 2 deneme), sonra elle-review kuyruğuna.

### prod şeması
```sql
CREATE TABLE prod.content_items (
  id            TEXT PRIMARY KEY,
  skeleton_id   TEXT,
  mechanic      TEXT,
  cefr          TEXT DEFAULT 'A1',
  grammar_topic TEXT,
  vocab_domain  TEXT,
  payload       JSONB,       -- render verisi
  solution      JSONB,       -- değerlendirme anahtarı
  audio_url     TEXT,
  quality_pass  BOOL,
  reviewed      BOOL DEFAULT false,   -- Busra QA onayı
  generated_at  TIMESTAMPTZ DEFAULT now()
);
```

---

## 5. VERİ MODELİ (tam)

```sql
-- Referans/telifsiz
CREATE TABLE prod.lektionen (
  id INT PRIMARY KEY, nummer INT, titel TEXT, thema TEXT, grammar_focus TEXT[]);

CREATE TABLE prod.vocab (
  id BIGSERIAL PRIMARY KEY, lektion_id INT,
  artikel TEXT, wort TEXT, plural TEXT, wortart TEXT,
  beispiel TEXT, uebersetzung_tr TEXT);   -- Lernwortschatz'tan parse

-- Staging (telifli, izole)
-- staging.raw_blocks, staging.skeletons  (yukarıda)

-- Prod içerik
-- prod.content_items  (yukarıda)

-- Kullanıcı ilerlemesi (uygulama tarafı)
CREATE TABLE prod.user_progress (
  user_id UUID, content_id TEXT, correct BOOL,
  attempts INT, last_seen TIMESTAMPTZ);
```

**vocab parse regex (Lernwortschatz):**
```python
# "das Bild, -er   Sehen Sie die Bilder an."
VOCAB_RE = re.compile(
  r'^(der|die|das)?\s*([A-ZÄÖÜ][\wäöüß·]+),?\s*([¨\-\w]+)?\s{2,}(.+)$')
# → artikel, wort, plural-eki, beispiel
```

---

## 6. UYGULAMA SIRASI

| Faz | İş | Çıktı | Bitiş kriteri |
|---|---|---|---|
| **P0** | Extract + kitap/Lektion sınırları + 1 Lektion (L3 Einkaufen) pilot | staging.raw_blocks (L3) | L3'ün tüm sayfaları bloklanmış, etiketli |
| **P1** | vocab parse (Lernwortschatz L3) + gramer ÜG-map | prod.vocab (L3), UG_MAP | L3 kelimeleri artikel+çoğul ayrık |
| **P2** | Structure sınıflandırıcı (kural+LLM hibrit) | staging.skeletons (L3) | L3'ün her alıştırması etiketli, telifsiz |
| **P3** | Generate: matching + fill_blank + kalite kapısı | prod.content_items (L3, 2 mekanik) | L3'te oynanabilir 2 mekanik |
| **P4** | TTS + listening mekaniği | audio + content (L3) | Sesli dinleme çalışıyor |
| **P5** | quiz + speaking (runtime AI partner) | 4 mekanik + konuşma tam | L3 uçtan uca 4 mekanik |
| **P6** | 7 Lektion'a batch ölçekle | tam veri seti | 7 Lektion prod'da |
| **P7** | Busra QA arayüzü (reviewed flag) | onaylı içerik | reviewed=true akışı |

**Neden L3 pilot?** Einkaufen — hem matching (yiyecek→resim), hem fill_blank (Plural), hem quiz içeriyor; 4 mekaniği de test eder. En yoğun mekanik çeşitliliği bu Lektion'da.

---

## 7. RİSK REGISTER

| Risk | Etki | Azaltma |
|---|---|---|
| Ham metin prod'a sızar | Telif ihlali | CI statik kontrol: `raw_text`→`prod` import yasak |
| Görsel matching (Suchbild) otomatikleşmez | İçerik eksik | P5+'a ertele; elle veya AI-görsel üretimi |
| de-CH vs de-DE karışması | Yanlış öğretim | Kalite kapısında dil normalleştirme kontrolü |
| LLM sınıflandırma hatası | Yanlış mekanik | 2+ belirsizde elle-review kuyruğu |
| TTS de-CH aksanı yok | Ses tutarsızlığı | de-DE standart voice, hedef kitle Almanya |
| Üretilen içerik A1 üstü | Seviye kayması | Kalite kapısı CEFR kontrolü + kelime beyaz liste (vocab tablosu) |

---

## 8. TECH STACK (memory ile hizalı)
- **Extract/Structure/Generate:** Python — pdfplumber, pydantic (şema doğrulama), anthropic SDK
- **DB:** PostgreSQL — staging + prod şema ayrımı, jsonb payload
- **API:** FastAPI — content servis endpoint'leri
- **Frontend:** mevcut React MVP — payload/solution şemasına göre render
- **TTS:** Azure Speech veya Google Cloud TTS (de-DE)
- **Orkestrasyon:** Claude Code — bu doküman + CLAUDE.md ile besle
- **LLM router:** üretim için API (Sonnet), yüksek hacim sınıflandırma için lokal (Qwen2.5) opsiyonu — mevcut multi-site altyapınla aynı desen

---

## 9. İLK KOMUT (Claude Code için)
```
P0'ı uygula: 9783191810801.pdf'ten Lektion 3 (Einkaufen, ~s34-45 kursbuch
+ ilgili Arbeitsbuch sayfaları) için staging.raw_blocks tablosunu doldur.
pdfplumber kullan, book/lektion/schritt etiketle, görsel sayfaları rasterle.
Kod bu dokümandaki Katman 1 şemasına uysun.
```
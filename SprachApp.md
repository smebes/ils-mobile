# SprachApp — İçerik Pipeline Yol Haritası
**Kaynak:** Schritte Plus Neu 1 (Schweiz), A1 — 215 sayfa, 7 Lektion
**Hedef:** PDF → yapılandırılmış veri (JSON/PostgreSQL) → uygulamanın tükettiği 4 mekanik

---

## 0. Telif Notu (kırmızı çizgi)
PDF'ten **birebir çıkarım = telif ihlali** (Hueber yayınevi). Karar: **hibrit**.
- **Otomatik çıkarım** → sadece *iskelet/şema* için: hangi Lektion'da hangi mekanik, kaç alıştırma, gramer başlıkları, kelime listeleri (fikirler telifsiz, ifade telifli).
- **AI ile yeniden üretim** → asıl *içerik* (cümleler, diyaloglar, örnekler) Claude API ile özgün üretilir; kitabın *mekaniği* örnek alınır, metni değil.
- Kural: Kitaptan çıkan ham metin **staging** katmanında kalır, prod DB'ye asla girmez. Prod'a sadece üretilmiş özgün içerik yazılır.

---

## Mimari (3 katman)

```
[PDF] ──> Katman 1: EXTRACT ──> raw_blocks (staging)
                                     │
                                     ▼
              Katman 2: STRUCTURE ──> exercise_skeletons (şema + tip etiketi)
                                     │
                                     ▼
              Katman 3: GENERATE ──> content_items (özgün, prod-ready JSON)
                                     │
                                     ▼
                              PostgreSQL ──> FastAPI ──> React MVP
```

---

## Katman 1 — EXTRACT (PDF → ham bloklar)

**Amaç:** Sayfaları makine-okunur bloklara ayır. İçeriği yorumlama, sadece topla.

**Araçlar:** `pdfplumber` (layout + koordinat), `pdftoppm` (görsel gerektiren sayfalar için raster).

**Çıktı şeması — `raw_blocks`:**
```json
{
  "page": 40, "lektion": 3, "schritt": "C",
  "block_type": "text|image|table",
  "bbox": [x0,y0,x1,y1],
  "text": "...", "image_path": "raster/p40_img2.png"
}
```

**Görevler:**
1. `pdfplumber` ile sayfa başına text+bbox çıkar.
2. Lektion/Schritt sınırlarını tespit et (regex: `^\d\s`, `Schritt A–E`, sayfa üstü numaralar).
3. Görsel-ağırlıklı sayfaları (Suchbild, Comic, resimli eşleştirme) `pdftoppm -r 150` ile rasterle → ayrı dizin.
4. Ses referanslarını yakala (`Hören Sie`, `Folge X`) → audio-gerektiren blok işareti.

**Bitiş kriteri:** 215 sayfa → ~N blok, her blok Lektion+Schritt etiketli.

---

## Katman 2 — STRUCTURE (ham blok → alıştırma iskeleti)

**Amaç:** Her bloğu 4 hedef mekanikten birine sınıflandır + parametrelerini çıkar. **İçerik değil, tip + yapı.**

**Sınıflandırma sinyalleri (kitaptan tespit edildi):**

| Mekanik | Tetikleyici ifadeler | Çıkarılacak parametre |
|---|---|---|
| **Eşleştirme** | "Ordnen Sie zu", "Verbinden Sie", "Wer ist das?" | sol liste, sağ liste, doğru eşleşme sayısı |
| **Boşluk doldurma** | "Ergänzen Sie", "…" yer tutucular, çoğul tabloları | boşluk sayısı, gramer konusu (Plural, Konjugation) |
| **Dinleme/Telaffuz** | "Hören Sie", "Satzmelodie", "Wortakzent", "Phonetik" | audio-id, soru tipi (kreuzen an / notieren) |
| **Quiz/Test** | "Was ist richtig?", "kreuzen Sie an", "Test", "Prüfungsaufgabe" | seçenek sayısı, format (MC / true-false) |
| **(AI konuşma)** | "Sprechen Sie mit Ihrer Partnerin", "Fokus" | senaryo/rol, hedef gramer |

**Çıktı şeması — `exercise_skeletons`:**
```json
{
  "id": "L3_C2", "lektion": 3, "schritt": "C",
  "mechanic": "matching|fill_blank|listening|quiz|speaking",
  "grammar_topic": "Plural der Nomen",
  "vocab_domain": "Einkaufen / Lebensmittel",
  "params": { "pairs": 5, "options_per_q": 4 },
  "source_page": 40,
  "needs_audio": true, "needs_image": true
}
```

**Görevler:**
1. Kural-tabanlı sınıflandırıcı (regex + ifade sözlüğü) — ilk geçiş.
2. Belirsizleri Claude API'ye gönder → tek tip etiketi döndür (few-shot).
3. Gramer konusu + kelime alanını eşle (Lernwortschatz sayfalarından — s179+).

**Bitiş kriteri:** Her iskelet 5 mekanikten birine bağlı, gramer/kelime etiketli. **Hiç telifli metin taşımıyor.**

---

## Katman 3 — GENERATE (iskelet → özgün içerik)

**Amaç:** İskeletin parametrelerini kullanarak Claude API ile **sıfırdan özgün** alıştırma üret. Kitabın metni değil, aynı öğretim hedefi.

**Prompt kalıbı (mekanik başına):**
- Girdi: `mechanic`, `grammar_topic`, `vocab_domain`, `params`, CEFR seviyesi (A1).
- Çıktı: katı JSON (uygulamanın render şeması).

**Örnek — matching üretimi:**
```
System: A1 Almanca öğretmenisin. Sadece JSON döndür.
User: 5 çiftlik eşleştirme. Konu: Plural der Nomen.
      Alan: Lebensmittel. A1 seviyesi. Çözüm anahtarı dahil.
→ { "left": ["Apfel","Ei",...], "right": ["Äpfel","Eier",...],
    "solution": {"Apfel":"Äpfel",...} }
```

**Çıktı şeması — `content_items` (prod, uygulama tüketir):**
```json
{
  "id": "L3_C2_gen", "skeleton_id": "L3_C2",
  "mechanic": "matching", "cefr": "A1",
  "grammar_topic": "Plural der Nomen",
  "payload": { /* mekaniğe özel render verisi */ },
  "solution": { /* değerlendirme anahtarı */ },
  "audio": { "tts_text": "...", "voice": "de-DE" },
  "generated_at": "...", "reviewed": false
}
```

**Görevler:**
1. Mekanik başına generator fonksiyonu + JSON şema doğrulama (pydantic).
2. **Kalite kapısı:** üretilen içeriği ikinci bir Claude çağrısıyla doğrula (gramer doğru mu, A1 seviyesinde mi, çözüm tutarlı mı).
3. Ses gereken maddeler → TTS (Azure/Google `de-DE` veya `de-CH`) → audio dosyası + URL.
4. `reviewed=false` işaretiyle prod'a yaz; eşin (Busra) QA onayında `true`.

---

## Veri Modeli (PostgreSQL)

```
lektionen (id, nummer, titel, thema)
skeletons (id, lektion_id, schritt, mechanic, grammar_topic, vocab_domain, params_jsonb, source_page)
content_items (id, skeleton_id, mechanic, cefr, payload_jsonb, solution_jsonb, audio_url, reviewed, generated_at)
vocab (id, lektion_id, wort, artikel, plural, uebersetzung)
```
- `raw_blocks` ayrı **staging şemasında** (prod'dan izole, telif hijyeni).

---

## Uygulama Sırası (fazlar)

| Faz | İş | Çıktı | Süre (tahmini) |
|---|---|---|---|
| **P0** | Extract altyapısı + 1 Lektion pilot | raw_blocks (L1) | 2–3 gün |
| **P1** | Structure sınıflandırıcı + şema | skeletons (L1) | 3–4 gün |
| **P2** | Generate + kalite kapısı (2 mekanik: matching, fill_blank) | content_items (L1) | 4–5 gün |
| **P3** | TTS entegrasyonu (listening/telaffuz) | audio + content | 2–3 gün |
| **P4** | Quiz motoru mekaniği + AI konuşma partneri | 4 mekanik tam | 4–5 gün |
| **P5** | 7 Lektion'a ölçekle + batch pipeline | tam veri seti | 3–4 gün |

**Not:** P0–P2 tek Lektion'da uçtan uca çalışınca pipeline "kanıtlanmış" olur; gerisi tekrar.

---

## Kritik Riskler
1. **Telif:** Ham metnin prod'a sızması. → Staging izolasyonu + kod-review kuralı.
2. **Sınıflandırma hatası:** Karışık düzenli sayfalar. → Kural + LLM hibrit, belirsizde LLM.
3. **Görsel mekanikler** (Suchbild, Comic): otomatikleştirmesi zor. → P4+'a ertele veya elle üret.
4. **de-CH vs de-DE:** Kitap İsviçre versiyonu ("Grüezi", "ss" yerine "ß" yok). Hedef kitlene göre normalleştir.

---

## Tech Stack (memory ile hizalı)
- Extract/Structure/Generate: **Python** (pdfplumber, pydantic, anthropic SDK)
- DB: **PostgreSQL** (jsonb payloadlar)
- API: **FastAPI**
- Frontend: mevcut **React MVP**
- Orkestrasyon: **Claude Code** (bu doküman + CLAUDE.md ile besle)
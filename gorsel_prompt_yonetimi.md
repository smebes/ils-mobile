# SprachApp — Görsel Prompt Yönetimi (GPT / gpt-image-1)

> **Amaç:** Uygulamadaki tüm görselleri GPT ile **tutarlı bir görsel dilde** üretmek. İlk fazda manuel: aşağıdaki promptları ChatGPT'ye yapıştır, çıkan PNG'yi belirtilen **dosya adıyla** kaydet, WebP'e çevir (§8). Bu doküman "tek doğruluk kaynağı"dır — hangi görsel, hangi prompt, hangi isim, hangi Lektion.

İlgili: `Project.md` §5 (görsel pipeline), §11 (dağıtım), `sprachapp_pipeline_detayli.md`.

---

## 0. İKİ TÜR GÖRSEL (KARAR)

Her görseli GPT'ye tek tek ürettirmiyoruz. İki ayrı hat var:

| Tür | Ne | Nasıl üretilir | Neden |
|---|---|---|---|
| **A · Foto sahneler** | Foto-Hörgeschichte, diyalog/listening ortamları, kapak | **GPT — fotogerçekçi** (kitaptaki gibi gerçek fotoğraf hissi) | Kompozisyon özgün + insan/ortam gerekiyor; SVG olmaz |
| **B · Vocab ikonları** | Tek nesneler (Apfel, Banane, Ei, Tisch…) | **SVG** (repoda/ikon setiyle) — GPT'ye gerek yok | Basit nesne; vektör minik boyutlu, her ekranda net, renk teması koda bağlı, tek tek üretim derdi yok |

**Sonuç:** GPT'yi sadece **A (foto sahneler)** için kullan. Vocab (**B**) SVG olarak gelir → `assets/vocab/*.svg` (örnek set üretildi: `apfel, banane, ei, brot, milch, kaese`; önizleme `assets/vocab/preview.html`).

- Track A promptları: **§9-A** (fotogerçekçi sahne promptları).
- Track B (vocab SVG) yönetimi: **§9-B**.
- Aşağıdaki §2 "flat vector" stili artık **kullanılmıyor** (arşiv). Sahneler fotogerçekçi, vocab SVG.

---

## 1. Altın Kural: Tutarlılık

Bir dil uygulamasında 500+ görsel olur. Hepsi **aynı stilde** görünmezse app amatör durur. Tutarlılığı 3 şey sağlar:

1. **Master Stil Promptu** (§2) — her promptun sonuna aynen eklenir.
2. **Karakter Kanonu** (§4) — tekrar eden kişiler her sahnede aynı tarif edilir.
3. **Referans görsel yöntemi** (§3) — iyi bir görsel yakaladıktan sonra onu referans verip "bu stille üret" demek.

---

## 2. MASTER STİL PROMPTU (her prompta eklenir)

Aşağıdaki bloğu **her görsel promptunun sonuna** kelimesi kelimesine yapıştır:

```
STYLE: flat modern vector illustration, clean geometric shapes with soft
rounded corners, friendly and warm, cohesive limited palette (warm cream
background #FAF3E7, teal #2A9D8F, coral #E76F51, mustard #E9C46A, deep navy
#264653 for outlines), consistent medium line weight, soft long shadows,
subtle paper grain, gentle even lighting, centered balanced composition,
generous padding, approachable and calm mood.
NEGATIVE: no text, no letters, no numbers, no words, no logos, no watermark,
no photorealism, no 3D render, no busy background, no harsh gradients.
```

> Not: GPT bazen görsele yazı ekler. "no text/letters" negatifine rağmen kaçarsa "remove all text and letters, keep it wordless" diye düzelttir.

**Arka plan kuralı:** Vocab/flashcard görsellerinde arka plan **düz krem (#FAF3E7)**. Sahnelerde açık, sade ortam. Bu, app'te kartların birbirine uymasını sağlar.

---

## 3. GPT Kullanım Notları (manuel faz)

- **Model:** ChatGPT görsel üretimi (gpt-image-1). Prompt = [KONU tarifi] + [MASTER STİL].
- **En/boy oranı (aspect ratio):**
  - Vocab / flashcard → **1:1** (kare)
  - Sahne (scene) → **3:2** (yatay)
  - Kapak (cover) / hero → **16:9** veya **3:4** (dikey mobil hero)
- **Çözünürlük:** GPT büyük üretir; sorun değil, §8'de küçültüp WebP yapıyoruz. Vocab için 1024², sahne için 1536×1024 yeterli.
- **Tutarlılık için:** İyi bir vocab görseli çıkınca, sonrakileri üretirken **o görseli referans yükle** ve "generate in the exact same flat vector style as this attached image, same palette, same background" de. Karakterler için de kanon görselini referans ver.
- **Batch mantığı:** Aynı Lektion'un vocab'larını arka arkaya, aynı sohbette üret → stil kayması azalır.

---

## 4. KARAKTER KANONU (tekrar eden kişiler)

Sahne ve diyalog görsellerinde bu kişiler döner. Her sahne promptunda ilgili kişiyi **aynen** şu cümlelerle tarif et (isim yeterli değil, GPT hatırlamaz):

| ID | İsim | Sabit tarif (prompta yapıştır) |
|---|---|---|
| `mara` | Mara | young woman, ~28, shoulder-length wavy auburn hair, olive skin, warm smile, teal jacket over white shirt |
| `tarek` | Tarek | man, ~32, short black hair, short beard, brown skin, navy sweater |
| `frau_weber` | Frau Weber | woman, ~62, silver bob haircut, round glasses, coral cardigan, kind expression |
| `leo` | Leo | boy, ~8, curly blond hair, mustard t-shirt, cheerful |
| `sofia` | Sofia | girl, ~10, straight brown hair in ponytail, teal dress, curious |
| `herr_koch` | Herr Koch | man, ~45, bald with glasses, white apron (shopkeeper), friendly |

> Bu kişiler **özgün**dür (kitaptaki karakterler değil). Telif açısından güvenli.

---

## 5. ADLANDIRMA KURALI

```
l{lektion}_{tip}_{slug}.webp
```
- `lektion` : 1–7 (referans/genel görseller için `gen`)
- `tip` : `cover` | `vocab` | `scene` | `char` | `grammar` | `ui`
- `slug` : küçük harf, Almanca kelime sadeleştirilmiş (ä→ae, ö→oe, ü→ue, ß→ss), boşluk→`_`

Örnekler:
```
l3_cover.webp
l3_vocab_apfel.webp
l3_scene_supermarkt.webp
l3_char_herr_koch.webp
l3_grammar_plural_apfel.webp
gen_ui_mascot.webp
```

Master (orijinal PNG) aynı isimle `masters/` altında: `masters/l3_vocab_apfel.png`.

---

## 6. GÖRSEL KATEGORİLERİ

| Tip | Ne için | Oran | Arka plan |
|---|---|---|---|
| `vocab` | Tek kelime/nesne (flashcard, matching) | 1:1 | düz krem |
| `scene` | Diyalog/Foto-Hörgeschichte ortamı, listening | 3:2 | sade ortam |
| `char` | Karakter portresi (speaking partner avatarı) | 1:1 | düz renk |
| `cover` | Lektion kapağı / hero | 16:9 veya 3:4 | tematik |
| `grammar` | Gramer görselleştirme (tekil/çoğul, yön okları) | 1:1 veya 3:2 | düz krem |
| `ui` | Maskot, rozet, boş-durum ikonları | 1:1 | şeffaf/düz |

---

## 7. YENİDEN KULLANILABİLİR PROMPT ŞABLONU

Vocab için tek şablon; sadece `{SUBJECT}` değişir:

```
A single {SUBJECT}, centered, front view, isolated as a flashcard object,
generous empty padding around it.
STYLE: flat modern vector illustration, clean geometric shapes with soft
rounded corners, friendly and warm, cohesive limited palette (warm cream
background #FAF3E7, teal #2A9D8F, coral #E76F51, mustard #E9C46A, deep navy
#264653 for outlines), consistent medium line weight, soft long shadows,
subtle paper grain, gentle even lighting, centered balanced composition,
generous padding, approachable and calm mood.
NEGATIVE: no text, no letters, no numbers, no words, no logos, no watermark,
no photorealism, no 3D render, no busy background, no harsh gradients.
```

Sahne için şablon (`{SCENE}` + `{CHARACTERS}` değişir):

```
Scene: {SCENE}. Characters present: {CHARACTERS}. Natural friendly interaction,
clear readable composition, wordless.
STYLE: [MASTER STİL bloğu §2]
```

---

## 8. PNG → WebP/AVIF (dönüştürme ve dağıtım)

**Önerilen yöntem (uzun vade):** Master PNG'yi Cloudflare R2'ye at → **Cloudflare Images** cihaza göre AVIF/WebP + boyut *on-the-fly* versin. Manuel çevirme derdi biter, tek master tutarsın (bkz. `Project.md` §11).

**İlk faz (manuel, CDN yokken):** yerel toplu dönüştürme — `sharp` ile. `tools/img_to_webp.mjs`:

```js
// Kullanım: node tools/img_to_webp.mjs masters/ public/img/
// Her PNG'den: <ad>.webp (768px) + <ad>@2x.webp (1280px) + <ad>.avif üretir.
import sharp from "sharp";
import { readdir, mkdir } from "node:fs/promises";
import path from "node:path";

const [,, inDir = "masters", outDir = "public/img"] = process.argv;
await mkdir(outDir, { recursive: true });
const files = (await readdir(inDir)).filter(f => /\.(png|jpe?g)$/i.test(f));

for (const f of files) {
  const name = path.parse(f).name;
  const src = path.join(inDir, f);
  await sharp(src).resize({ width: 768 }).webp({ quality: 80 })
    .toFile(path.join(outDir, `${name}.webp`));
  await sharp(src).resize({ width: 1280 }).webp({ quality: 80 })
    .toFile(path.join(outDir, `${name}@2x.webp`));
  await sharp(src).resize({ width: 768 }).avif({ quality: 55 })
    .toFile(path.join(outDir, `${name}.avif`));
  console.log("✓", name);
}
```
Kurulum: `npm i sharp`. (CLI alternatifi: `cwebp -q 80 in.png -o out.webp`.)

**Boyut disiplini:** vocab 512–768 px, sahne/kapak 1024–1280 px yeter. Master'ı gereksiz büyük tutma.

---

## 9-A. FOTO SAHNE PROMPTLARI (GPT, fotogerçekçi)

Kitaptaki gibi gerçek fotoğraf hissi. Her sahne promptunun sonuna bu **foto stil bloğunu** ekle:

```
STYLE: realistic photograph, natural soft daylight, shallow depth of field,
authentic everyday adult language-school / everyday-life setting in Germany,
diverse friendly adults, candid documentary feel, neutral modern interior,
high detail, no text, no captions, no watermark, no on-image writing.
```

**Karakter yüz tutarlılığı uyarısı:** GPT foto modunda aynı yüzü farklı sahnelerde birebir tutamaz. Çözüm: (a) iyi bir kişi görseli çıkınca onu **referans yükleyip** "same person, same face" de; ya da (b) her sahnede bağımsız kişiler kullan (çoğu egzersiz için sorun değil) — karakter sürekliliğini **ses** (ElevenLabs sabit voice) taşır.

**Lektion 3 — foto sahneler:**
`l3_scene_supermarkt.png` (yatay 3:2):
```
A woman shopping in a bright modern supermarket aisle, holding a shopping
basket, colorful groceries on shelves, shopping cart nearby.
STYLE: [foto blok ↑]
```
`l3_scene_an_der_kasse.png`:
```
A customer paying at a supermarket checkout counter, a friendly cashier
scanning groceries, everyday moment.
STYLE: [foto blok ↑]
```
`l3_scene_wochenmarkt.png`:
```
An outdoor farmers market stall with fresh fruit and vegetables in crates,
a vendor and a customer talking.
STYLE: [foto blok ↑]
```
`l3_scene_baeckerei.png`:
```
A cozy bakery counter with fresh bread and pastries, a customer choosing.
STYLE: [foto blok ↑]
```
`l3_cover.png` (16:9): supermarket alışveriş sahnesi, sıcak/davetkâr → yukarıdaki `supermarkt` promptunu 16:9 iste.

> Diğer Lektion foto sahneleri: §9 (aşağıdaki eski katalog) sahne satırlarını al, "STYLE: [§2]" yerine yukarıdaki **foto bloğunu** koy.

---

## 9-B. VOCAB (SVG — GPT yok)

Vocab görselleri `assets/vocab/*.svg` altında. İki yol:

1. **Özel SVG (marka):** Uygulama paletinde elle çizilmiş (örnek set üretildi: `l3_vocab_apfel/banane/ei/brot/milch/kaese.svg`). En "bizim" görünüm; ama her nesneyi çizmek emek.
2. **Açık ikon seti (hız):** OpenMoji (CC BY-SA) / Twemoji (CC-BY) gibi setlerden Almanca kelime→ikon eşlemesi. Anında, tutarlı, ücretsiz; tüm 7 Lektion'u kapsar. Atıf (attribution) gerekir.

**Adlandırma aynı:** `l{N}_vocab_{slug}.svg`. Kelime listeleri için aşağıdaki eski §9 tablolarındaki `slug`'ları kullan (sadece uzantı `.svg`).

**App'te kullanım:** `expo-image`/`<img>` SVG'yi doğrudan render eder; WebP'e çevirmeye gerek yok (vektör zaten minik). CDN'e ham SVG konur.

---

## 9. (ARŞİV) FLAT-VECTOR PROMPT KATALOĞU

> Not: Aşağısı ilk (flat-vector) yaklaşımın kataloğu. Artık sahneler **fotogerçekçi** (§9-A), vocab **SVG** (§9-B). Bu bölümü sadece **slug/kelime listesi** referansı olarak kullan.

Her Lektion için: kapak + sahneler + vocab tablosu. Vocab satırlarında sadece `{SUBJECT}` verilir; §7 şablonuna koyup kullan. **Pilot: Lektion 3.**

### Lektion 1 — Guten Tag / Tanışma
**Kapak** `l1_cover` (16:9):
```
Two friendly people meeting and waving hello at a bright community center
entrance, welcoming atmosphere. Characters: [mara §4], [tarek §4].
STYLE: [§2]
```
**Sahneler:**
- `l1_scene_begruessung` (3:2) — "people greeting each other, handshake and wave, cafe corner. Characters: [mara], [frau_weber §4]."
- `l1_scene_vorstellung` (3:2) — "a person introducing themselves to a small group in a language class. Characters: [tarek]."

**Vocab (`{SUBJECT}`):** 
| slug | SUBJECT |
|---|---|
| `l1_vocab_hand` | a waving hand gesture, greeting |
| `l1_vocab_name` | a simple name tag badge (blank, no text) |
| `l1_vocab_land` | a small globe / world map marker |
| `l1_vocab_telefon` | a modern smartphone |
| `l1_vocab_kaffee` | a cup of coffee |

### Lektion 2 — Meine Familie
**Kapak** `l2_cover` (16:9): "a warm multi-generational family together on a sofa, cozy living room. Characters: [mara], [frau_weber], [leo §4], [sofia §4]. STYLE: [§2]"
**Sahneler:** `l2_scene_wohnzimmer` (aile birlikte), `l2_scene_fotoalbum` (bir kişi fotoğraf albümü gösteriyor).
**Vocab:**
| slug | SUBJECT |
|---|---|
| `l2_vocab_familie` | a small group family icon (parents + two kids) |
| `l2_vocab_mutter` | a friendly mother figure, portrait |
| `l2_vocab_vater` | a friendly father figure, portrait |
| `l2_vocab_kind` | a happy child figure |
| `l2_vocab_haus` | a cozy small family house |

### Lektion 3 — Einkaufen (PİLOT — tam set)
**Kapak** `l3_cover` (16:9):
```
A cheerful grocery shopping scene at a bright supermarket aisle with baskets
of fresh food, shopping cart. Character: [mara §4] holding a shopping basket,
[herr_koch §4] the shopkeeper behind a counter.
STYLE: [§2]
```
**Sahneler (3:2):**
- `l3_scene_supermarkt` — "a bright supermarket aisle with shelves of colorful groceries, shopping cart in foreground. Character: [mara]."
- `l3_scene_wochenmarkt` — "an outdoor farmers market stall with fruit and vegetables in crates. Characters: [tarek §4] as customer, [herr_koch] as vendor."
- `l3_scene_baeckerei` — "a small bakery counter with bread and pastries. Character: [frau_weber §4]."
- `l3_scene_an_der_kasse` — "a supermarket checkout counter, customer paying. Characters: [mara], [herr_koch] as cashier."

**Gramer (Plural der Nomen):**
- `l3_grammar_plural_apfel` (3:2) — "left side one single apple, right side a group of several identical apples, clear visual contrast of singular vs plural, thin divider line in the middle. STYLE: [§2]"

**Vocab — Lebensmittel (`{SUBJECT}`, hepsi 1:1, arka plan krem):**
| slug | SUBJECT |
|---|---|
| `l3_vocab_apfel` | a single red apple |
| `l3_vocab_banane` | a single ripe banana |
| `l3_vocab_orange` | a single orange fruit |
| `l3_vocab_ei` | a single white egg |
| `l3_vocab_brot` | a loaf of bread |
| `l3_vocab_broetchen` | a bread roll |
| `l3_vocab_milch` | a carton of milk |
| `l3_vocab_kaese` | a wedge of cheese |
| `l3_vocab_butter` | a block of butter |
| `l3_vocab_tomate` | a single red tomato |
| `l3_vocab_kartoffel` | a single potato |
| `l3_vocab_gemuese` | an assortment of vegetables |
| `l3_vocab_obst` | an assortment of fruit |
| `l3_vocab_fleisch` | a cut of raw meat / steak |
| `l3_vocab_fisch` | a single fish |
| `l3_vocab_wurst` | a sausage |
| `l3_vocab_reis` | a bowl of rice |
| `l3_vocab_zucker` | a bag of sugar |
| `l3_vocab_salz` | a salt shaker |
| `l3_vocab_wasser` | a bottle of water |
| `l3_vocab_saft` | a glass/carton of juice |
| `l3_vocab_kaffee` | a bag of coffee beans |
| `l3_vocab_tee` | a box/cup of tea |
| `l3_vocab_einkaufswagen` | a shopping cart |
| `l3_vocab_einkaufskorb` | a shopping basket |
| `l3_vocab_geld` | euro coins and banknotes |

### Lektion 4 — Meine Wohnung
**Kapak** `l4_cover`: "a cozy modern apartment interior cross-section, furnished rooms. Character: [tarek §4]. STYLE: [§2]"
**Sahneler:** `l4_scene_wohnzimmer`, `l4_scene_kueche`, `l4_scene_schlafzimmer`.
**Vocab:**
| slug | SUBJECT |
|---|---|
| `l4_vocab_tisch` | a wooden table |
| `l4_vocab_stuhl` | a chair |
| `l4_vocab_bett` | a bed |
| `l4_vocab_sofa` | a sofa |
| `l4_vocab_lampe` | a table lamp |
| `l4_vocab_schrank` | a wardrobe/cupboard |
| `l4_vocab_fenster` | a window |
| `l4_vocab_tuer` | a door |

### Lektion 5 — Tagesabläufe (günlük rutin)
**Kapak** `l5_cover`: "a daily routine timeline, morning to night, sun and moon. Character: [sofia §4]. STYLE: [§2]"
**Sahneler:** `l5_scene_morgen` (kahvaltı), `l5_scene_arbeit`, `l5_scene_abend`.
**Vocab:**
| slug | SUBJECT |
|---|---|
| `l5_vocab_uhr` | a wall clock |
| `l5_vocab_wecker` | an alarm clock |
| `l5_vocab_bett_aufstehen` | a person getting out of bed |
| `l5_vocab_fruehstueck` | a breakfast plate |
| `l5_vocab_arbeit` | an office desk with laptop |
| `l5_vocab_schlafen` | a sleeping crescent moon with pillow |

### Lektion 6 — Freizeit (boş zaman)
**Kapak** `l6_cover`: "a group enjoying free time activities in a park, sports and music. Characters: [mara §4], [leo §4]. STYLE: [§2]"
**Sahneler:** `l6_scene_park`, `l6_scene_sport`, `l6_scene_musik`.
**Vocab:**
| slug | SUBJECT |
|---|---|
| `l6_vocab_fussball` | a soccer ball |
| `l6_vocab_fahrrad` | a bicycle |
| `l6_vocab_buch` | an open book |
| `l6_vocab_musik` | musical notes with headphones |
| `l6_vocab_kino` | a cinema/film clapperboard |
| `l6_vocab_schwimmen` | swimming goggles |

### Lektion 7 — Kinder und Schule
**Kapak** `l7_cover`: "a friendly classroom with children and a teacher, bright and encouraging. Characters: [sofia §4], [leo §4], [frau_weber §4]. STYLE: [§2]"
**Sahneler:** `l7_scene_klassenzimmer`, `l7_scene_schulweg`, `l7_scene_hausaufgaben`.
**Vocab:**
| slug | SUBJECT |
|---|---|
| `l7_vocab_schule` | a school building |
| `l7_vocab_lehrer` | a teacher figure at a board |
| `l7_vocab_schueler` | a pupil with backpack |
| `l7_vocab_buch_schule` | a stack of school books |
| `l7_vocab_stift` | a pencil |
| `l7_vocab_tafel` | a blank classroom board |

---

## 10. GENEL / UI GÖRSELLERİ
| slug | SUBJECT / not |
|---|---|
| `gen_ui_mascot` | a friendly simple owl mascot (dil öğrenme maskotu), 1:1, şeffaf zemin |
| `gen_ui_empty` | an empty-state illustration (boş kutu / sakin), 1:1 |
| `gen_ui_success` | a celebration illustration (konfeti, onay), 1:1 |
| `gen_ui_streak` | a flame/streak badge, 1:1 |

---

## 11. ÜRETİM TAKİP TABLOSU (checklist doldur)

Her görsel üretildikçe işaretle. (İstersen ayrı bir CSV/sheet'e taşı; `media_assets` tablosuna `slug` ile bağlanır.)

| slug | üretildi | WebP | R2/CDN | reviewed |
|---|---|---|---|---|
| l3_cover | ☐ | ☐ | ☐ | ☐ |
| l3_scene_supermarkt | ☐ | ☐ | ☐ | ☐ |
| l3_vocab_apfel | ☐ | ☐ | ☐ | ☐ |
| … | | | | |

---

## 12. KALİTE KONTROL CHECKLIST (her görsel için)
- [ ] Stil master palete uyuyor (krem zemin, aynı çizgi kalınlığı)
- [ ] Üzerinde **hiç yazı/harf yok**
- [ ] Nesne net, tanınır, A1 seviyesine uygun (belirsiz değil)
- [ ] Karakter varsa kanona uygun (§4)
- [ ] Doğru en/boy oranı ve isim
- [ ] WebP < ~120 KB (vocab), < ~250 KB (sahne)

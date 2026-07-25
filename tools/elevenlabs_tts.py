#!/usr/bin/env python3
"""
SprachApp — ElevenLabs seslendirme script'i.

Amaç: Tüm A1 Almanca diyaloglarını ANADİL Almanca, öğrenciye uygun YAVAŞ ve
AKICI bir tonda seslendirmek. Her konuşmacıya sabit bir ses (voice) atanır,
böylece diyaloglar tutarlı olur. İki hız üretebilir (yavaş + normal).

Kurulum:
    pip install -r tools/requirements.txt
    export ELEVENLABS_API_KEY="xi-..."

Kullanım:
    python tools/elevenlabs_tts.py \
        --input tools/dialogues.sample.json \
        --voices tools/voices.json \
        --out storage/audio \
        --speeds slow

    # iki hız birden (yavaş + normal):
    python tools/elevenlabs_tts.py --input ... --speeds slow,normal

    # sadece ne üretileceğini gör (API çağrısı yapmaz):
    python tools/elevenlabs_tts.py --input ... --dry-run

Girdi formatı (dialogues.json) örneği için: tools/dialogues.sample.json
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import sys
import time
from dataclasses import dataclass, field
from pathlib import Path

# ---------------------------------------------------------------------------
# Sabitler / varsayılanlar (A1 "uygulama ruhu": yavaş, net, akıcı)
# ---------------------------------------------------------------------------
DEFAULT_MODEL = "eleven_multilingual_v2"   # Almanca uzun-form için ideal
OUTPUT_FORMAT = "mp3_44100_128"

# ElevenLabs voice_settings — A1 öğrenci için ayarlandı.
#   stability yüksek  -> tutarlı, sakin, net anlatım
#   speed 0.72        -> belirgin yavaş (A1; 0.7–1.2 güvenli aralık)
SPEED_PRESETS = {
    "slow": 0.72,     # A1 öğrenme hızı (önceki 0.85 → daha yavaş)
    "normal": 0.95,   # doğal ama hafif yavaş (1.0 → 0.95)
}
BASE_SETTINGS = {
    "stability": 0.65,
    "similarity_boost": 0.80,
    "style": 0.0,
    "use_speaker_boost": True,
}
DEFAULT_SPEAKER = "narrator"
MAX_RETRIES = 4


# ---------------------------------------------------------------------------
# Yapılar
# ---------------------------------------------------------------------------
@dataclass
class VoiceConfig:
    voice_id: str
    settings: dict = field(default_factory=dict)


def load_voices(path: Path) -> dict[str, VoiceConfig]:
    data = json.loads(path.read_text(encoding="utf-8"))
    voices: dict[str, VoiceConfig] = {}
    for speaker, cfg in data.items():
        if speaker.startswith("_"):  # _note gibi yorum alanları
            continue
        voices[speaker] = VoiceConfig(
            voice_id=cfg["voice_id"],
            settings=cfg.get("settings", {}),
        )
    if DEFAULT_SPEAKER not in voices:
        raise SystemExit(
            f"voices.json içinde '{DEFAULT_SPEAKER}' tanımlı olmalı (yedek ses)."
        )
    return voices


def build_settings(voice: VoiceConfig, speed: float) -> dict:
    s = dict(BASE_SETTINGS)
    s.update(voice.settings)   # ses-özel override
    s["speed"] = speed
    return s


def text_hash(text: str, voice_id: str, speed: float, model: str) -> str:
    key = f"{model}|{voice_id}|{speed}|{text}".encode("utf-8")
    return hashlib.sha1(key).hexdigest()[:10]


def slugify(value: str) -> str:
    tr = str.maketrans({"ä": "ae", "ö": "oe", "ü": "ue", "ß": "ss",
                        "Ä": "ae", "Ö": "oe", "Ü": "ue", " ": "_"})
    out = value.lower().translate(tr)
    return "".join(c for c in out if c.isalnum() or c in "_-") or "x"


# ---------------------------------------------------------------------------
# ElevenLabs istemcisi (lazy import — dry-run'da gerekmez)
# ---------------------------------------------------------------------------
def make_client():
    try:
        from elevenlabs.client import ElevenLabs
    except ImportError:
        sys.exit("elevenlabs paketi yok. `pip install -r tools/requirements.txt`")
    api_key = os.environ.get("ELEVENLABS_API_KEY")
    if not api_key:
        sys.exit("ELEVENLABS_API_KEY tanımlı değil. `export ELEVENLABS_API_KEY=...`")
    return ElevenLabs(api_key=api_key)


def synthesize(client, text: str, voice_id: str, settings: dict,
               model: str, out_path: Path) -> None:
    from elevenlabs import VoiceSettings
    vs = VoiceSettings(**settings)
    last_err = None
    for attempt in range(1, MAX_RETRIES + 1):
        try:
            audio = client.text_to_speech.convert(
                text=text,
                voice_id=voice_id,
                model_id=model,
                output_format=OUTPUT_FORMAT,
                voice_settings=vs,
            )
            out_path.parent.mkdir(parents=True, exist_ok=True)
            with open(out_path, "wb") as f:
                for chunk in audio:
                    if chunk:
                        f.write(chunk)
            return
        except Exception as e:  # rate limit / geçici hata → backoff
            last_err = e
            wait = 2 ** attempt
            print(f"    ! hata ({attempt}/{MAX_RETRIES}): {e} — {wait}s bekle")
            time.sleep(wait)
    raise RuntimeError(f"Seslendirme başarısız: {out_path.name} — {last_err}")


# ---------------------------------------------------------------------------
# İsteğe bağlı: diyalog satırlarını tek dosyada birleştir (pydub + ffmpeg)
# ---------------------------------------------------------------------------
def try_stitch(line_paths: list[Path], out_path: Path, gap_ms: int = 600) -> bool:
    try:
        from pydub import AudioSegment
    except ImportError:
        return False
    try:
        combined = AudioSegment.silent(duration=0)
        gap = AudioSegment.silent(duration=gap_ms)
        for i, p in enumerate(line_paths):
            seg = AudioSegment.from_file(p, format="mp3")
            combined += seg
            if i < len(line_paths) - 1:
                combined += gap
        combined.export(out_path, format="mp3")
        return True
    except Exception as e:
        print(f"    ! birleştirme atlandı (ffmpeg gerekli): {e}")
        return False


# ---------------------------------------------------------------------------
# Ana akış
# ---------------------------------------------------------------------------
def process(args) -> None:
    voices = load_voices(Path(args.voices))
    items = json.loads(Path(args.input).read_text(encoding="utf-8"))
    if isinstance(items, dict):
        items = items.get("items", [])
    out_root = Path(args.out)
    speeds = [SPEED_PRESETS[s.strip()] for s in args.speeds.split(",")]
    speed_names = {v: k for k, v in SPEED_PRESETS.items()}

    client = None if args.dry_run else make_client()
    manifest: dict[str, dict] = {}
    total = made = skipped = 0

    for item in items:
        cid = item["id"]
        lektion = item.get("lektion", "gen")
        # lines: [{speaker, text}]  |  ya da tek "text" alanı (anlatım)
        lines = item.get("lines")
        if not lines:
            lines = [{"speaker": item.get("speaker", DEFAULT_SPEAKER),
                      "text": item["text"]}]

        manifest[cid] = {"lektion": lektion, "speeds": {}}
        print(f"▶ {cid} (L{lektion}) — {len(lines)} satır")

        for speed in speeds:
            sname = speed_names.get(speed, str(speed))
            line_paths: list[Path] = []
            for idx, line in enumerate(lines, 1):
                speaker = line.get("speaker", DEFAULT_SPEAKER)
                voice = voices.get(speaker) or voices[DEFAULT_SPEAKER]
                text = line["text"].strip()
                settings = build_settings(voice, speed)
                h = text_hash(text, voice.voice_id, speed, args.model)
                fname = f"{slugify(cid)}_{sname}_{idx:02d}_{slugify(speaker)}_{h}.mp3"
                out_path = out_root / f"l{lektion}" / sname / fname
                total += 1

                if out_path.exists() and not args.force:
                    print(f"  ⏭  {out_path.name} (var)")
                    skipped += 1
                elif args.dry_run:
                    print(f"  · [dry] {speaker:10s} @{sname} → {out_path.name}")
                    print(f"        \"{text}\"")
                else:
                    print(f"  ♪ {speaker:10s} @{sname} → {out_path.name}")
                    synthesize(client, text, voice.voice_id, settings,
                               args.model, out_path)
                    made += 1
                line_paths.append(out_path)

            # diyalogu tek dosyada birleştir (opsiyonel)
            combined = None
            if len(line_paths) > 1 and not args.dry_run:
                comb_path = out_root / f"l{lektion}" / sname / f"{slugify(cid)}_{sname}_full.mp3"
                if try_stitch(line_paths, comb_path):
                    combined = str(comb_path)
                    print(f"  ⧉ birleştirildi → {comb_path.name}")

            manifest[cid]["speeds"][sname] = {
                "lines": [str(p) for p in line_paths],
                "combined": combined,
            }

    if not args.dry_run:
        man_path = out_root / "manifest.json"
        man_path.parent.mkdir(parents=True, exist_ok=True)
        # Mevcut manifest'i koru (L3 varken L1 üretince silinmesin)
        existing: dict = {}
        if man_path.exists():
            try:
                existing = json.loads(man_path.read_text(encoding="utf-8"))
            except Exception:
                existing = {}
        existing.update(manifest)
        man_path.write_text(json.dumps(existing, ensure_ascii=False, indent=2),
                            encoding="utf-8")
        print(f"\n📄 manifest → {man_path} ({len(existing)} kayıt)")

    print(f"\nÖzet: {total} klip · üretildi {made} · atlandı {skipped}"
          + (" · [DRY-RUN]" if args.dry_run else ""))


def main() -> None:
    ap = argparse.ArgumentParser(description="SprachApp ElevenLabs seslendirme")
    ap.add_argument("--input", required=True, help="diyalog JSON dosyası")
    ap.add_argument("--voices", default="tools/voices.json", help="konuşmacı→ses eşlemesi")
    ap.add_argument("--out", default="storage/audio", help="çıktı kök klasörü")
    ap.add_argument("--model", default=DEFAULT_MODEL)
    ap.add_argument("--speeds", default="slow",
                    help="virgüllü: slow,normal (varsayılan: slow)")
    ap.add_argument("--force", action="store_true", help="var olan dosyaları yeniden üret")
    ap.add_argument("--dry-run", action="store_true", help="API çağırmadan planı göster")
    args = ap.parse_args()

    for s in args.speeds.split(","):
        if s.strip() not in SPEED_PRESETS:
            sys.exit(f"Geçersiz hız '{s}'. Seçenekler: {', '.join(SPEED_PRESETS)}")
    process(args)


if __name__ == "__main__":
    main()

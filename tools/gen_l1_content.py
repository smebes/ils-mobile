#!/usr/bin/env python3
"""Lektion 1 içerik + SVG üretimi. Spec'ten; özgün, de-DE, telifsiz."""
from __future__ import annotations

import json
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONTENT = ROOT / "content" / "l1"
MOBILE_CONTENT = ROOT / "mobile" / "assets" / "content" / "l1"
VOCAB_DIR = ROOT / "mobile" / "assets" / "vocab" / "l1"
IMG_DIR = ROOT / "mobile" / "assets" / "img"

CREAM = "#FAF3E7"
NAVY = "#264653"
TEAL = "#2A9D8F"
CORAL = "#E76F51"
MUSTARD = "#E9C46A"
BLUE = "#457B9D"
RED = "#E63946"
GREEN = "#2A9D8F"


def slug(wort: str) -> str:
    s = wort.lower()
    for a, b in [
        ("ä", "ae"),
        ("ö", "oe"),
        ("ü", "ue"),
        ("ß", "ss"),
        (" ", "_"),
        ("/", "_"),
        ("?", ""),
        ("!", ""),
        (".", ""),
        ("-", "_"),
    ]:
        s = s.replace(a, b)
    return "".join(c for c in s if c.isalnum() or c == "_")


def svg_base(label: str, body: str) -> str:
    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200" width="200" height="200" role="img" aria-label="{label}">
  <rect width="200" height="200" rx="32" fill="{CREAM}"/>
  <g fill="none" stroke="{NAVY}" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">
{body}
  </g>
</svg>
'''


def svg_sun() -> str:
    return svg_base(
        "Guten Morgen",
        f'    <circle cx="100" cy="90" r="36" fill="{MUSTARD}"/>\n'
        f'    <path d="M100 30 V48 M100 132 V150 M40 90 H58 M142 90 H160 M55 45 L68 58 M132 122 L145 135 M145 45 L132 58 M55 135 L68 122"/>\n'
        f'    <path d="M40 170 Q100 140 160 170" stroke="{TEAL}"/>',
    )


def svg_day() -> str:
    return svg_base(
        "Guten Tag",
        f'    <circle cx="140" cy="50" r="22" fill="{MUSTARD}"/>\n'
        f'    <path d="M30 140 Q70 100 110 120 Q140 140 170 110" stroke="{TEAL}" fill="{TEAL}" fill-opacity="0.25"/>\n'
        f'    <path d="M50 170 H150" stroke="{CORAL}"/>',
    )


def svg_evening() -> str:
    return svg_base(
        "Guten Abend",
        f'    <circle cx="130" cy="70" r="28" fill="{CORAL}"/>\n'
        f'    <circle cx="118" cy="70" r="22" fill="{CREAM}"/>\n'
        f'    <path d="M30 150 Q100 120 170 150" stroke="{NAVY}"/>\n'
        f'    <path d="M40 170 H160"/>',
    )


def svg_night() -> str:
    return svg_base(
        "Gute Nacht",
        f'    <circle cx="120" cy="70" r="30" fill="{BLUE}"/>\n'
        f'    <circle cx="108" cy="66" r="24" fill="{CREAM}"/>\n'
        f'    <circle cx="55" cy="50" r="3" fill="{MUSTARD}" stroke="none"/>\n'
        f'    <circle cx="70" cy="90" r="2" fill="{MUSTARD}" stroke="none"/>\n'
        f'    <circle cx="160" cy="110" r="2.5" fill="{MUSTARD}" stroke="none"/>',
    )


def svg_wave() -> str:
    return svg_base(
        "Hallo",
        f'    <circle cx="100" cy="70" r="28" fill="{MUSTARD}"/>\n'
        f'    <path d="M70 110 Q100 95 130 110 L140 170 H60 Z" fill="{TEAL}"/>\n'
        f'    <path d="M130 100 Q160 80 170 110" stroke="{CORAL}"/>',
    )


def svg_bye() -> str:
    return svg_base(
        "Tschüss",
        f'    <circle cx="80" cy="75" r="24" fill="{MUSTARD}"/>\n'
        f'    <path d="M55 110 Q80 95 105 110 L115 165 H50 Z" fill="{CORAL}"/>\n'
        f'    <path d="M110 90 Q140 70 155 100"/>',
    )


def svg_formal() -> str:
    return svg_base(
        "Auf Wiedersehen",
        f'    <rect x="55" y="55" width="90" height="100" rx="10" fill="{TEAL}"/>\n'
        f'    <circle cx="100" cy="85" r="18" fill="{MUSTARD}"/>\n'
        f'    <path d="M70 170 H130"/>',
    )


def svg_welcome() -> str:
    return svg_base(
        "Willkommen",
        f'    <path d="M40 140 L100 50 L160 140 Z" fill="{TEAL}"/>\n'
        f'    <rect x="80" y="110" width="40" height="50" fill="{MUSTARD}"/>\n'
        f'    <circle cx="100" cy="40" r="10" fill="{CORAL}" stroke="none"/>',
    )


def svg_thanks() -> str:
    return svg_base(
        "danke",
        f'    <path d="M70 110 C70 70 130 70 130 110 C130 145 100 160 100 160 C100 160 70 145 70 110 Z" fill="{CORAL}"/>\n'
        f'    <path d="M85 105 L95 115 L120 90" stroke="{CREAM}" stroke-width="8"/>',
    )


def svg_person(color: str, label: str) -> str:
    return svg_base(
        label,
        f'    <circle cx="100" cy="70" r="28" fill="{color}"/>\n'
        f'    <path d="M55 170 Q55 115 100 115 Q145 115 145 170 Z" fill="{TEAL}"/>',
    )


def svg_name() -> str:
    return svg_base(
        "Name",
        f'    <rect x="45" y="55" width="110" height="90" rx="12" fill="{TEAL}"/>\n'
        f'    <circle cx="75" cy="95" r="16" fill="{MUSTARD}"/>\n'
        f'    <path d="M100 80 H140 M100 100 H135 M100 120 H128" stroke="{CREAM}" stroke-width="5"/>',
    )


def svg_phone() -> str:
    return svg_base(
        "Telefon",
        f'    <rect x="70" y="35" width="60" height="120" rx="12" fill="{NAVY}"/>\n'
        f'    <rect x="78" y="50" width="44" height="70" rx="4" fill="{TEAL}"/>\n'
        f'    <circle cx="100" cy="140" r="8" fill="{MUSTARD}" stroke="none"/>',
    )


def svg_letter() -> str:
    return svg_base(
        "Buchstabe",
        f'    <rect x="50" y="40" width="100" height="120" rx="10" fill="{MUSTARD}"/>\n'
        f'    <path d="M75 70 H125 M100 70 V145" stroke="{NAVY}" stroke-width="10"/>',
    )


def svg_alphabet() -> str:
    return svg_base(
        "Alphabet",
        f'    <rect x="35" y="50" width="50" height="60" rx="8" fill="{CORAL}"/>\n'
        f'    <rect x="75" y="70" width="50" height="60" rx="8" fill="{TEAL}"/>\n'
        f'    <rect x="115" y="90" width="50" height="60" rx="8" fill="{MUSTARD}"/>',
    )


def svg_card() -> str:
    return svg_base(
        "Visitenkarte",
        f'    <rect x="35" y="60" width="130" height="80" rx="8" fill="{TEAL}"/>\n'
        f'    <circle cx="65" cy="100" r="16" fill="{MUSTARD}"/>\n'
        f'    <path d="M95 85 H150 M95 105 H140 M95 125 H130" stroke="{CREAM}" stroke-width="5"/>',
    )


def svg_form() -> str:
    return svg_base(
        "Formular",
        f'    <rect x="45" y="35" width="110" height="130" rx="8" fill="{MUSTARD}"/>\n'
        f'    <path d="M60 60 H140 M60 85 H140 M60 110 H120 M60 135 H130" stroke="{NAVY}" stroke-width="5"/>',
    )


def svg_street() -> str:
    return svg_base(
        "Straße",
        f'    <path d="M30 150 L100 50 L170 150 Z" fill="{TEAL}"/>\n'
        f'    <rect x="85" y="110" width="30" height="40" fill="{MUSTARD}"/>\n'
        f'    <path d="M20 170 H180" stroke="{NAVY}"/>',
    )


def svg_city() -> str:
    return svg_base(
        "Stadt",
        f'    <rect x="40" y="90" width="40" height="70" fill="{TEAL}"/>\n'
        f'    <rect x="90" y="60" width="35" height="100" fill="{CORAL}"/>\n'
        f'    <rect x="135" y="100" width="30" height="60" fill="{MUSTARD}"/>\n'
        f'    <path d="M30 170 H175"/>',
    )


def svg_country() -> str:
    return svg_base(
        "Land",
        f'    <circle cx="100" cy="100" r="55" fill="{TEAL}"/>\n'
        f'    <path d="M100 45 V155 M45 100 H155" stroke="{CREAM}" stroke-width="4"/>\n'
        f'    <ellipse cx="100" cy="100" rx="25" ry="55" stroke="{CREAM}" stroke-width="4"/>',
    )


def svg_plz() -> str:
    return svg_base(
        "Postleitzahl",
        f'    <rect x="40" y="70" width="120" height="60" rx="8" fill="{TEAL}"/>\n'
        f'    <path d="M55 100 H85 M100 100 H130 M145 90 V110" stroke="{CREAM}" stroke-width="6"/>',
    )


def svg_address() -> str:
    return svg_base(
        "Adresse",
        f'    <rect x="50" y="45" width="100" height="110" rx="8" fill="{MUSTARD}"/>\n'
        f'    <path d="M65 70 H135 M65 95 H125 M65 120 H110" stroke="{NAVY}" stroke-width="5"/>',
    )


def svg_firma() -> str:
    return svg_base(
        "Firma",
        f'    <rect x="40" y="70" width="120" height="90" rx="6" fill="{TEAL}"/>\n'
        f'    <rect x="55" y="85" width="25" height="25" fill="{MUSTARD}"/>\n'
        f'    <rect x="90" y="85" width="25" height="25" fill="{MUSTARD}"/>\n'
        f'    <rect x="125" y="85" width="20" height="50" fill="{CORAL}"/>',
    )


def svg_language() -> str:
    return svg_base(
        "Sprache",
        f'    <ellipse cx="80" cy="95" rx="40" ry="30" fill="{TEAL}"/>\n'
        f'    <ellipse cx="130" cy="110" rx="35" ry="26" fill="{MUSTARD}"/>\n'
        f'    <path d="M70 125 L55 150 L90 130" fill="{TEAL}" stroke="none"/>',
    )


def svg_flag(c1: str, c2: str, c3: str | None, label: str) -> str:
    if c3:
        body = (
            f'    <rect x="40" y="50" width="120" height="33" fill="{c1}" stroke="none"/>\n'
            f'    <rect x="40" y="83" width="120" height="34" fill="{c2}" stroke="none"/>\n'
            f'    <rect x="40" y="117" width="120" height="33" fill="{c3}" stroke="none"/>\n'
            f'    <rect x="40" y="50" width="120" height="100" rx="6"/>'
        )
    else:
        body = (
            f'    <rect x="40" y="50" width="120" height="50" fill="{c1}" stroke="none"/>\n'
            f'    <rect x="40" y="100" width="120" height="50" fill="{c2}" stroke="none"/>\n'
            f'    <rect x="40" y="50" width="120" height="100" rx="6"/>'
        )
    return svg_base(label, body)


def svg_ch() -> str:
    return svg_base(
        "Schweiz",
        f'    <rect x="40" y="50" width="120" height="100" rx="6" fill="{RED}" stroke="none"/>\n'
        f'    <path d="M100 70 V130 M70 100 H130" stroke="#FFFFFF" stroke-width="14"/>\n'
        f'    <rect x="40" y="50" width="120" height="100" rx="6"/>',
    )


def svg_tr() -> str:
    return svg_base(
        "Türkei",
        f'    <rect x="40" y="50" width="120" height="100" rx="6" fill="{RED}" stroke="none"/>\n'
        f'    <circle cx="85" cy="100" r="22" fill="#FFFFFF" stroke="none"/>\n'
        f'    <circle cx="92" cy="100" r="17" fill="{RED}" stroke="none"/>\n'
        f'    <rect x="40" y="50" width="120" height="100" rx="6"/>',
    )


def svg_bubble(label: str) -> str:
    return svg_base(
        label,
        f'    <ellipse cx="100" cy="90" rx="55" ry="40" fill="{TEAL}"/>\n'
        f'    <path d="M80 125 L70 155 L105 130" fill="{TEAL}" stroke="none"/>\n'
        f'    <circle cx="80" cy="90" r="5" fill="{CREAM}" stroke="none"/>\n'
        f'    <circle cx="100" cy="90" r="5" fill="{CREAM}" stroke="none"/>\n'
        f'    <circle cx="120" cy="90" r="5" fill="{CREAM}" stroke="none"/>',
    )


def svg_cover() -> str:
    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 450" width="800" height="450" role="img" aria-label="Lektion 1 Cover">
  <defs>
    <linearGradient id="g" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="{TEAL}"/>
      <stop offset="100%" stop-color="{NAVY}"/>
    </linearGradient>
  </defs>
  <rect width="800" height="450" fill="url(#g)"/>
  <circle cx="220" cy="200" r="48" fill="{MUSTARD}"/>
  <path d="M160 320 Q160 250 220 250 Q280 250 280 320 Z" fill="{CORAL}"/>
  <circle cx="520" cy="190" r="48" fill="{MUSTARD}"/>
  <path d="M460 320 Q460 240 520 240 Q580 240 580 320 Z" fill="{TEAL}"/>
  <path d="M300 210 Q370 170 440 210" fill="none" stroke="{CREAM}" stroke-width="8" stroke-linecap="round"/>
</svg>
'''


def svg_scene_evening() -> str:
    return svg_evening().replace('viewBox="0 0 200 200"', 'viewBox="0 0 200 200"')


# ─── VOCAB ───────────────────────────────────────────────────────────

VOCAB: list[dict] = []


def add(
    wort: str,
    *,
    artikel: str | None,
    plural: str | None,
    wortart: str,
    tr: str,
    schritt: str,
    typ: str,
    beispiel: str,
    image_key: str | None,
):
    item = {
        "wort": wort,
        "artikel": artikel,
        "plural": plural,
        "wortart": wortart,
        "uebersetzung_tr": tr,
        "schritt": schritt,
        "typ": typ,
        "beispiel": beispiel,
        "image": f"assets/vocab/l1/l1_vocab_{image_key}.svg" if image_key else None,
        "audio": None,
    }
    VOCAB.append(item)


def build_vocab():
    # Folge / genel
    add("heißen", artikel=None, plural=None, wortart="Verb", tr="adında olmak",
        schritt="folge", typ="funktion", beispiel="Ich heiße Lara.", image_key=None)
    add("Name", artikel="der", plural="Namen", wortart="Nomen", tr="isim",
        schritt="folge", typ="somut", beispiel="Mein Name ist Walter.", image_key="name")
    add("kommen", artikel=None, plural=None, wortart="Verb", tr="gelmek",
        schritt="folge", typ="funktion", beispiel="Ich komme aus Polen.", image_key=None)
    add("sprechen", artikel=None, plural=None, wortart="Verb", tr="konuşmak",
        schritt="folge", typ="funktion", beispiel="Ich spreche ein bisschen Deutsch.", image_key=None)
    add("ein bisschen", artikel=None, plural=None, wortart="Phrase", tr="biraz",
        schritt="folge", typ="funktion", beispiel="Ich spreche ein bisschen Deutsch.", image_key=None)

    # A
    add("Guten Morgen", artikel=None, plural=None, wortart="Phrase", tr="günaydın",
        schritt="A", typ="sahne", beispiel="Guten Morgen, Herr Baumann!", image_key="guten_morgen")
    add("Guten Tag", artikel=None, plural=None, wortart="Phrase", tr="iyi günler",
        schritt="A", typ="sahne", beispiel="Guten Tag! Wie geht es Ihnen?", image_key="guten_tag")
    add("Guten Abend", artikel=None, plural=None, wortart="Phrase", tr="iyi akşamlar",
        schritt="A", typ="sahne", beispiel="Guten Abend, Frau Nowak.", image_key="guten_abend")
    add("Gute Nacht", artikel=None, plural=None, wortart="Phrase", tr="iyi geceler",
        schritt="A", typ="sahne", beispiel="Gute Nacht, Lili!", image_key="gute_nacht")
    add("Hallo", artikel=None, plural=None, wortart="Phrase", tr="merhaba",
        schritt="A", typ="sahne", beispiel="Hallo, ich heiße Lara.", image_key="hallo")
    add("Tschüss", artikel=None, plural=None, wortart="Phrase", tr="hoşça kal",
        schritt="A", typ="sahne", beispiel="Tschüss! Bis morgen.", image_key="tschuess")
    add("Auf Wiedersehen", artikel=None, plural=None, wortart="Phrase", tr="görüşürüz",
        schritt="A", typ="sahne", beispiel="Auf Wiedersehen, Herr Baumann.", image_key="auf_wiedersehen")
    add("Willkommen", artikel=None, plural=None, wortart="Phrase", tr="hoş geldiniz",
        schritt="A", typ="sahne", beispiel="Willkommen in Deutschland!", image_key="willkommen")
    add("danke", artikel=None, plural=None, wortart="Phrase", tr="teşekkürler",
        schritt="A", typ="sahne", beispiel="Danke, das ist nett.", image_key="danke")
    add("Frau", artikel="die", plural="Frauen", wortart="Nomen", tr="hanım",
        schritt="A", typ="somut-kisi", beispiel="Guten Tag, Frau Nowak.", image_key="frau")
    add("Herr", artikel="der", plural="Herren", wortart="Nomen", tr="bey",
        schritt="A", typ="somut-kisi", beispiel="Guten Tag, Herr Baumann.", image_key="herr")
    add("Dame", artikel="die", plural="Damen", wortart="Nomen", tr="hanım",
        schritt="A", typ="somut-kisi", beispiel="Die Dame heißt Sofia.", image_key="dame")

    # B
    add("Entschuldigung", artikel="die", plural="Entschuldigungen", wortart="Nomen", tr="pardon",
        schritt="B", typ="funktion", beispiel="Entschuldigung, wie heißen Sie?", image_key=None)
    add("wie", artikel=None, plural=None, wortart="Fragewort", tr="nasıl",
        schritt="B", typ="funktion", beispiel="Wie heißen Sie?", image_key=None)
    add("wer", artikel=None, plural=None, wortart="Fragewort", tr="kim",
        schritt="B", typ="funktion", beispiel="Wer ist das?", image_key=None)
    add("ja", artikel=None, plural=None, wortart="Partikel", tr="evet",
        schritt="B", typ="funktion", beispiel="Ja, das stimmt.", image_key=None)
    add("nein", artikel=None, plural=None, wortart="Partikel", tr="hayır",
        schritt="B", typ="funktion", beispiel="Nein, ich heiße nicht Anna.", image_key=None)
    add("stimmen", artikel=None, plural=None, wortart="Verb", tr="doğru olmak",
        schritt="B", typ="funktion", beispiel="Ja, das stimmt.", image_key=None)
    add("Freut mich", artikel=None, plural=None, wortart="Phrase", tr="memnun oldum",
        schritt="B", typ="sahne", beispiel="Freut mich. Ich heiße Walter.", image_key="freut_mich")

    # C
    add("woher", artikel=None, plural=None, wortart="Fragewort", tr="nereden",
        schritt="C", typ="funktion", beispiel="Woher kommen Sie?", image_key=None)
    add("aus", artikel=None, plural=None, wortart="Präposition", tr="-den/-dan",
        schritt="C", typ="funktion", beispiel="Ich komme aus Polen.", image_key=None)
    add("Sprache", artikel="die", plural="Sprachen", wortart="Nomen", tr="dil",
        schritt="C", typ="somut", beispiel="Welche Sprache sprechen Sie?", image_key="sprache")
    add("toll", artikel=None, plural=None, wortart="Adjektiv", tr="harika",
        schritt="C", typ="sahne", beispiel="Deutsch ist toll!", image_key="toll")
    add("interessant", artikel=None, plural=None, wortart="Adjektiv", tr="ilginç",
        schritt="C", typ="sahne", beispiel="Das ist interessant.", image_key="interessant")

    flags = [
        ("Deutschland", None, None, "Almanya", "deutschland", "schwarz_rot_gold"),
        ("Österreich", None, None, "Avusturya", "oesterreich", "rot_weiss_rot"),
        ("Schweiz", "die", None, "İsviçre", "schweiz", "ch"),
        ("Polen", None, None, "Polonya", "polen", "weiss_rot"),
        ("Türkei", "die", None, "Türkiye", "tuerkei", "tr"),
        ("Spanien", None, None, "İspanya", "spanien", "rot_gelb"),
        ("Italien", None, None, "İtalya", "italien", "gruen_weiss_rot"),
        ("Frankreich", None, None, "Fransa", "frankreich", "blau_weiss_rot"),
        ("Syrien", None, None, "Suriye", "syrien", "rot_weiss_schwarz"),
    ]
    for wort, art, pl, tr, key, _ in flags:
        add(wort, artikel=art, plural=pl, wortart="Nomen", tr=tr,
            schritt="C", typ="somut-bayrak",
            beispiel=f"Ich komme aus {('der ' + wort) if art == 'die' else wort}.",
            image_key=key)

    langs = [
        ("Deutsch", "Almanca", "deutsch"),
        ("Polnisch", "Lehçe", "polnisch"),
        ("Türkisch", "Türkçe", "tuerkisch"),
        ("Spanisch", "İspanyolca", "spanisch"),
        ("Italienisch", "İtalyanca", "italienisch"),
        ("Französisch", "Fransızca", "franzoesisch"),
        ("Arabisch", "Arapça", "arabisch"),
    ]
    for wort, tr, key in langs:
        add(wort, artikel=None, plural=None, wortart="Nomen", tr=tr,
            schritt="C", typ="somut",
            beispiel=f"Ich spreche {wort}.", image_key=key)

    # D
    add("Buchstabe", artikel="der", plural="Buchstaben", wortart="Nomen", tr="harf",
        schritt="D", typ="somut", beispiel="Das ist der Buchstabe M.", image_key="buchstabe")
    add("Alphabet", artikel="das", plural=None, wortart="Nomen", tr="alfabe",
        schritt="D", typ="somut", beispiel="Das Alphabet hat 26 Buchstaben.", image_key="alphabet")
    add("buchstabieren", artikel=None, plural=None, wortart="Verb", tr="harf harf söylemek",
        schritt="D", typ="sahne", beispiel="Können Sie Ihren Namen buchstabieren?", image_key="buchstabieren")
    add("Wie bitte?", artikel=None, plural=None, wortart="Phrase", tr="efendim?",
        schritt="D", typ="sahne", beispiel="Wie bitte? Noch einmal, bitte.", image_key="wie_bitte")
    add("Firma", artikel="die", plural="Firmen", wortart="Nomen", tr="firma",
        schritt="D", typ="somut", beispiel="Ich arbeite in einer Firma.", image_key="firma")
    add("Telefon", artikel="das", plural="Telefone", wortart="Nomen", tr="telefon",
        schritt="D", typ="somut", beispiel="Mein Telefon ist neu.", image_key="telefon")

    # E
    add("Adresse", artikel="die", plural="Adressen", wortart="Nomen", tr="adres",
        schritt="E", typ="somut", beispiel="Wie ist Ihre Adresse?", image_key="adresse")
    add("Visitenkarte", artikel="die", plural="Visitenkarten", wortart="Nomen", tr="kartvizit",
        schritt="E", typ="somut", beispiel="Hier ist meine Visitenkarte.", image_key="visitenkarte")
    add("Vorname", artikel="der", plural="Vornamen", wortart="Nomen", tr="ad",
        schritt="E", typ="somut-form", beispiel="Mein Vorname ist Lara.", image_key="vorname")
    add("Familienname", artikel="der", plural="Familiennamen", wortart="Nomen", tr="soyad",
        schritt="E", typ="somut-form", beispiel="Mein Familienname ist Nowak.", image_key="familienname")
    add("Straße", artikel="die", plural="Straßen", wortart="Nomen", tr="cadde",
        schritt="E", typ="somut", beispiel="Ich wohne in der Goethestraße.", image_key="strasse")
    add("Stadt", artikel="die", plural="Städte", wortart="Nomen", tr="şehir",
        schritt="E", typ="somut", beispiel="Die Stadt heißt München.", image_key="stadt")
    add("Land", artikel="das", plural="Länder", wortart="Nomen", tr="ülke",
        schritt="E", typ="somut", beispiel="Welches Land ist das?", image_key="land")
    add("Postleitzahl", artikel="die", plural="Postleitzahlen", wortart="Nomen", tr="posta kodu",
        schritt="E", typ="somut", beispiel="Die Postleitzahl ist 80331.", image_key="postleitzahl")
    add("Formular", artikel="das", plural="Formulare", wortart="Nomen", tr="form",
        schritt="E", typ="somut", beispiel="Bitte füllen Sie das Formular aus.", image_key="formular")


SVG_MAP = {
    "name": svg_name,
    "guten_morgen": svg_sun,
    "guten_tag": svg_day,
    "guten_abend": svg_evening,
    "gute_nacht": svg_night,
    "hallo": svg_wave,
    "tschuess": svg_bye,
    "auf_wiedersehen": svg_formal,
    "willkommen": svg_welcome,
    "danke": svg_thanks,
    "frau": lambda: svg_person(CORAL, "Frau"),
    "herr": lambda: svg_person(BLUE, "Herr"),
    "dame": lambda: svg_person(MUSTARD, "Dame"),
    "freut_mich": svg_thanks,
    "sprache": svg_language,
    "toll": svg_thanks,
    "interessant": svg_language,
    "deutschland": lambda: svg_flag("#000000", "#DD0000", "#FFCE00", "Deutschland"),
    "oesterreich": lambda: svg_flag("#ED2939", "#FFFFFF", "#ED2939", "Österreich"),
    "schweiz": svg_ch,
    "polen": lambda: svg_flag("#FFFFFF", "#DC143C", None, "Polen"),
    "tuerkei": svg_tr,
    "spanien": lambda: svg_flag("#AA151B", "#F1BF00", "#AA151B", "Spanien"),
    "italien": lambda: svg_flag("#009246", "#FFFFFF", "#CE2B37", "Italien"),
    "frankreich": lambda: svg_flag("#0055A4", "#FFFFFF", "#EF4135", "Frankreich"),
    "syrien": lambda: svg_flag("#CE1126", "#FFFFFF", "#000000", "Syrien"),
    "deutsch": lambda: svg_bubble("Deutsch"),
    "polnisch": lambda: svg_bubble("Polnisch"),
    "tuerkisch": lambda: svg_bubble("Türkisch"),
    "spanisch": lambda: svg_bubble("Spanisch"),
    "italienisch": lambda: svg_bubble("Italienisch"),
    "franzoesisch": lambda: svg_bubble("Französisch"),
    "arabisch": lambda: svg_bubble("Arabisch"),
    "buchstabe": svg_letter,
    "alphabet": svg_alphabet,
    "buchstabieren": svg_letter,
    "wie_bitte": svg_wave,
    "firma": svg_firma,
    "telefon": svg_phone,
    "adresse": svg_address,
    "visitenkarte": svg_card,
    "vorname": svg_name,
    "familienname": svg_name,
    "strasse": svg_street,
    "stadt": svg_city,
    "land": svg_country,
    "postleitzahl": svg_plz,
    "formular": svg_form,
}


def write_svgs():
    VOCAB_DIR.mkdir(parents=True, exist_ok=True)
    IMG_DIR.mkdir(parents=True, exist_ok=True)
    for key, fn in SVG_MAP.items():
        (VOCAB_DIR / f"l1_vocab_{key}.svg").write_text(fn(), encoding="utf-8")
    (IMG_DIR / "l1_cover.svg").write_text(svg_cover(), encoding="utf-8")
    (IMG_DIR / "l1_scene_abend.svg").write_text(svg_evening(), encoding="utf-8")
    (IMG_DIR / "l1_scene_nachbarn.svg").write_text(svg_wave(), encoding="utf-8")
    (IMG_DIR / "l1_scene_telefon.svg").write_text(svg_phone(), encoding="utf-8")


def build_lektion() -> dict:
    return {
        "_meta": {
            "note": "Lektion 1 (Guten Tag. Mein Name ist …) meta + vocab. Yapı Schritte Plus Neu 1; içerik özgün (telifsiz). de-DE normalleştirme.",
            "media": {
                "vocab_base": "assets/vocab/l1/",
                "scene_base": "public/img/",
                "audio_manifest": "storage/audio/manifest.json",
            },
        },
        "lektion": {
            "id": 1,
            "nummer": 1,
            "titel": "Guten Tag. Mein Name ist …",
            "thema": "Tanışma, selamlaşma, ülke/dil, alfabe, kayıt",
            "cefr": "A1",
            "folge": {"id": 1, "titel": "Das bin ich."},
            "grammar_focus": [
                "Aussage",
                "W-Frage",
                "Personalpronomen (ich/du/Sie)",
                "Verbkonjugation (heißen, kommen, sprechen, sein)",
                "Präposition aus",
            ],
            "cover_image": "public/img/l1_cover.svg",
            "vocab_narration": {"audio_ref": "L1_vocab_narration"},
        },
        "schritte": [
            {"id": "folge", "titel": "Das bin ich.", "ziel": "Foto-Hörgeschichte: neue Nachbarn"},
            {"id": "A", "titel": "Guten Tag", "ziel": "Begrüßung und Abschied"},
            {"id": "B", "titel": "Ich heiße Lara Nowak", "ziel": "Namen fragen und sagen"},
            {"id": "C", "titel": "Ich komme aus Polen", "ziel": "Herkunft und Sprachen"},
            {"id": "D", "titel": "Buchstaben", "ziel": "Alphabet und am Telefon buchstabieren"},
            {"id": "E", "titel": "Adresse", "ziel": "Visitenkarte und Formular"},
        ],
        "vocab": VOCAB,
    }


def ex(
    eid: str,
    schritt: str,
    mechanic: str,
    grammar: str,
    domain: str,
    payload: dict,
    solution,
) -> dict:
    return {
        "id": eid,
        "lektion_id": 1,
        "schritt": schritt,
        "mechanic": mechanic,
        "cefr": "A1",
        "grammar_topic": grammar,
        "vocab_domain": domain,
        "payload": payload,
        "solution": solution,
        "quality_pass": True,
        "reviewed": False,
    }


def vimg(key: str) -> str:
    return f"assets/vocab/l1/l1_vocab_{key}.svg"


def build_exercises() -> dict:
    items = []

    # ── A ──
    items.append(ex(
        "L1_A1", "A", "matching", "Begrüßung", "Begrüßung/Abschied",
        {
            "instruction": "Ordne die Bilder den Begrüßungen zu.",
            "left": [
                {"id": "a", "image": vimg("guten_morgen")},
                {"id": "b", "image": vimg("guten_tag")},
                {"id": "c", "image": vimg("guten_abend")},
                {"id": "d", "image": vimg("gute_nacht")},
            ],
            "right": [
                {"id": "1", "text": "Guten Morgen"},
                {"id": "2", "text": "Guten Tag"},
                {"id": "3", "text": "Guten Abend"},
                {"id": "4", "text": "Gute Nacht"},
            ],
        },
        {"a": "1", "b": "2", "c": "3", "d": "4"},
    ))
    items.append(ex(
        "L1_A2", "A", "matching", "Begrüßung vs Abschied", "Begrüßung/Abschied",
        {
            "instruction": "Ordne zu: Begrüßung oder Abschied?",
            "many_to_one": True,
            "left": [
                {"id": "a", "text": "Guten Tag"},
                {"id": "b", "text": "Hallo"},
                {"id": "c", "text": "Tschüss"},
                {"id": "d", "text": "Auf Wiedersehen"},
            ],
            "right": [
                {"id": "1", "text": "Begrüßung"},
                {"id": "2", "text": "Abschied"},
            ],
        },
        {"a": "1", "b": "1", "c": "2", "d": "2"},
    ))
    items.append(ex(
        "L1_A3", "A", "listening", "Hörverstehen — Tageszeit", "Begrüßung/Abschied",
        {
            "instruction": "Hör den Dialog. Welche Tageszeit ist es?",
            "scene_image": "public/img/l1_scene_abend.svg",
            "audio_ref": "L1_A3_tageszeit",
            "default_speed": "slow",
            "lines": [
                {"speaker": "walter", "text": "Guten Abend, Frau Nowak."},
                {"speaker": "lara", "text": "Guten Abend, Herr Baumann."},
            ],
            "audio": {"slow": [], "normal": []},
            "questions": [
                {
                    "id": "q1",
                    "q": "Welche Tageszeit ist es?",
                    "options": [
                        {"id": "o1", "text": "Abend"},
                        {"id": "o2", "text": "Morgen"},
                        {"id": "o3", "text": "Nacht"},
                    ],
                }
            ],
        },
        {"q1": "o1"},
    ))
    items.append(ex(
        "L1_A4", "A", "quiz", "Begrüßung zur Tageszeit", "Begrüßung/Abschied",
        {
            "instruction": "Was ist richtig?",
            "question": "Es ist Abend. Was sagt man?",
            "image": "public/img/l1_scene_abend.svg",
            "options": [
                {"id": "o1", "text": "Guten Abend"},
                {"id": "o2", "text": "Guten Morgen"},
                {"id": "o3", "text": "Gute Nacht"},
            ],
        },
        {
            "answer": "o1",
            "explanation": "Am Abend sagt man „Guten Abend“. „Gute Nacht“ sagt man zum Schlafen.",
        },
    ))

    # ── B ──
    items.append(ex(
        "L1_B1", "B", "fill_blank", "W-Frage + Verbkonjugation heißen", "Personalien",
        {
            "instruction": "Ergänze.",
            "sentence": "{{b1}} heißen Sie? — Ich {{b2}} Lara.",
            "blanks": [
                {"id": "b1", "options": ["Wie", "Wer", "Wo"]},
                {"id": "b2", "options": ["heiße", "heißt", "heißen"]},
            ],
        },
        {
            "b1": {"answer": "Wie", "accept": ["wie", "Wie"]},
            "b2": {"answer": "heiße", "accept": ["heiße", "heisse"]},
        },
    ))
    items.append(ex(
        "L1_B2", "B", "matching", "Frage ↔ Antwort", "Personalien",
        {
            "instruction": "Ordne Frage und Antwort.",
            "left": [
                {"id": "a", "text": "Wie heißen Sie?"},
                {"id": "b", "text": "Wie heißt du?"},
                {"id": "c", "text": "Wer ist das?"},
            ],
            "right": [
                {"id": "1", "text": "Ich heiße Walter Baumann."},
                {"id": "2", "text": "Ich heiße Lili."},
                {"id": "3", "text": "Das ist Lara Nowak."},
            ],
        },
        {"a": "1", "b": "2", "c": "3"},
    ))
    items.append(ex(
        "L1_B3", "B", "quiz", "Aussage vs W-Frage", "Personalien",
        {
            "instruction": "Was ist richtig?",
            "question": "Welche Satz ist eine W-Frage?",
            "options": [
                {"id": "o1", "text": "Wie heißen Sie?"},
                {"id": "o2", "text": "Ich heiße Lara."},
                {"id": "o3", "text": "Mein Name ist Walter."},
            ],
        },
        {
            "answer": "o1",
            "explanation": "W-Fragen beginnen oft mit wie, wer, wo… und enden mit Fragezeichen.",
        },
    ))
    items.append(ex(
        "L1_B4", "B", "fill_blank", "Aussage: Mein Name ist …", "Personalien",
        {
            "instruction": "Ergänze den Dialog.",
            "sentence": "Guten Tag. {{b1}} ist Lara. — Freut mich.",
            "blanks": [
                {"id": "b1", "options": ["Mein Name", "Wie", "Ich heiße"]},
            ],
        },
        {
            "b1": {"answer": "Mein Name", "accept": ["mein name", "Mein Name"]},
        },
    ))

    # ── C ──
    items.append(ex(
        "L1_C1", "C", "matching", "Länder", "Länder, Sprachen",
        {
            "instruction": "Ordne die Flaggen den Ländern zu.",
            "left": [
                {"id": "a", "image": vimg("deutschland")},
                {"id": "b", "image": vimg("polen")},
                {"id": "c", "image": vimg("tuerkei")},
                {"id": "d", "image": vimg("italien")},
            ],
            "right": [
                {"id": "1", "text": "Deutschland"},
                {"id": "2", "text": "Polen"},
                {"id": "3", "text": "die Türkei"},
                {"id": "4", "text": "Italien"},
            ],
        },
        {"a": "1", "b": "2", "c": "3", "d": "4"},
    ))
    items.append(ex(
        "L1_C2", "C", "matching", "Land ↔ Sprache", "Länder, Sprachen",
        {
            "instruction": "Ordne Land und Sprache.",
            "left": [
                {"id": "a", "text": "Deutschland", "image": vimg("deutschland")},
                {"id": "b", "text": "Polen", "image": vimg("polen")},
                {"id": "c", "text": "die Türkei", "image": vimg("tuerkei")},
                {"id": "d", "text": "Spanien", "image": vimg("spanien")},
            ],
            "right": [
                {"id": "1", "text": "Deutsch"},
                {"id": "2", "text": "Polnisch"},
                {"id": "3", "text": "Türkisch"},
                {"id": "4", "text": "Spanisch"},
            ],
        },
        {"a": "1", "b": "2", "c": "3", "d": "4"},
    ))
    items.append(ex(
        "L1_C3", "C", "fill_blank", "Präposition aus", "Länder, Sprachen",
        {
            "instruction": "Ergänze: aus / aus der …",
            "sentence": "Ich komme {{b1}} Polen. Ich komme {{b2}} der Schweiz.",
            "blanks": [
                {"id": "b1", "options": ["aus", "in", "von"]},
                {"id": "b2", "options": ["aus", "in", "von"]},
            ],
        },
        {
            "b1": {"answer": "aus", "accept": ["aus"]},
            "b2": {"answer": "aus", "accept": ["aus"]},
        },
    ))
    items.append(ex(
        "L1_C4", "C", "quiz", "du vs Sie — Verbkonjugation", "Personalpronomen",
        {
            "instruction": "Was ist richtig?",
            "question": "Woher ___ du? / Woher ___ Sie?",
            "options": [
                {"id": "o1", "text": "kommst / kommen"},
                {"id": "o2", "text": "kommen / kommst"},
                {"id": "o3", "text": "kommt / komme"},
            ],
        },
        {
            "answer": "o1",
            "explanation": "du → kommst; Sie (Höflichkeit) → kommen (wie Plural).",
        },
    ))
    items.append(ex(
        "L1_C5", "C", "listening", "Hörverstehen — Herkunft", "Länder, Sprachen",
        {
            "instruction": "Hör den Dialog. Woher kommt die Person?",
            "scene_image": "public/img/l1_scene_nachbarn.svg",
            "audio_ref": "L1_folge1",
            "default_speed": "slow",
            "lines": [
                {"speaker": "walter", "text": "Guten Tag. Mein Name ist Walter Baumann."},
                {"speaker": "lara", "text": "Hallo. Ich heiße Lara Nowak."},
                {"speaker": "walter", "text": "Woher kommen Sie, Frau Nowak?"},
                {"speaker": "lara", "text": "Ich komme aus Polen. Und ich spreche ein bisschen Deutsch."},
                {"speaker": "lili", "text": "Ich bin Lili. Ich bin vier."},
                {"speaker": "lara", "text": "Hallo Lili!"},
            ],
            "audio": {"slow": [], "normal": []},
            "questions": [
                {
                    "id": "q1",
                    "q": "Woher kommt Lara?",
                    "options": [
                        {"id": "o1", "text": "aus Polen"},
                        {"id": "o2", "text": "aus der Türkei"},
                        {"id": "o3", "text": "aus Spanien"},
                    ],
                },
                {
                    "id": "q2",
                    "q": "Wie heißt das Kind?",
                    "options": [
                        {"id": "o1", "text": "Lili"},
                        {"id": "o2", "text": "Sofia"},
                        {"id": "o3", "text": "Lara"},
                    ],
                },
            ],
        },
        {"q1": "o1", "q2": "o1"},
    ))

    # ── D ──
    items.append(ex(
        "L1_D1", "D", "listening", "Alphabet hören", "Alphabet",
        {
            "instruction": "Hör den Buchstaben. Welcher Buchstabe ist das?",
            "audio_ref": "L1_D1_buchstabe_m",
            "default_speed": "slow",
            "lines": [{"speaker": "narrator", "text": "M"}],
            "audio": {"slow": [], "normal": []},
            "questions": [
                {
                    "id": "q1",
                    "q": "Welchen Buchstaben hörst du?",
                    "options": [
                        {"id": "o1", "text": "M"},
                        {"id": "o2", "text": "N"},
                        {"id": "o3", "text": "W"},
                    ],
                }
            ],
        },
        {"q1": "o1"},
    ))
    items.append(ex(
        "L1_D2", "D", "fill_blank", "Verbkonjugation sein", "Verbkonjugation",
        {
            "instruction": "Ergänze: sein.",
            "sentence": "ich {{b1}} — du {{b2}} — er {{b3}}",
            "blanks": [
                {"id": "b1", "options": ["bin", "bist", "ist"]},
                {"id": "b2", "options": ["bin", "bist", "ist"]},
                {"id": "b3", "options": ["bin", "bist", "ist"]},
            ],
        },
        {
            "b1": {"answer": "bin", "accept": ["bin"]},
            "b2": {"answer": "bist", "accept": ["bist"]},
            "b3": {"answer": "ist", "accept": ["ist"]},
        },
    ))
    items.append(ex(
        "L1_D3", "D", "quiz", "Verbkonjugation heißen", "Verbkonjugation",
        {
            "instruction": "Was ist richtig?",
            "question": "Wie ___ du?",
            "options": [
                {"id": "o1", "text": "heißt"},
                {"id": "o2", "text": "heiße"},
                {"id": "o3", "text": "heißen"},
            ],
        },
        {
            "answer": "o1",
            "explanation": "du → heißt (2. Person Singular).",
        },
    ))
    items.append(ex(
        "L1_D4", "D", "listening", "Namen buchstabieren", "Alphabet",
        {
            "instruction": "Hör zu. Wie schreibt man den Namen?",
            "scene_image": "public/img/l1_scene_telefon.svg",
            "audio_ref": "L1_D4_buchstabieren",
            "default_speed": "slow",
            "lines": [
                {"speaker": "walter", "text": "Wie heißt die Firma, bitte?"},
                {"speaker": "lara", "text": "Nowak. N-O-W-A-K."},
            ],
            "audio": {"slow": [], "normal": []},
            "questions": [
                {
                    "id": "q1",
                    "q": "Wie schreibt man den Namen?",
                    "options": [
                        {"id": "o1", "text": "Nowak"},
                        {"id": "o2", "text": "Novak"},
                        {"id": "o3", "text": "Nowack"},
                    ],
                }
            ],
        },
        {"q1": "o1"},
    ))

    # ── E ──
    items.append(ex(
        "L1_E1", "E", "matching", "Formularfelder", "Adresse",
        {
            "instruction": "Ordne Formularfeld und Wert.",
            "left": [
                {"id": "a", "text": "Vorname"},
                {"id": "b", "text": "Familienname"},
                {"id": "c", "text": "Stadt"},
                {"id": "d", "text": "Postleitzahl"},
            ],
            "right": [
                {"id": "1", "text": "Lara"},
                {"id": "2", "text": "Nowak"},
                {"id": "3", "text": "München"},
                {"id": "4", "text": "80331"},
            ],
        },
        {"a": "1", "b": "2", "c": "3", "d": "4"},
    ))
    items.append(ex(
        "L1_E2", "E", "fill_blank", "Visitenkarte lesen", "Adresse",
        {
            "instruction": "Lies die Visitenkarte und ergänze.",
            "sentence": "Vorname: {{b1}} — Familienname: {{b2}} — Stadt: {{b3}}",
            "hint": "Visitenkarte: Mira Keller · Berlin · Keller Design",
            "blanks": [
                {"id": "b1"},
                {"id": "b2"},
                {"id": "b3"},
            ],
        },
        {
            "b1": {"answer": "Mira", "accept": ["mira", "Mira"]},
            "b2": {"answer": "Keller", "accept": ["keller", "Keller"]},
            "b3": {"answer": "Berlin", "accept": ["berlin", "Berlin"]},
        },
    ))
    items.append(ex(
        "L1_E3", "E", "quiz", "Postleitzahl lesen", "Adresse",
        {
            "instruction": "Was ist richtig?",
            "question": "Visitenkarte: Mira Keller, Friedrichstraße 12, 10117 Berlin. Wie ist die Postleitzahl?",
            "options": [
                {"id": "o1", "text": "10117"},
                {"id": "o2", "text": "80331"},
                {"id": "o3", "text": "12"},
            ],
        },
        {
            "answer": "o1",
            "explanation": "Die Postleitzahl steht vor der Stadt: 10117 Berlin.",
        },
    ))
    items.append(ex(
        "L1_E4", "E", "listening", "Anmeldung — Formular", "Adresse",
        {
            "instruction": "Hör zu und ordne die Informationen.",
            "scene_image": "public/img/l1_scene_telefon.svg",
            "audio_ref": "L1_E4_anmeldung",
            "default_speed": "slow",
            "lines": [
                {"speaker": "walter", "text": "Guten Tag. Mein Vorname ist Omar."},
                {"speaker": "lara", "text": "Und der Familienname?"},
                {"speaker": "walter", "text": "Hassan. Ich wohne in Köln."},
            ],
            "audio": {"slow": [], "normal": []},
            "questions": [
                {
                    "id": "q1",
                    "q": "Wie ist der Vorname?",
                    "options": [
                        {"id": "o1", "text": "Omar"},
                        {"id": "o2", "text": "Hassan"},
                        {"id": "o3", "text": "Walter"},
                    ],
                },
                {
                    "id": "q2",
                    "q": "In welcher Stadt wohnt er?",
                    "options": [
                        {"id": "o1", "text": "Köln"},
                        {"id": "o2", "text": "Berlin"},
                        {"id": "o3", "text": "München"},
                    ],
                },
            ],
        },
        {"q1": "o1", "q2": "o1"},
    ))

    # Folge listening already as C5; add dedicated Folge opener
    items.insert(0, ex(
        "L1_F1", "folge", "listening", "Foto-Hörgeschichte", "Das bin ich",
        {
            "instruction": "Hör die Geschichte: neue Nachbarn. Beantworte die Fragen.",
            "scene_image": "public/img/l1_scene_nachbarn.svg",
            "audio_ref": "L1_folge1",
            "default_speed": "slow",
            "lines": [
                {"speaker": "walter", "text": "Guten Tag. Mein Name ist Walter Baumann."},
                {"speaker": "lara", "text": "Hallo. Ich heiße Lara Nowak."},
                {"speaker": "walter", "text": "Woher kommen Sie, Frau Nowak?"},
                {"speaker": "lara", "text": "Ich komme aus Polen. Und ich spreche ein bisschen Deutsch."},
                {"speaker": "lili", "text": "Ich bin Lili. Ich bin vier."},
                {"speaker": "lara", "text": "Hallo Lili!"},
            ],
            "audio": {"slow": [], "normal": []},
            "questions": [
                {
                    "id": "q1",
                    "q": "Wer kommt aus Polen?",
                    "options": [
                        {"id": "o1", "text": "Lara"},
                        {"id": "o2", "text": "Walter"},
                        {"id": "o3", "text": "Lili"},
                    ],
                },
                {
                    "id": "q2",
                    "q": "Wie alt ist Lili?",
                    "options": [
                        {"id": "o1", "text": "vier"},
                        {"id": "o2", "text": "fünf"},
                        {"id": "o3", "text": "sechs"},
                    ],
                },
            ],
        },
        {"q1": "o1", "q2": "o1"},
    ))

    return {
        "_meta": {
            "note": "Lektion 1 egzersizleri. Schritt sırası folge→A→B→C→D→E. Yapı kitaptan, içerik özgün (telifsiz). de-DE.",
            "schema": {
                "matching": "payload{left[{id,image?,text?}], right[{id,text}]}  solution{leftId:rightId}",
                "fill_blank": "payload{sentence, blanks[{id,options?}]}            solution{blankId:{answer,accept[]}}",
                "listening": "payload{audio{slow[],normal[]}, lines?, questions[{id,q,options}]}  solution{qId:optionId}",
                "quiz": "payload{question, options[{id,text}]}               solution{answer, explanation}",
            },
            "validation": {"case_sensitive": False, "trim": True, "ignore_punctuation": True},
        },
        "items": items,
    }


def build_dialogues() -> dict:
    return {
        "_note": "Lektion 1 ElevenLabs girdisi. de-DE. Üretim: python tools/elevenlabs_tts.py --input tools/dialogues_l1.json",
        "items": [
            {
                "id": "L1_folge1",
                "lektion": 1,
                "vocab_domain": "Das bin ich",
                "lines": [
                    {"speaker": "walter", "text": "Guten Tag. Mein Name ist Walter Baumann."},
                    {"speaker": "lara", "text": "Hallo. Ich heiße Lara Nowak."},
                    {"speaker": "walter", "text": "Woher kommen Sie, Frau Nowak?"},
                    {"speaker": "lara", "text": "Ich komme aus Polen. Und ich spreche ein bisschen Deutsch."},
                    {"speaker": "lili", "text": "Ich bin Lili. Ich bin vier."},
                    {"speaker": "lara", "text": "Hallo Lili!"},
                ],
            },
            {
                "id": "L1_A3_tageszeit",
                "lektion": 1,
                "lines": [
                    {"speaker": "walter", "text": "Guten Abend, Frau Nowak."},
                    {"speaker": "lara", "text": "Guten Abend, Herr Baumann."},
                ],
            },
            {
                "id": "L1_D1_buchstabe_m",
                "lektion": 1,
                "lines": [{"speaker": "narrator", "text": "M"}],
            },
            {
                "id": "L1_D4_buchstabieren",
                "lektion": 1,
                "lines": [
                    {"speaker": "walter", "text": "Wie heißt die Firma, bitte?"},
                    {"speaker": "lara", "text": "Nowak. N-O-W-A-K."},
                ],
            },
            {
                "id": "L1_E4_anmeldung",
                "lektion": 1,
                "lines": [
                    {"speaker": "walter", "text": "Guten Tag. Mein Vorname ist Omar."},
                    {"speaker": "lara", "text": "Und der Familienname?"},
                    {"speaker": "walter", "text": "Hassan. Ich wohne in Köln."},
                ],
            },
            {
                "id": "L1_vocab_narration",
                "lektion": 1,
                "text": "Guten Tag. Hallo. Tschüss. Auf Wiedersehen. der Name. die Frau. der Herr. Deutschland. Polen. Deutsch. Polnisch. die Adresse. die Straße. die Stadt.",
            },
        ],
    }


def main():
    build_vocab()
    write_svgs()
    lektion = build_lektion()
    exercises = build_exercises()
    dialogues = build_dialogues()

    CONTENT.mkdir(parents=True, exist_ok=True)
    MOBILE_CONTENT.mkdir(parents=True, exist_ok=True)

    for dest in (CONTENT, MOBILE_CONTENT):
        (dest / "lektion.json").write_text(
            json.dumps(lektion, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
        )
        (dest / "exercises.json").write_text(
            json.dumps(exercises, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
        )

    (ROOT / "tools" / "dialogues_l1.json").write_text(
        json.dumps(dialogues, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )

    print(f"vocab: {len(VOCAB)}")
    print(f"exercises: {len(exercises['items'])}")
    print(f"svgs: {len(list(VOCAB_DIR.glob('*.svg')))}")
    print("OK")


if __name__ == "__main__":
    main()

#!/usr/bin/env bash
# Netlify CI — Flutter web build (SDK yoksa stable kanaldan kurar).
set -euo pipefail

export PATH="${HOME}/flutter/bin:${PATH}"

if ! command -v flutter >/dev/null 2>&1; then
  echo "▶ Flutter SDK kuruluyor (stable)..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "${HOME}/flutter"
  flutter config --enable-web
  flutter precache --web
fi

flutter --version
flutter pub get
flutter build web --release
